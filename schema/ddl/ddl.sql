-- Consolidated DDL for the cinema schema (aligned with current migrations V1-V6)
-- Create extension required for exclusion constraints
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE person (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50),
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'STAFF', 'CUSTOMER')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE customer (
    person_id BIGINT PRIMARY KEY REFERENCES person (id),
    membership_status VARCHAR(20) NOT NULL CHECK (membership_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    loyalty_points INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE employee (
    person_id BIGINT PRIMARY KEY REFERENCES person (id),
    job_title VARCHAR(100) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE movie (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    genre VARCHAR(100) NOT NULL DEFAULT 'Unknown',
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    release_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    avg_rating NUMERIC(3, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE cinema_hall (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    location VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE seat (
    id BIGSERIAL PRIMARY KEY,
    hall_id BIGINT NOT NULL REFERENCES cinema_hall (id) ON DELETE CASCADE,
    seat_row INTEGER NOT NULL CHECK (seat_row > 0),
    seat_number INTEGER NOT NULL CHECK (seat_number > 0),
    label VARCHAR(10),
    CONSTRAINT seat_unique_per_hall UNIQUE (hall_id, seat_row, seat_number)
);

CREATE TABLE promotion (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_percent NUMERIC(5, 2) NOT NULL CHECK (discount_percent >= 0 AND discount_percent <= 100),
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    min_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    usage_limit INTEGER,
    times_redeemed INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT promotion_valid_dates CHECK (valid_from <= valid_to)
);

CREATE TABLE session (
    id BIGSERIAL PRIMARY KEY,
    movie_id BIGINT NOT NULL REFERENCES movie (id),
    hall_id BIGINT NOT NULL REFERENCES cinema_hall (id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    base_price NUMERIC(10, 2) NOT NULL CHECK (base_price >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('SCHEDULED', 'ACTIVE', 'CANCELLED', 'COMPLETED')),
    available_seats INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT session_time_valid CHECK (start_time < end_time),
    CONSTRAINT session_hall_overlaps EXCLUDE USING gist (
        hall_id WITH =,
        tstzrange(start_time, end_time) WITH &&
    ) WHERE (status IN ('SCHEDULED', 'ACTIVE'))
);

CREATE TABLE reservation (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer (person_id),
    session_id BIGINT NOT NULL REFERENCES session (id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED')),
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    promotion_id BIGINT REFERENCES promotion (id),
    reserved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id, session_id)
);

CREATE TABLE ticket (
    reservation_id BIGINT NOT NULL,
    ticket_number INTEGER NOT NULL,
    seat_id BIGINT NOT NULL REFERENCES seat (id),
    session_id BIGINT NOT NULL REFERENCES session (id),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'CANCELLED', 'REFUNDED')),
    PRIMARY KEY (reservation_id, ticket_number),
    CONSTRAINT ticket_reservation_seat UNIQUE (reservation_id, seat_id),
    CONSTRAINT ticket_session_seat UNIQUE (session_id, seat_id),
    CONSTRAINT ticket_reservation_session_fk FOREIGN KEY (reservation_id, session_id) REFERENCES reservation (id, session_id) ON DELETE CASCADE
);

CREATE TABLE payment (
    id BIGSERIAL PRIMARY KEY,
    reservation_id BIGINT NOT NULL UNIQUE REFERENCES reservation (id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'PAID', 'REFUNDED')),
    method VARCHAR(30) NOT NULL,
    paid_at TIMESTAMPTZ
);

CREATE TABLE review (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer (person_id),
    movie_id BIGINT NOT NULL REFERENCES movie (id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT review_unique_per_customer UNIQUE (customer_id, movie_id)
);

CREATE TABLE works_on (
    employee_id BIGINT NOT NULL REFERENCES employee (person_id),
    movie_id BIGINT NOT NULL REFERENCES movie (id),
    role VARCHAR(100) NOT NULL,
    PRIMARY KEY (employee_id, movie_id, role)
);

CREATE TABLE monitors (
    employee_id BIGINT NOT NULL REFERENCES employee (person_id),
    session_id BIGINT NOT NULL REFERENCES session (id),
    PRIMARY KEY (employee_id, session_id)
);

CREATE TABLE manages (
    employee_id BIGINT NOT NULL REFERENCES employee (person_id),
    hall_id BIGINT NOT NULL REFERENCES cinema_hall (id),
    PRIMARY KEY (employee_id, hall_id)
);

CREATE INDEX idx_session_movie ON session (movie_id);
CREATE INDEX idx_reservation_customer ON reservation (customer_id);
CREATE INDEX idx_ticket_session ON ticket (session_id);
CREATE INDEX idx_review_movie ON review (movie_id);
