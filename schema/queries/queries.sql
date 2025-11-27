-- Reporting and utility queries

-- Revenue by day
SELECT DATE(p.paid_at) AS day, SUM(p.amount) AS revenue
FROM payment p
WHERE p.status = 'PAID'
GROUP BY day
ORDER BY day DESC;

-- Revenue by movie
SELECT m.title, SUM(p.amount) AS revenue
FROM payment p
JOIN reservation r ON p.reservation_id = r.id
JOIN session s ON r.session_id = s.id
JOIN movie m ON s.movie_id = m.id
WHERE p.status = 'PAID'
GROUP BY m.title
ORDER BY revenue DESC;

-- Occupancy by session
SELECT s.id AS session_id,
       m.title,
       h.name AS hall,
       h.capacity,
       (h.capacity - s.available_seats) AS seats_sold,
       ROUND(((h.capacity - s.available_seats)::numeric / h.capacity) * 100, 2) AS occupancy_pct
FROM session s
JOIN movie m ON s.movie_id = m.id
JOIN cinema_hall h ON s.hall_id = h.id
ORDER BY s.start_time DESC;

-- Top customers by spend
SELECT c.person_id,
       p.email,
       SUM(pay.amount) AS total_spend,
       COUNT(pay.id) AS payments
FROM payment pay
JOIN reservation r ON pay.reservation_id = r.id
JOIN customer c ON r.customer_id = c.person_id
JOIN person p ON p.id = c.person_id
WHERE pay.status = 'PAID'
GROUP BY c.person_id, p.email
ORDER BY total_spend DESC
LIMIT 10;

-- Promotion effectiveness (usage and revenue impact)
SELECT promo.code,
       promo.description,
       COUNT(r.id) AS reservations,
       SUM(r.total_amount) AS gross_after_discount,
       promo.times_redeemed,
       promo.usage_limit
FROM promotion promo
LEFT JOIN reservation r ON promo.id = r.promotion_id
GROUP BY promo.id, promo.code, promo.description, promo.times_redeemed, promo.usage_limit
ORDER BY reservations DESC;

-- Average rating per movie
SELECT m.title, ROUND(AVG(r.rating)::numeric, 2) AS avg_rating, COUNT(r.id) AS review_count
FROM review r
JOIN movie m ON r.movie_id = m.id
GROUP BY m.title
ORDER BY avg_rating DESC;

-- Sessions with potential overlaps (diagnostic)
SELECT s1.id AS session_a,
       s2.id AS session_b,
       h.name AS hall,
       s1.start_time AS a_start,
       s1.end_time AS a_end,
       s2.start_time AS b_start,
       s2.end_time AS b_end
FROM session s1
JOIN session s2 ON s1.hall_id = s2.hall_id
JOIN cinema_hall h ON h.id = s1.hall_id
WHERE s1.id < s2.id
  AND s1.start_time < s2.end_time
  AND s1.end_time > s2.start_time
ORDER BY h.name;

-- Seat availability map for a session
SELECT seat.id,
       seat.label,
       seat.seat_row,
       seat.seat_number,
       CASE WHEN t.seat_id IS NULL THEN 'AVAILABLE' ELSE 'BOOKED' END AS status
FROM seat
JOIN session s ON seat.hall_id = s.hall_id
LEFT JOIN ticket t ON t.session_id = s.id AND t.seat_id = seat.id
WHERE s.id = :sessionId
ORDER BY seat.seat_row, seat.seat_number;
