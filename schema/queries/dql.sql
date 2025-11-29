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
