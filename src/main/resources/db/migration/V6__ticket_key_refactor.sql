-- Make ticket a weak entity with partial key per reservation
ALTER TABLE ticket
  ADD COLUMN IF NOT EXISTS ticket_number INTEGER;

-- Populate ticket_number with row_number per reservation for existing data
WITH numbered AS (
  SELECT reservation_id, seat_id, session_id,
         ROW_NUMBER() OVER (PARTITION BY reservation_id ORDER BY seat_id) AS rn
  FROM ticket
)
UPDATE ticket t
SET ticket_number = n.rn
FROM numbered n
WHERE t.reservation_id = n.reservation_id
  AND t.seat_id = n.seat_id
  AND t.session_id = n.session_id;

ALTER TABLE ticket
  ALTER COLUMN ticket_number SET NOT NULL;

-- Drop old PK and recreate with (reservation_id, ticket_number)
ALTER TABLE ticket DROP CONSTRAINT ticket_pkey;
ALTER TABLE ticket
  ADD CONSTRAINT ticket_pkey PRIMARY KEY (reservation_id, ticket_number);

-- Keep uniqueness of seat within session
ALTER TABLE ticket
  ADD CONSTRAINT ticket_reservation_seat_unique UNIQUE (reservation_id, seat_id);
