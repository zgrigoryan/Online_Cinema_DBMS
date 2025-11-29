CREATE EXTENSION IF NOT EXISTS btree_gist;

-- DROP TABLES (IF EXIST)

DROP TABLE IF EXISTS makes CASCADE;
DROP TABLE IF EXISTS manages CASCADE;
DROP TABLE IF EXISTS monitors CASCADE;
DROP TABLE IF EXISTS ticket CASCADE;
DROP TABLE IF EXISTS review CASCADE;
DROP TABLE IF EXISTS works_on CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS promotion CASCADE;
DROP TABLE IF EXISTS session CASCADE;
DROP TABLE IF EXISTS seat CASCADE;
DROP TABLE IF EXISTS cinema_hall CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS movie CASCADE;
DROP TABLE IF EXISTS person CASCADE;

-- DROP ENUM TYPES (IF EXIST)

DROP TYPE IF EXISTS membership_status_type CASCADE;
DROP TYPE IF EXISTS hall_type CASCADE;
DROP TYPE IF EXISTS payment_method_type CASCADE;
DROP TYPE IF EXISTS reservation_status_type CASCADE;
DROP TYPE IF EXISTS crew_role_type CASCADE;

-- CREATE ENUM TYPES

CREATE TYPE membership_status_type AS ENUM ('REGULAR', 'SILVER', 'GOLD', 'PLATINUM');

CREATE TYPE hall_type AS ENUM ('VIP', 'REGULAR');

CREATE TYPE payment_method_type AS ENUM ('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'CASH');

CREATE TYPE reservation_status_type AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED');

CREATE TYPE crew_role_type AS ENUM ('ACTOR', 'DIRECTOR', 'PRODUCER', 'WRITER', 'CINEMATOGRAPHER');

-- TABLES

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50),
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY REFERENCES person (person_id) ON DELETE CASCADE,
    membership_status membership_status_type NOT NULL,
    registration_date TIMESTAMP NOT NULL
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY REFERENCES person (person_id),
    position VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL CHECK (salary >= 0),
    works_for_id INT REFERENCES employee (employee_id) ON DELETE SET NULL
);

CREATE TABLE movie (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    genre VARCHAR(100) NOT NULL DEFAULT 'Unknown',
    duration INTEGER NOT NULL CHECK (duration > 0),
    release_year DATE, 
    movie_rating NUMERIC(10,2) 
);

CREATE TABLE cinema_hall (
    hall_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    type hall_type NOT NULL
);

CREATE TABLE seat (
    seat_id SERIAL PRIMARY KEY,
    hall_id INT NOT NULL REFERENCES cinema_hall (hall_id) ON DELETE CASCADE,
    row_number INTEGER NOT NULL CHECK (row_number > 0),
    seat_number INTEGER NOT NULL CHECK (seat_number > 0),
    base_price NUMERIC(10, 2) NOT NULL CHECK (base_price >= 0),
    category VARCHAR(50) NOT NULL DEFAULT 'Standard',
    CONSTRAINT seat_unique_per_hall UNIQUE (hall_id, row_number, seat_number)
);

CREATE TABLE promotion (
    promotion_id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_amount NUMERIC(5, 2) NOT NULL CHECK (discount_amount >= 0),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    CONSTRAINT promotion_date_valid CHECK (start_date < end_date) 
);

CREATE TABLE session (
    session_id SERIAL PRIMARY KEY,
    movie_id INT NOT NULL REFERENCES movie (movie_id) ON DELETE CASCADE,
    hall_id INT NOT NULL REFERENCES cinema_hall (hall_id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    available_seats INTEGER NOT NULL CHECK (available_seats >= 0),
    show_date DATE NOT NULL,
    session_price NUMERIC(10, 2) NOT NULL CHECK (session_price >= 0),
    CONSTRAINT session_time_valid CHECK (start_time < end_time),
    CONSTRAINT session_hall_overlaps EXCLUDE USING gist (
        hall_id WITH =,
        tsrange(start_time, end_time) WITH &&
    )
);

-- Trigger to enforce hall capacity
CREATE OR REPLACE FUNCTION enforce_session_capacity() RETURNS TRIGGER AS $$
DECLARE
    hall_capacity INTEGER;
BEGIN
    SELECT capacity INTO hall_capacity FROM cinema_hall WHERE hall_id = NEW.hall_id;
    IF hall_capacity IS NULL THEN
        RAISE EXCEPTION 'Hall % not found for session %', NEW.hall_id, NEW.session_id;
    END IF;
    IF NEW.available_seats > hall_capacity THEN
        RAISE EXCEPTION 'available_seats % exceeds hall capacity % for hall %', NEW.available_seats, hall_capacity, NEW.hall_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_session_capacity
BEFORE INSERT OR UPDATE OF available_seats, hall_id
ON session
FOR EACH ROW
EXECUTE FUNCTION enforce_session_capacity();

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    promotion_id INT REFERENCES promotion (promotion_id),
    final_amount NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (final_amount >= 0),
    payment_method payment_method_type NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE reservation (
    reservation_id SERIAL PRIMARY KEY,
    session_id INT NOT NULL REFERENCES session (session_id) ON DELETE CASCADE,
    payment_id INT REFERENCES payment (payment_id) ON DELETE RESTRICT, -- nullable: reservation may not be paid yet
    status reservation_status_type NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    reservation_date TIMESTAMP NOT NULL DEFAULT NOW(),
    customer_id INT NOT NULL REFERENCES customer (customer_id) ON DELETE CASCADE,
    UNIQUE(session_id, customer_id)
);

CREATE TABLE ticket (
    reservation_id INT NOT NULL REFERENCES reservation (reservation_id) ON DELETE CASCADE, 
    ticket_number INTEGER NOT NULL,
    seat_id INT NOT NULL REFERENCES seat (seat_id),
    ticket_price NUMERIC(10, 2) NOT NULL CHECK (ticket_price >= 0),
    purchase_date TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (reservation_id, ticket_number),
    CONSTRAINT ticket_reservation_seat UNIQUE (reservation_id, seat_id)
);

-- Trigger to enforce that the seat's hall matches the session's hall for the reservation
CREATE OR REPLACE FUNCTION enforce_ticket_seat_session() RETURNS TRIGGER AS $$
DECLARE
    seat_hall INT;
    session_hall INT;
BEGIN
    SELECT hall_id INTO seat_hall FROM seat WHERE seat_id = NEW.seat_id;
    IF seat_hall IS NULL THEN
        RAISE EXCEPTION 'Seat % not found', NEW.seat_id;
    END IF;

    SELECT s.hall_id INTO session_hall
    FROM reservation r
    JOIN session s ON s.session_id = r.session_id
    WHERE r.reservation_id = NEW.reservation_id;

    IF session_hall IS NULL THEN
        RAISE EXCEPTION 'Reservation % not found or has no session', NEW.reservation_id;
    END IF;

    IF seat_hall <> session_hall THEN
        RAISE EXCEPTION 'Seat % belongs to hall %, but reservation % is for hall %', NEW.seat_id, seat_hall, NEW.reservation_id, session_hall;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_seat_matches_session
BEFORE INSERT OR UPDATE OF seat_id, reservation_id
ON ticket
FOR EACH ROW
EXECUTE FUNCTION enforce_ticket_seat_session();

CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer (customer_id) ON DELETE CASCADE,
    movie_id INT NOT NULL REFERENCES movie (movie_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT review_unique_per_customer UNIQUE (customer_id, movie_id)
);

CREATE TABLE works_on (
    person_id INT NOT NULL REFERENCES person (person_id) ON DELETE CASCADE,
    movie_id INT NOT NULL REFERENCES movie (movie_id) ON DELETE CASCADE,
    role crew_role_type NOT NULL,
    biography TEXT,
    PRIMARY KEY (person_id, movie_id, role)
);

CREATE TABLE monitors (
    employee_id INT NOT NULL REFERENCES employee (employee_id),
    session_id INT NOT NULL REFERENCES session (session_id),
    PRIMARY KEY (employee_id, session_id)
);

CREATE TABLE manages (
    employee_id INT NOT NULL REFERENCES employee (employee_id) ON DELETE CASCADE,
    hall_id INT NOT NULL REFERENCES cinema_hall (hall_id) ON DELETE CASCADE,
    PRIMARY KEY (employee_id, hall_id)
);

CREATE INDEX idx_session_movie ON session (movie_id);
CREATE INDEX idx_reservation_customer ON reservation (customer_id);
CREATE INDEX idx_review_movie ON review (movie_id);
