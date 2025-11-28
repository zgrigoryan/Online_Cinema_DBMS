-- Consolidated seed data (demo users, halls/seats, movies, sessions, reservation)

-- People and roles
INSERT INTO person (id, first_name, last_name, email, phone, password_hash, role, created_at, updated_at, version) VALUES
    (1, 'Alice', 'Admin', 'alice.admin@example.com', '+1234567890', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'ADMIN', NOW(), NOW(), 0),
    (2, 'Cathy', 'Customer', 'cathy.customer@example.com', '+1987654321', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'CUSTOMER', NOW(), NOW(), 0),
    (3, 'Evan', 'Employee', 'evan.employee@example.com', '+1098765432', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'STAFF', NOW(), NOW(), 0),
    (4, 'Demo', 'Customer', 'demo.customer@example.com', '+10000000001', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'CUSTOMER', NOW(), NOW(), 0),
    (5, 'Demo', 'Staff', 'demo.staff@example.com', '+10000000002', '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'STAFF', NOW(), NOW(), 0)
ON CONFLICT (email) DO NOTHING;

INSERT INTO customer (person_id, membership_status, loyalty_points, updated_at) VALUES
    (2, 'ACTIVE', 120, NOW()),
    (4, 'ACTIVE', 50, NOW())
ON CONFLICT (person_id) DO NOTHING;

-- More users/customers
INSERT INTO person (first_name, last_name, email, phone, password_hash, role, created_at, updated_at, version)
SELECT CONCAT('User', g), 'Demo', CONCAT('user', g, '@example.com'), CONCAT('+10000', g),
       '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'CUSTOMER', NOW(), NOW(), 0
FROM generate_series(10, 120) g
ON CONFLICT (email) DO NOTHING;

INSERT INTO customer (person_id, membership_status, loyalty_points, updated_at)
SELECT id, 'ACTIVE', (RANDOM()*500)::int, NOW() FROM person
WHERE email LIKE 'user%' AND id NOT IN (SELECT person_id FROM customer);

INSERT INTO employee (person_id, job_title, active, hire_date) VALUES
    (1, 'Operations Manager', TRUE, CURRENT_DATE - INTERVAL '400 days'),
    (3, 'Projectionist', TRUE, CURRENT_DATE - INTERVAL '200 days'),
    (5, 'Floor Manager', TRUE, CURRENT_DATE - INTERVAL '100 days')
ON CONFLICT (person_id) DO NOTHING;

-- Halls
INSERT INTO cinema_hall (id, name, capacity, location, created_at) VALUES
    (1, 'Hall A', 6, 'Ground Floor', NOW()),
    (2, 'Hall B', 25, 'First Floor', NOW())
ON CONFLICT (name) DO NOTHING;

-- Seats for Hall A (2 rows x 3 seats)
INSERT INTO seat (id, hall_id, seat_row, seat_number, label) VALUES
    (1, 1, 1, 1, 'A1'),
    (2, 1, 1, 2, 'A2'),
    (3, 1, 1, 3, 'A3'),
    (4, 1, 2, 1, 'B1'),
    (5, 1, 2, 2, 'B2'),
    (6, 1, 2, 3, 'B3')
ON CONFLICT (hall_id, seat_row, seat_number) DO NOTHING;

-- Movies
INSERT INTO movie (id, title, description, duration_minutes, release_date, is_active, avg_rating, created_at, updated_at) VALUES
    (1, 'The Grand Adventure', 'Action adventure feature for demo purposes', 120, CURRENT_DATE - INTERVAL '30 days', TRUE, 0, NOW(), NOW()),
    (2, 'Demo Feature One', 'Family adventure film', 105, CURRENT_DATE - INTERVAL '20 days', TRUE, 0, NOW(), NOW()),
    (3, 'Demo Feature Two', 'Light comedy', 95, CURRENT_DATE - INTERVAL '10 days', TRUE, 0, NOW(), NOW()),
    (4, 'Demo Feature Three', 'Thriller', 110, CURRENT_DATE - INTERVAL '5 days', TRUE, 0, NOW(), NOW())
ON CONFLICT (title) DO NOTHING;

-- More movies
INSERT INTO movie (title, description, duration_minutes, release_date, is_active, avg_rating, created_at, updated_at)
SELECT CONCAT('Seed Movie ', g),
       'Generated movie for load testing',
       80 + (g % 60),
       CURRENT_DATE - (g || ' days')::interval,
       TRUE,
       0,
       NOW(),
       NOW()
FROM generate_series(20, 120) g
ON CONFLICT (title) DO NOTHING;

-- Promotions
INSERT INTO promotion (id, code, description, discount_percent, valid_from, valid_to, active, min_amount, usage_limit, times_redeemed) VALUES
    (1, 'WELCOME10', '10% off first reservation', 10.00, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '60 days', TRUE, 20.00, 100, 0),
    (2, 'SPRING15', '15% off spring special', 15.00, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '50 days', TRUE, 20.00, 500, 0)
ON CONFLICT (code) DO NOTHING;

-- Sessions (Hall A)
INSERT INTO session (id, movie_id, hall_id, start_time, end_time, base_price, status, available_seats, created_at, updated_at) VALUES
    (1, 1, 1, (CURRENT_DATE + INTERVAL '1 day')::timestamptz + TIME '18:00', (CURRENT_DATE + INTERVAL '1 day')::timestamptz + TIME '20:00', 12.50, 'SCHEDULED', 6, NOW(), NOW()),
    (2, 2, 1, (CURRENT_DATE + INTERVAL '2 day')::timestamptz + TIME '18:00', (CURRENT_DATE + INTERVAL '2 day')::timestamptz + TIME '20:00', 12.50, 'SCHEDULED', 6, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Additional halls and seats
INSERT INTO cinema_hall (name, capacity, location, created_at)
VALUES
  ('Hall F', 25, 'Third Floor', NOW()),
  ('Hall G', 25, 'Third Floor', NOW())
ON CONFLICT (name) DO NOTHING;

DO $$
DECLARE
  h RECORD;
  r INT;
  c INT;
BEGIN
  FOR h IN SELECT id FROM cinema_hall WHERE name IN ('Hall F','Hall G') LOOP
    FOR r IN 1..5 LOOP
      FOR c IN 1..5 LOOP
        INSERT INTO seat (hall_id, seat_row, seat_number, label)
        VALUES (h.id, r, c, CONCAT('R', r, 'C', c))
        ON CONFLICT (hall_id, seat_row, seat_number) DO NOTHING;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;

-- Sessions for newest movies in Hall F
WITH movies AS (
  SELECT id FROM movie ORDER BY id DESC LIMIT 20
), hall AS (
  SELECT id, capacity FROM cinema_hall WHERE name = 'Hall F' LIMIT 1
)
INSERT INTO session (movie_id, hall_id, start_time, end_time, base_price, status, available_seats, created_at, updated_at)
SELECT m.id, (SELECT id FROM hall), NOW() + (g || ' hours')::interval, NOW() + ((g+2) || ' hours')::interval,
       10 + (g % 5), 'SCHEDULED', (SELECT capacity FROM hall), NOW(), NOW()
FROM movies m CROSS JOIN generate_series(1,5) g
ON CONFLICT DO NOTHING;

-- Bulk promotions
INSERT INTO promotion (code, description, discount_percent, valid_from, valid_to, active, min_amount, usage_limit, times_redeemed)
SELECT CONCAT('PROMO', g), 'Generated promo', 5 + (g % 20), CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '60 days',
       TRUE, 15.00, NULL, 0
FROM generate_series(10, 25) g
ON CONFLICT (code) DO NOTHING;

-- Sample reservations/tickets for last 10 customers and first 5 sessions
DO $$
DECLARE
  cust RECORD;
  sess RECORD;
  seat_id BIGINT;
  ticket_no INT;
  price NUMERIC(10,2);
  res_id BIGINT;
BEGIN
  FOR cust IN SELECT person_id FROM customer ORDER BY person_id DESC LIMIT 10 LOOP
    FOR sess IN SELECT id, base_price, hall_id FROM session ORDER BY id LIMIT 5 LOOP
      price := sess.base_price;
      INSERT INTO reservation (customer_id, session_id, status, total_amount, promotion_id, reserved_at)
      VALUES (cust.person_id, sess.id, 'CONFIRMED', price, NULL, NOW())
      RETURNING id INTO res_id;

      ticket_no := 1;
      SELECT id INTO seat_id FROM seat WHERE hall_id = sess.hall_id ORDER BY RANDOM() LIMIT 1;
      INSERT INTO ticket (reservation_id, ticket_number, seat_id, session_id, price, status)
      VALUES (res_id, ticket_no, seat_id, sess.id, price, 'ACTIVE')
      ON CONFLICT DO NOTHING;

      INSERT INTO payment (reservation_id, amount, status, method, paid_at)
      VALUES (res_id, price, 'PAID', 'CARD', NOW())
      ON CONFLICT DO NOTHING;
    END LOOP;
  END LOOP;
END $$;

-- Reservation + tickets + payment for session 1
INSERT INTO reservation (id, customer_id, session_id, status, total_amount, promotion_id, reserved_at) VALUES
    (1, 2, 1, 'CONFIRMED', 22.50, 1, NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO ticket (reservation_id, ticket_number, seat_id, session_id, price, status) VALUES
    (1, 1, 1, 1, 11.25, 'ACTIVE'),
    (1, 2, 2, 1, 11.25, 'ACTIVE')
ON CONFLICT DO NOTHING;

INSERT INTO payment (id, reservation_id, amount, status, method, paid_at) VALUES
    (1, 1, 22.50, 'PAID', 'CARD', NOW())
ON CONFLICT (id) DO NOTHING;

-- Sample review
INSERT INTO review (id, customer_id, movie_id, rating, comment, created_at, updated_at) VALUES
    (1, 2, 1, 5, 'Great experience!', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Align sequences
SELECT setval(pg_get_serial_sequence('person', 'id'), (SELECT MAX(id) FROM person));
SELECT setval(pg_get_serial_sequence('movie', 'id'), (SELECT MAX(id) FROM movie));
SELECT setval(pg_get_serial_sequence('cinema_hall', 'id'), (SELECT MAX(id) FROM cinema_hall));
SELECT setval(pg_get_serial_sequence('seat', 'id'), (SELECT MAX(id) FROM seat));
SELECT setval(pg_get_serial_sequence('promotion', 'id'), (SELECT MAX(id) FROM promotion));
SELECT setval(pg_get_serial_sequence('session', 'id'), (SELECT MAX(id) FROM session));
SELECT setval(pg_get_serial_sequence('reservation', 'id'), (SELECT MAX(id) FROM reservation));
SELECT setval(pg_get_serial_sequence('payment', 'id'), (SELECT MAX(id) FROM payment));
