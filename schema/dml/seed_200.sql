-- Bulk data seed to reach ~200 entities for testing/demo

-- Base users (adds to existing if run after other seeds)
INSERT INTO person (first_name, last_name, email, phone, password_hash, role, created_at, updated_at, version)
SELECT CONCAT('User', g), 'Demo', CONCAT('user', g, '@example.com'), CONCAT('+10000', g),
       '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'CUSTOMER', NOW(), NOW(), 0
FROM generate_series(10, 120) g
ON CONFLICT (email) DO NOTHING;

INSERT INTO customer (person_id, membership_status, loyalty_points, updated_at)
SELECT id, 'ACTIVE', (RANDOM()*500)::int, NOW() FROM person
WHERE email LIKE 'user%' AND id NOT IN (SELECT person_id FROM customer);

-- Add more movies
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

-- Add a couple more halls and seats (5x5 each)
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

-- Sessions for newly added movies in Hall F
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

-- Promotions
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
