CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50),
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY REFERENCES person (person_id),
    membership_status VARCHAR(20) NOT NULL CHECK (membership_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    registration_date TIMESTAMP NOT NULL
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY REFERENCES person (person_id),
    position VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    works_for_id INT REFERENCES employee (employee_id) ON DELETE SET NULL
);

CREATE TABLE movie (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL UNIQUE,
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
    type VARCHAR(20) NOT NULL CHECK (type IN ('VIP', 'REGULAR'))
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
    end_date TIMESTAMP NOT NULL
);

CREATE TABLE session (
    session_id SERIAL PRIMARY KEY,
    movie_id INT NOT NULL REFERENCES movie (movie_id),
    hall_id INT NOT NULL REFERENCES cinema_hall (hall_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    available_seats INTEGER NOT NULL,
    show_date DATE NOT NULL,
    session_price NUMERIC(10, 2) NOT NULL CHECK (session_price >= 0),
    CONSTRAINT session_time_valid CHECK (start_time < end_time),
    CONSTRAINT session_hall_overlaps EXCLUDE USING gist (
        hall_id WITH =,
        tsrange(start_time, end_time) WITH &&
    )
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    promotion_id INT REFERENCES promotion (promotion_id),
    final_amount NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (final_amount >= 0),
    payment_method VARCHAR(30) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE reservation (
    reservation_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer (customer_id),
    session_id INT NOT NULL REFERENCES session (session_id),
    payment_id INT NOT NULL UNIQUE REFERENCES payment (payment_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED')),
    total_amount NUMERIC(10, 2) NOT NULL,
    reservation_date TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (customer_id, session_id)
);


CREATE TABLE ticket (
    -- IS THIS CORRECT 
    reservation_id INT NOT NULL REFERENCES reservation (reservation_id) ON DELETE CASCADE, 
    ticket_number INTEGER NOT NULL,
    seat_id INT NOT NULL REFERENCES seat (seat_id),
    ticket_price NUMERIC(10, 2) NOT NULL CHECK (ticket_price >= 0),
    purchase_date TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (reservation_id, ticket_number),
    CONSTRAINT ticket_reservation_seat UNIQUE (reservation_id, seat_id)
    -- CONSTRAINT ticket_session_seat UNIQUE (session_id, seat_id),
    -- CONSTRAINT ticket_reservation_session_fk FOREIGN KEY (reservation_id, session_id) REFERENCES reservation (reservation_id, session_id) ON DELETE CASCADE
);

CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer (customer_id),
    movie_id INT NOT NULL REFERENCES movie (movie_id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT review_unique_per_customer UNIQUE (customer_id, movie_id)
);

CREATE TABLE works_on (
    person_id INT NOT NULL REFERENCES person (person_id),
    movie_id INT NOT NULL REFERENCES movie (movie_id),
    role VARCHAR(100) NOT NULL CHECK(role IN ('ACTOR', 'DIRECTOR', 'PRODUCER', 'WRITER', 'CINEMATOGRAPHER')),
    biography TEXT,
    PRIMARY KEY (person_id, movie_id, role)
);

CREATE TABLE monitors (
    employee_id INT NOT NULL REFERENCES employee (employee_id),
    session_id INT NOT NULL REFERENCES session (session_id),
    PRIMARY KEY (employee_id, session_id)
);

CREATE TABLE manages (
    employee_id INT NOT NULL REFERENCES employee (employee_id),
    hall_id INT NOT NULL REFERENCES cinema_hall (hall_id),
    PRIMARY KEY (employee_id, hall_id)
);

CREATE TABLE makes (
    customer_id INT NOT NULL REFERENCES customer (customer_id),
    reservation_id INT NOT NULL REFERENCES reservation (reservation_id),
    PRIMARY KEY (customer_id, reservation_id)
);
CREATE INDEX idx_session_movie ON session (movie_id);
CREATE INDEX idx_reservation_customer ON reservation (customer_id);
CREATE INDEX idx_review_movie ON review (movie_id);
