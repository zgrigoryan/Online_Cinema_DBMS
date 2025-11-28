-- Additional demo seed data (idempotent-ish via ON CONFLICT or existence checks)

-- Demo users
INSERT INTO person (first_name, last_name, email, phone, password_hash, role, created_at, updated_at, version)
VALUES
  ('Admin', 'User', 'admin@example.com', '+10000000000',
   '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'ADMIN', NOW(), NOW(), 0),
  ('Demo', 'Customer', 'demo.customer@example.com', '+10000000001',
   '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'CUSTOMER', NOW(), NOW(), 0),
  ('Demo', 'Staff', 'demo.staff@example.com', '+10000000002',
   '{bcrypt}$2a$10$8A6yYwO5lYpG6OQBljkN0OlT0T3W76dGOwXBLcWglc7aKNP9xNRS.', 'STAFF', NOW(), NOW(), 0)
ON CONFLICT (email) DO NOTHING;

INSERT INTO customer (person_id, membership_status, loyalty_points, updated_at)
SELECT id, 'ACTIVE', 50, NOW()
FROM person p WHERE p.email = 'demo.customer@example.com'
ON CONFLICT (person_id) DO NOTHING;

INSERT INTO employee (person_id, job_title, active, hire_date)
SELECT id, 'Operations', TRUE, CURRENT_DATE - INTERVAL '100 days'
FROM person p WHERE p.email = 'demo.staff@example.com'
ON CONFLICT (person_id) DO NOTHING;

-- Demo movies
INSERT INTO movie (title, description, duration_minutes, release_date, is_active, avg_rating, created_at, updated_at)
VALUES
  ('Demo Feature One', 'Family adventure film', 105, CURRENT_DATE - INTERVAL '20 days', TRUE, 0, NOW(), NOW()),
  ('Demo Feature Two', 'Light comedy', 95, CURRENT_DATE - INTERVAL '10 days', TRUE, 0, NOW(), NOW()),
  ('Demo Feature Three', 'Thriller', 110, CURRENT_DATE - INTERVAL '5 days', TRUE, 0, NOW(), NOW())
ON CONFLICT (title) DO NOTHING;

-- Demo sessions in Hall A
DO $$
DECLARE
  hall_a_id BIGINT;
  movie_id BIGINT;
BEGIN
  SELECT id INTO hall_a_id FROM cinema_hall WHERE name = 'Hall A';
  IF hall_a_id IS NULL THEN
    SELECT id INTO hall_a_id FROM cinema_hall LIMIT 1;
  END IF;

  FOR movie_id IN SELECT id FROM movie WHERE title IN ('Demo Feature One','Demo Feature Two','Demo Feature Three') LOOP
    INSERT INTO session (movie_id, hall_id, start_time, end_time, base_price, status, available_seats, created_at, updated_at)
    VALUES (
      movie_id,
      hall_a_id,
      (CURRENT_DATE + INTERVAL '1 day')::timestamptz + TIME '18:00',
      (CURRENT_DATE + INTERVAL '1 day')::timestamptz + TIME '20:00',
      12.50,
      'SCHEDULED',
      (SELECT capacity FROM cinema_hall WHERE id = hall_a_id),
      NOW(), NOW()
    )
    ON CONFLICT DO NOTHING;
  END LOOP;
END $$;

-- Demo reservation with tickets for first session
DO $$
DECLARE
  cust_id BIGINT;
  sess_id BIGINT;
  seat1 BIGINT;
  seat2 BIGINT;
  base_price_val NUMERIC(10,2);
  total NUMERIC(10,2);
  res_id BIGINT;
BEGIN
  SELECT person_id INTO cust_id FROM customer c JOIN person p ON c.person_id = p.id WHERE p.email = 'demo.customer@example.com';
  SELECT id, base_price INTO sess_id, base_price_val FROM session ORDER BY start_time LIMIT 1;
  SELECT id INTO seat1 FROM seat WHERE hall_id = (SELECT hall_id FROM session WHERE id = sess_id) ORDER BY id LIMIT 1;
  SELECT id INTO seat2 FROM seat WHERE hall_id = (SELECT hall_id FROM session WHERE id = sess_id) ORDER BY id OFFSET 1 LIMIT 1;

  IF cust_id IS NOT NULL AND sess_id IS NOT NULL AND seat1 IS NOT NULL AND seat2 IS NOT NULL THEN
    total := base_price_val * 2;
    INSERT INTO reservation (customer_id, session_id, status, total_amount, promotion_id, reserved_at)
    VALUES (cust_id, sess_id, 'CONFIRMED', total, NULL, NOW())
    ON CONFLICT DO NOTHING;

    SELECT id INTO res_id FROM reservation WHERE customer_id = cust_id AND session_id = sess_id ORDER BY reserved_at DESC LIMIT 1;

    IF res_id IS NOT NULL THEN
      INSERT INTO ticket (reservation_id, ticket_number, seat_id, session_id, price, status)
      VALUES
        (res_id, 1, seat1, sess_id, base_price_val, 'ACTIVE'),
        (res_id, 2, seat2, sess_id, base_price_val, 'ACTIVE')
      ON CONFLICT DO NOTHING;

      INSERT INTO payment (reservation_id, amount, status, method, paid_at)
      VALUES (res_id, total, 'PAID', 'CARD', NOW())
      ON CONFLICT DO NOTHING;
    END IF;
  END IF;
END $$;
