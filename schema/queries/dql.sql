-- 2. Browse Movies and View Details
SELECT 
    m.movie_id,
    m.title,
    m.genre,
    m.duration,
    m.description,
    m.release_year,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS total_reviews
FROM movie m
LEFT JOIN review r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title, m.genre, m.duration, m.description, m.release_year
ORDER BY avg_rating DESC NULLS LAST, total_reviews DESC;

-- 3. View Upcoming Sessions for a Selected Movie
SELECT 
    s.session_id,
    m.movie_id,
    m.title AS movie_title,
    s.show_date,
    s.start_time,
    s.end_time,
    ch.hall_id,
    ch.name AS hall_name,
    ch.type AS hall_type,
    ch.capacity AS total_capacity,
    s.available_seats,
    (ch.capacity - s.available_seats) AS seats_booked,
    s.session_price
FROM session s
JOIN movie m ON s.movie_id = m.movie_id
JOIN cinema_hall ch ON s.hall_id = ch.hall_id
WHERE m.movie_id = 8   -- for checking
  AND s.start_time >= NOW()
ORDER BY s.start_time;

-- 4. Session Seat Map and Availability
SELECT 
    se.seat_id,
    se.row_number,
    se.seat_number,
    se.category,
    se.base_price,
    CASE 
        WHEN se.seat_id IN (
            SELECT t.seat_id
            FROM ticket t
            INNER JOIN reservation r ON t.reservation_id = r.reservation_id
            WHERE r.session_id = 1
              AND r.status IN ('PENDING', 'CONFIRMED')
        ) THEN 'RESERVED'
        ELSE 'AVAILABLE'
    END AS seat_status
FROM 
    seat se
WHERE 
    se.hall_id = (SELECT hall_id FROM session WHERE session_id = 1)
ORDER BY 
    se.row_number, se.seat_number;

-- 5. Validate Seat Availability Before Booking
SELECT 
    s.seat_id,
    s.row_number,
    s.seat_number,
    CASE 
        WHEN t.seat_id IS NOT NULL THEN 'OCCUPIED'
        ELSE 'AVAILABLE'
    END AS availability_status
FROM seat s
LEFT JOIN (
    SELECT t.seat_id, t.reservation_id
    FROM ticket t
    INNER JOIN reservation r ON t.reservation_id = r.reservation_id
    WHERE r.session_id = 2
      AND r.status IN ('CONFIRMED', 'PENDING')
) t ON s.seat_id = t.seat_id
WHERE s.seat_id IN (6, 7, 8) -- for checking
  AND s.hall_id = (SELECT hall_id FROM session WHERE session_id = 2);

-- 7. Cancel reservation
UPDATE reservation
SET status = 'CANCELLED'
WHERE reservation_id = 5
RETURNING *;

-- 8. Customer Purchase and Ticket History
SELECT
    r.reservation_id,
    r.status AS reservation_status,
    r.reservation_date,
    t.ticket_number,
    t.ticket_price,
    t.seat_id,
    st.row_number,
    st.seat_number,
    st.category AS seat_category,
    ss.session_id,
    ss.start_time,
    ss.end_time,
    ch.name AS hall_name,
    m.title AS movie_title,
    p.final_amount AS paid_amount,
    p.payment_method,
    p.payment_date
FROM reservation r
JOIN ticket t ON r.reservation_id = t.reservation_id
JOIN seat st ON t.seat_id = st.seat_id
JOIN session ss ON r.session_id = ss.session_id
JOIN cinema_hall ch ON ss.hall_id = ch.hall_id
JOIN movie m ON ss.movie_id = m.movie_id
JOIN payment p ON r.payment_id = p.payment_id
WHERE r.customer_id = customer_id
ORDER BY r.reservation_date DESC, ticket_number ASC;

-- 9. Submit and Manage Movie Reviews
INSERT INTO review (customer_id, movie_id, rating, comment)
SELECT 
    r.customer_id,
    s.movie_id,
    5 AS rating,
    'Great movie!' AS comment
FROM reservation r
JOIN ticket t ON r.reservation_id = t.reservation_id
JOIN session s ON r.session_id = s.session_id
ORDER BY r.reservation_date DESC
LIMIT 1
RETURNING *;

-- 10. Retrieve Film Crew for a Movie
SELECT 
    p.first_name,
    p.last_name,
    w.role,
    w.biography
FROM works_on w
JOIN person p ON p.person_id = w.person_id
WHERE w.movie_id = movie_id;

-- 11. Global Session Overlap Detection
SELECT 
    s1.session_id AS session_a,
    s1.hall_id AS hall_a,
    s1.start_time AS start_a,
    s1.end_time AS end_a,
    s2.session_id AS session_b,
    s2.hall_id AS hall_b,
    s2.start_time AS start_b,
    s2.end_time AS end_b
FROM session s1
JOIN session s2
    ON s1.hall_id = s2.hall_id
   AND s1.session_id < s2.session_id
   AND tsrange(s1.start_time, s1.end_time)
       && tsrange(s2.start_time, s2.end_time)
ORDER BY s1.hall_id, s1.start_time;

-- 12. Hall-Specific Session Overlap Check (During Scheduling)
SELECT 
    s1.session_id AS session_a,
    s1.hall_id    AS hall,
    s1.start_time AS start_a,
    s1.end_time   AS end_a,
    s2.session_id AS session_b,
    s2.start_time AS start_b,
    s2.end_time   AS end_b
FROM session s1
JOIN session s2
    ON s1.hall_id = s2.hall_id          
   AND s1.session_id < s2.session_id    
   AND s1.start_time < s2.end_time      
   AND s1.end_time   > s2.start_time    
ORDER BY hall, start_a;

-- 13. Hall Utilization and Occupancy Analysis
-- Seats sold vs hall capacity per session.
SELECT
    s.session_id,
    s.show_date,
    s.start_time,
    m.title AS movie_title,
    ch.name AS hall_name,
    ch.capacity,
    COUNT(t.ticket_number) AS tickets_sold,
    COALESCE(SUM(t.ticket_price), 0) AS ticket_revenue,
    ROUND(COUNT(t.ticket_number)::NUMERIC * 100 / NULLIF(ch.capacity, 0), 2) AS occupancy_percent
FROM session s
JOIN cinema_hall ch ON ch.hall_id = s.hall_id
JOIN movie m ON m.movie_id = s.movie_id
LEFT JOIN reservation r ON r.session_id = s.session_id
LEFT JOIN ticket t ON t.reservation_id = r.reservation_id
GROUP BY s.session_id, s.show_date, s.start_time, m.title, ch.name, ch.capacity
ORDER BY s.show_date, s.start_time, s.session_id;

-- 14. Revenue Report by Date and Payment Method
-- Summarize payments per day and payment method.
SELECT
    payment_date::DATE AS payment_day,
    payment_method,
    SUM(final_amount) AS total_revenue,
    COUNT(*) AS payment_count
FROM payment
GROUP BY payment_day, payment_method
ORDER BY payment_day, payment_method;

-- 15. Revenue per Movie
-- Total reservation revenue per movie (confirmed + paid reservations).
SELECT
    m.movie_id,
    m.title AS movie_title,
    SUM(r.total_amount) AS total_revenue,
    COUNT(DISTINCT r.reservation_id) AS reservations_count
FROM movie m
JOIN session s ON s.movie_id = m.movie_id
JOIN reservation r ON r.session_id = s.session_id
LEFT JOIN payment p ON p.payment_id = r.payment_id
WHERE r.status = 'CONFIRMED'
GROUP BY m.movie_id, m.title
ORDER BY total_revenue DESC, m.title;

-- 16. Top Customer Ranking
-- Rank customers by spend and confirmed reservation count.
SELECT
    c.customer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS customer_name,
    SUM(r.total_amount) AS total_spent,
    COUNT(*) AS confirmed_reservations
FROM customer c
JOIN person p ON p.person_id = c.customer_id
JOIN reservation r ON r.customer_id = c.customer_id
LEFT JOIN payment pay ON pay.payment_id = r.payment_id
WHERE r.status = 'CONFIRMED'
GROUP BY c.customer_id, p.first_name, p.last_name
ORDER BY total_spent DESC, confirmed_reservations DESC, customer_name;

-- 17. Promotion Usage and Effectiveness
-- How often promotions were used and the revenue linked to them.
SELECT
    promo.promotion_id,
    promo.code,
    COUNT(pay.payment_id) AS times_used,
    COALESCE(SUM(pay.final_amount), 0) AS revenue_with_promo
FROM promotion promo
LEFT JOIN payment pay ON pay.promotion_id = promo.promotion_id
GROUP BY promo.promotion_id, promo.code
ORDER BY times_used DESC, promo.code;

-- 18. Employee Workload Overview
-- Sessions monitored per employee per day.
SELECT
    e.employee_id,
    CONCAT(per.first_name, ' ', per.last_name) AS employee_name,
    s.show_date,
    COUNT(mn.session_id) AS sessions_monitored
FROM employee e
JOIN person per ON per.person_id = e.employee_id
LEFT JOIN monitors mn ON mn.employee_id = e.employee_id
LEFT JOIN session s ON s.session_id = mn.session_id
GROUP BY e.employee_id, per.first_name, per.last_name, s.show_date
ORDER BY s.show_date NULLS LAST, sessions_monitored DESC, employee_name;
