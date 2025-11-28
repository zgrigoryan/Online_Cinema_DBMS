-- Minimal seed data for local testing
INSERT INTO person (id, first_name, last_name, email, phone, password_hash, role, created_at, updated_at) VALUES
    (1, 'Alice', 'Admin', 'alice.admin@example.com', '+1234567890', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'ADMIN', NOW(), NOW()),
    (2, 'Cathy', 'Customer', 'cathy.customer@example.com', '+1987654321', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'CUSTOMER', NOW(), NOW()),
    (3, 'Evan', 'Employee', 'evan.employee@example.com', '+1098765432', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'STAFF', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO customer (person_id, membership_status, loyalty_points, updated_at) VALUES
    (2, 'ACTIVE', 120, NOW())
ON CONFLICT (person_id) DO NOTHING;

INSERT INTO employee (person_id, job_title, active, hire_date) VALUES
    (1, 'Operations Manager', TRUE, CURRENT_DATE - INTERVAL '400 days'),
    (3, 'Projectionist', TRUE, CURRENT_DATE - INTERVAL '200 days')
ON CONFLICT (person_id) DO NOTHING;

INSERT INTO movie (id, title, description, duration_minutes, release_date, is_active, avg_rating, created_at, updated_at) VALUES
    (1, 'The Grand Adventure', 'Action adventure feature for demo purposes', 120, CURRENT_DATE - INTERVAL '30 days', TRUE, 0, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO cinema_hall (id, name, capacity, location, created_at) VALUES
    (1, 'Hall A', 6, 'Ground Floor', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO seat (id, hall_id, seat_row, seat_number, label) VALUES
    (1, 1, 1, 1, 'A1'),
    (2, 1, 1, 2, 'A2'),
    (3, 1, 1, 3, 'A3'),
    (4, 1, 2, 1, 'B1'),
    (5, 1, 2, 2, 'B2'),
    (6, 1, 2, 3, 'B3')
ON CONFLICT (id) DO NOTHING;

INSERT INTO promotion (id, code, description, discount_percent, valid_from, valid_to, active, min_amount, usage_limit, times_redeemed) VALUES
    (1, 'WELCOME10', '10% off first reservation', 10.00, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '60 days', TRUE, 20.00, 100, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO session (id, movie_id, hall_id, start_time, end_time, base_price, status, available_seats, created_at, updated_at) VALUES
    (1, 1, 1, (CURRENT_DATE + INTERVAL '1 day')::timestamptz + TIME '18:00', (CURRENT_DATE + INTERVAL '1 day')::timestamptz + TIME '20:00', 12.50, 'SCHEDULED', 6, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO reservation (id, customer_id, session_id, status, total_amount, promotion_id, reserved_at) VALUES
    (1, 2, 1, 'CONFIRMED', 22.50, 1, NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO ticket (reservation_id, ticket_number, seat_id, session_id, price, status) VALUES
    (1, 1, 1, 1, 11.25, 'ACTIVE'),
    (1, 2, 2, 1, 11.25, 'ACTIVE')
ON CONFLICT DO NOTHING;

INSERT INTO payment (id, reservation_id, amount, status, method, paid_at) VALUES
    (1, 1, 22.50, 'PAID', 'CARD', NOW());

INSERT INTO review (id, customer_id, movie_id, rating, comment, created_at, updated_at) VALUES
    (1, 2, 1, 5, 'Great experience!', NOW(), NOW());

INSERT INTO works_on (employee_id, movie_id, role) VALUES
    (3, 1, 'Projection'),
    (1, 1, 'Scheduling');

INSERT INTO monitors (employee_id, session_id) VALUES
    (3, 1);

INSERT INTO manages (employee_id, hall_id) VALUES
    (1, 1);

-- Align sequences with the explicit IDs used above
SELECT setval(pg_get_serial_sequence('person', 'id'), (SELECT MAX(id) FROM person));
SELECT setval(pg_get_serial_sequence('movie', 'id'), (SELECT MAX(id) FROM movie));
SELECT setval(pg_get_serial_sequence('cinema_hall', 'id'), (SELECT MAX(id) FROM cinema_hall));
SELECT setval(pg_get_serial_sequence('seat', 'id'), (SELECT MAX(id) FROM seat));
SELECT setval(pg_get_serial_sequence('promotion', 'id'), (SELECT MAX(id) FROM promotion));
SELECT setval(pg_get_serial_sequence('session', 'id'), (SELECT MAX(id) FROM session));
SELECT setval(pg_get_serial_sequence('reservation', 'id'), (SELECT MAX(id) FROM reservation));
SELECT setval(pg_get_serial_sequence('payment', 'id'), (SELECT MAX(id) FROM payment));
