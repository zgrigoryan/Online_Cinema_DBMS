-- Bulk seed data (~200 rows) to enrich the demo database

-- Additional halls
INSERT INTO cinema_hall (name, capacity, location, created_at)
VALUES
  ('Hall B', 25, 'First Floor', NOW()),
  ('Hall C', 25, 'First Floor', NOW()),
  ('Hall D', 25, 'Second Floor', NOW()),
  ('Hall E', 25, 'Second Floor', NOW())
ON CONFLICT (name) DO NOTHING;

-- Generate seats for new halls (5 rows x 5 seats = 25 per hall)
DO $$
DECLARE
  hall_rec RECORD;
  r INT;
  c INT;
BEGIN
  FOR hall_rec IN SELECT id FROM cinema_hall WHERE name IN ('Hall B', 'Hall C', 'Hall D', 'Hall E') LOOP
    FOR r IN 1..5 LOOP
      FOR c IN 1..5 LOOP
        INSERT INTO seat (hall_id, seat_row, seat_number, label)
        VALUES (hall_rec.id, r, c, CONCAT('R', r, 'C', c))
        ON CONFLICT (hall_id, seat_row, seat_number) DO NOTHING;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;

-- Add a batch of movies
INSERT INTO movie (title, description, duration_minutes, release_date, is_active, avg_rating, created_at, updated_at)
SELECT
  CONCAT('Demo Movie ', g) AS title,
  'Synthetic seeded movie for testing' AS description,
  90 + (g % 40) AS duration_minutes,
  CURRENT_DATE - (g || ' days')::interval AS release_date,
  TRUE AS is_active,
  0 AS avg_rating,
  NOW(),
  NOW()
FROM generate_series(2, 80) AS g
ON CONFLICT (title) DO NOTHING;

-- Promotions batch
INSERT INTO promotion (code, description, discount_percent, valid_from, valid_to, active, min_amount, usage_limit, times_redeemed)
VALUES
  ('SPRING15', '15% off spring special', 15.00, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '50 days', TRUE, 20.00, 500, 0),
  ('WEEKEND5', '5% off weekend shows', 5.00, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '90 days', TRUE, 10.00, NULL, 0),
  ('BULK20', '20% off 4+ tickets', 20.00, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '120 days', TRUE, 40.00, 200, 0),
  ('EARLYBIRD', '12% off early bird', 12.00, CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE + INTERVAL '30 days', TRUE, 15.00, 150, 0),
  ('NIGHTOWL', '8% off late shows', 8.00, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '45 days', TRUE, 12.00, NULL, 0)
ON CONFLICT (code) DO NOTHING;

-- Batch customers (person + customer rows)
WITH new_people AS (
  INSERT INTO person (first_name, last_name, email, phone, password_hash, role, created_at, updated_at)
  SELECT
    CONCAT('Customer', g),
    'User',
    CONCAT('customer', g, '@example.com'),
    CONCAT('+10000000', LPAD(g::text, 3, '0')),
    '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.',
    'CUSTOMER',
    NOW(),
    NOW()
  FROM generate_series(10, 29) AS g
  ON CONFLICT (email) DO NOTHING
  RETURNING id
)
INSERT INTO customer (person_id, membership_status, loyalty_points, updated_at)
SELECT id, 'ACTIVE', (RANDOM() * 300)::int, NOW() FROM new_people;

-- Sessions across halls (non-overlapping by design)
WITH halls AS (
  SELECT name, id, capacity FROM cinema_hall
),
movies AS (
  SELECT id, title FROM movie WHERE id <= 10
)
INSERT INTO session (movie_id, hall_id, start_time, end_time, base_price, status, available_seats, created_at, updated_at)
SELECT
  m.id,
  h.id,
  (CURRENT_DATE + (row_number() OVER () || ' days')::interval)::timestamptz + TIME '12:00',
  (CURRENT_DATE + (row_number() OVER () || ' days')::interval)::timestamptz + TIME '14:00',
  10 + (m.id % 5),
  'SCHEDULED',
  h.capacity,
  NOW(),
  NOW()
FROM movies m
JOIN halls h ON (m.id % 5) + 1 = h.id
LIMIT 10;

-- Align sequences after bulk inserts
SELECT setval(pg_get_serial_sequence('movie', 'id'), (SELECT MAX(id) FROM movie));
SELECT setval(pg_get_serial_sequence('cinema_hall', 'id'), (SELECT MAX(id) FROM cinema_hall));
SELECT setval(pg_get_serial_sequence('seat', 'id'), (SELECT MAX(id) FROM seat));
SELECT setval(pg_get_serial_sequence('promotion', 'id'), (SELECT MAX(id) FROM promotion));
