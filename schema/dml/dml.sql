-- ================
-- PERSON (20 rows)
-- ================
INSERT INTO person (person_id, first_name, last_name, email, phone, password_hash) VALUES
(1,  'Anna',   'Martirosyan', 'anna1@example.com',   '+37411111111', 'hash1'),
(2,  'David',  'Petrosyan',   'david2@example.com',  '+37411111112', 'hash2'),
(3,  'Mariam', 'Sargsyan',    'mariam3@example.com', '+37411111113', 'hash3'),
(4,  'Arman',  'Harutyunyan', 'arman4@example.com',  '+37411111114', 'hash4'),
(5,  'Narek',  'Hakobyan',    'narek5@example.com',  '+37411111115', 'hash5'),
(6,  'Lilit',  'Khachatryan', 'lilit6@example.com',  '+37411111116', 'hash6'),
(7,  'Sona',   'Azaryan',     'sona7@example.com',   '+37411111117', 'hash7'),
(8,  'Tigran', 'Galstyan',    'tigran8@example.com', '+37411111118', 'hash8'),
(9,  'Hayk',   'Vardanyan',   'hayk9@example.com',   '+37411111119', 'hash9'),
(10, 'Ani',    'Karapetyan',  'ani10@example.com',   '+37411111120', 'hash10'),
(11, 'Gor',    'Melikyan',    'gor11@example.com',   '+37411111121', 'hash11'),
(12, 'Lusine', 'Hovhannisyan','lusine12@example.com','+37411111122', 'hash12'),
(13, 'Arman',  'Grigoryan',   'armang13@example.com','+37411111123', 'hash13'),
(14, 'Suren',  'Avetisyan',   'suren14@example.com', '+37411111124', 'hash14'),
(15, 'Karen',  'Kocharyan',   'karen15@example.com', '+37411111125', 'hash15'),
(16, 'Nune',   'Simonyan',    'nune16@example.com',  '+37411111126', 'hash16'),
(17, 'Mher',   'Babayan',     'mher17@example.com',  '+37411111127', 'hash17'),
(18, 'Rita',   'Avagyan',     'rita18@example.com',  '+37411111128', 'hash18'),
(19, 'Vahan',  'Stepanyan',   'vahan19@example.com', '+37411111129', 'hash19'),
(20, 'Eva',    'Sahakyan',    'eva20@example.com',   '+37411111130', 'hash20');

-- =================
-- CUSTOMERS (10)
-- =================
INSERT INTO customer (customer_id, membership_status, registration_date) VALUES
(1,  'REGULAR',  '2024-01-10 10:00:00'),
(2,  'SILVER',   '2024-01-15 15:30:00'),
(3,  'GOLD',     '2024-02-01 12:00:00'),
(4,  'PLATINUM', '2024-02-10 09:00:00'),
(5,  'REGULAR',  '2024-02-20 11:00:00'),
(6,  'SILVER',   '2024-03-01 13:00:00'),
(7,  'GOLD',     '2024-03-10 16:00:00'),
(8,  'PLATINUM', '2024-03-20 18:00:00'),
(9,  'REGULAR',  '2024-04-01 14:00:00'),
(10, 'SILVER',   '2024-04-05 17:00:00');

-- =================
-- EMPLOYEES (10)
-- =================
INSERT INTO employee (employee_id, position, salary, works_for_id) VALUES
(11, 'General Manager', 750000.00, NULL),
(12, 'Hall Manager',    550000.00, 11),
(13, 'Hall Manager',    550000.00, 11),
(14, 'Cashier',         350000.00, 12),
(15, 'Cashier',         350000.00, 12),
(16, 'Projectionist',   380000.00, 13),
(17, 'Usher',           300000.00, 13),
(18, 'Usher',           300000.00, 13),
(19, 'Technician',      400000.00, 11),
(20, 'Cleaner',         280000.00, 13);

-- ================
-- CINEMA HALLS (3)
-- ================
INSERT INTO cinema_hall (hall_id, name, capacity, type) VALUES
(1, 'Hall 1', 120, 'REGULAR'),
(2, 'Hall 2',  80, 'VIP'),
(3, 'Hall 3',  60, 'REGULAR');

-- ======================================
-- SEATS (3 halls × 10 seats = 30 rows)
-- ======================================
INSERT INTO seat (hall_id, row_number, seat_number, base_price, category)
VALUES
-- Hall 1 (Standard)
(1, 1, 1, 5000.00, 'Standard'),
(1, 1, 2, 5000.00, 'Standard'),
(1, 1, 3, 5000.00, 'Standard'),
(1, 1, 4, 5000.00, 'Standard'),
(1, 1, 5, 5000.00, 'Standard'),
(1, 2, 1, 5000.00, 'Standard'),
(1, 2, 2, 5000.00, 'Standard'),
(1, 2, 3, 5000.00, 'Standard'),
(1, 2, 4, 5000.00, 'Standard'),
(1, 2, 5, 5000.00, 'Standard'),

-- Hall 2 (VIP)
(2, 1, 1, 8000.00, 'VIP'),
(2, 1, 2, 8000.00, 'VIP'),
(2, 1, 3, 8000.00, 'VIP'),
(2, 1, 4, 8000.00, 'VIP'),
(2, 1, 5, 8000.00, 'VIP'),
(2, 2, 1, 8000.00, 'VIP'),
(2, 2, 2, 8000.00, 'VIP'),
(2, 2, 3, 8000.00, 'VIP'),
(2, 2, 4, 8000.00, 'VIP'),
(2, 2, 5, 8000.00, 'VIP'),

-- Hall 3 (Standard)
(3, 1, 1, 4500.00, 'Standard'),
(3, 1, 2, 4500.00, 'Standard'),
(3, 1, 3, 4500.00, 'Standard'),
(3, 1, 4, 4500.00, 'Standard'),
(3, 1, 5, 4500.00, 'Standard'),
(3, 2, 1, 4500.00, 'Standard'),
(3, 2, 2, 4500.00, 'Standard'),
(3, 2, 3, 4500.00, 'Standard'),
(3, 2, 4, 4500.00, 'Standard'),
(3, 2, 5, 4500.00, 'Standard');

-- ==================
-- PROMOTIONS (4 rows)
-- ==================
INSERT INTO promotion (promotion_id, code, discount_amount, start_date, end_date) VALUES
(1, 'SPRING10', 10.00, '2024-03-01 00:00:00', '2024-04-30 23:59:59'),
(2, 'WEEKEND15',15.00, '2024-05-01 00:00:00', '2024-06-30 23:59:59'),
(3, 'STUDENT5', 5.00,  '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
(4, 'VIP20',    20.00, '2024-07-01 00:00:00', '2024-12-31 23:59:59');

-- ======================
-- SOME HAND-WRITTEN MOVIES
-- ======================
INSERT INTO movie (movie_id, title, description, genre, duration, release_year, movie_rating) VALUES
(1,  'Inception', 'A thief enters people''s dreams to steal secrets.', 'Sci-Fi',     148, '2010-07-16', 8.80),
(2,  'The Dark Knight', 'Batman faces the Joker in Gotham.',          'Action',     152, '2008-07-18', 9.00),
(3,  'Interstellar', 'Explorers travel through a wormhole in space.', 'Sci-Fi',     169, '2014-11-07', 8.60),
(4,  'Titanic', 'A romance aboard the doomed ocean liner.',           'Romance',    195, '1997-12-19', 7.80),
(5,  'Avatar', 'Humans colonize Pandora, a lush alien world.',        'Sci-Fi',     162, '2009-12-18', 7.80),
(6,  'The Godfather', 'The story of the Corleone crime family.',      'Crime',      175, '1972-03-24', 9.20),
(7,  'Pulp Fiction', 'Interwoven tales of crime in Los Angeles.',     'Crime',      154, '1994-10-14', 8.90),
(8,  'The Matrix', 'A hacker discovers reality is a simulation.',     'Sci-Fi',     136, '1999-03-31', 8.70),
(9,  'Parasite', 'A poor family infiltrates a wealthy household.',    'Thriller',   132, '2019-05-30', 8.60),
(10, 'La La Land', 'A jazz musician and actress fall in love.',       'Musical',    128, '2016-12-09', 8.00);

-- ==========================================
-- SYNTHETIC MOVIES: IDs 11..250 (240 rows)
-- ==========================================
INSERT INTO movie (movie_id, title, description, genre, duration, release_year, movie_rating)
SELECT
    i AS movie_id,
    'Movie ' || i AS title,
    'Automatically generated description for movie ' || i AS description,
    CASE (i % 6)
        WHEN 0 THEN 'Action'
        WHEN 1 THEN 'Drama'
        WHEN 2 THEN 'Comedy'
        WHEN 3 THEN 'Sci-Fi'
        WHEN 4 THEN 'Romance'
        ELSE 'Animation'
    END AS genre,
    85 + (i % 50) AS duration,
    make_date(1980 + (i % 40), 1, 1) AS release_year,
    5.0 + (i % 45) * 0.1 AS movie_rating
FROM generate_series(11, 250) AS i;


-- ======================
-- SESSIONS (9 rows)
-- ======================
INSERT INTO session (session_id, movie_id, hall_id, start_time, end_time, available_seats, show_date, session_price) VALUES
-- Hall 1
(1,  1, 1, '2024-12-20 10:00:00', '2024-12-20 12:30:00', 120, '2024-12-20', 6000.00),
(2,  2, 1, '2024-12-20 13:00:00', '2024-12-20 15:30:00', 120, '2024-12-20', 6000.00),
(3,  3, 1, '2024-12-20 16:00:00', '2024-12-20 18:30:00', 120, '2024-12-20', 6500.00),

-- Hall 2
(4,  4, 2, '2024-12-20 09:30:00', '2024-12-20 12:00:00', 80, '2024-12-20', 9000.00),
(5,  5, 2, '2024-12-20 12:30:00', '2024-12-20 15:00:00', 80, '2024-12-20', 9000.00),
(6,  6, 2, '2024-12-20 15:30:00', '2024-12-20 18:00:00', 80, '2024-12-20', 9500.00),

-- Hall 3
(7,  7, 3, '2024-12-20 10:15:00', '2024-12-20 12:30:00', 60, '2024-12-20', 5500.00),
(8,  8, 3, '2024-12-20 13:00:00', '2024-12-20 15:15:00', 60, '2024-12-20', 5500.00),
(9,  9, 3, '2024-12-20 15:45:00', '2024-12-20 18:00:00', 60, '2024-12-20', 6000.00);


-- =====================
-- PAYMENTS (10 rows)
-- =====================
INSERT INTO payment (payment_id, promotion_id, final_amount, payment_method, payment_date) VALUES
(1,  1, 12000.00, 'CREDIT_CARD', '2024-12-01 10:00:00'),
(2,  NULL, 6000.00, 'CASH',       '2024-12-01 11:00:00'),
(3,  2, 15300.00, 'DEBIT_CARD',   '2024-12-01 12:00:00'),
(4,  3, 5500.00,  'PAYPAL',       '2024-12-01 13:00:00'),
(5,  NULL, 9000.00,'CREDIT_CARD', '2024-12-02 10:00:00'),
(6,  1, 11000.00, 'PAYPAL',       '2024-12-02 11:30:00'),
(7,  4, 18000.00, 'CREDIT_CARD',  '2024-12-02 12:30:00'),
(8,  NULL, 6000.00,'CASH',        '2024-12-02 14:00:00'),
(9,  3, 5800.00,  'DEBIT_CARD',   '2024-12-03 10:00:00'),
(10, NULL, 6500.00,'CASH',        '2024-12-03 11:00:00');


-- ===========================
-- RESERVATIONS (12 rows)
-- ===========================
INSERT INTO reservation (reservation_id, customer_id, session_id, payment_id, status, total_amount, reservation_date) VALUES
(1,  1, 1,  1,  'CONFIRMED', 12000.00, '2024-11-30 09:00:00'),
(2,  2, 1,  2,  'CONFIRMED', 6000.00,  '2024-11-30 10:00:00'),
(3,  3, 2,  3,  'CONFIRMED', 17000.00, '2024-11-30 11:00:00'),
(4,  4, 2,  4,  'PENDING',   5500.00,  '2024-11-30 12:00:00'),
(5,  5, 3,  5,  'CONFIRMED', 9000.00,  '2024-11-30 13:00:00'),
(6,  6, 3,  6,  'CONFIRMED', 12000.00, '2024-11-30 14:00:00'),
(7,  7, 4,  7,  'CONFIRMED', 20000.00, '2024-11-30 15:00:00'),
(8,  8, 4,  8,  'PENDING',   6000.00,  '2024-11-30 16:00:00'),
(9,  9, 5,  9,  'CONFIRMED', 5800.00,  '2024-11-30 17:00:00'),
(10,10, 5, 10,  'CONFIRMED', 6500.00,  '2024-11-30 18:00:00'),
(11,1,  6, NULL,'PENDING',   9500.00,  '2024-11-30 19:00:00'),
(12,2,  7, NULL,'CANCELLED', 6000.00,  '2024-11-30 20:00:00');

-- ===========================
-- TICKETS
-- ===========================
INSERT INTO ticket (reservation_id, ticket_number, seat_id, ticket_price, purchase_date) VALUES
-- Reservation 1, Session 1 -> Hall 1
(1, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 1 AND seat_number = 1),
   6000.00, '2024-11-30 09:05:00'),
(1, 2,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 1 AND seat_number = 2),
   6000.00, '2024-11-30 09:05:00'),

-- Reservation 2, Session 1 -> Hall 1
(2, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 1 AND seat_number = 3),
   6000.00, '2024-11-30 10:05:00'),

-- Reservation 3, Session 2 -> Hall 1
(3, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 1 AND seat_number = 4),
   8500.00, '2024-11-30 11:05:00'),
(3, 2,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 1 AND seat_number = 5),
   8500.00, '2024-11-30 11:05:00'),

-- Reservation 4, Session 2
(4, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 2 AND seat_number = 1),
   5500.00, '2024-11-30 12:05:00'),

-- Reservation 5, Session 3
(5, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 2 AND seat_number = 2),
   9000.00, '2024-11-30 13:05:00'),

-- Reservation 6, Session 3
(6, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 1 AND row_number = 2 AND seat_number = 3),
   6000.00, '2024-11-30 14:05:00'),

-- Reservation 7, Session 4 -> Hall 2 (VIP)
(7, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 2 AND row_number = 1 AND seat_number = 1),
   10000.00, '2024-11-30 15:05:00'),
(7, 2,
   (SELECT seat_id FROM seat WHERE hall_id = 2 AND row_number = 1 AND seat_number = 2),
   10000.00, '2024-11-30 15:05:00'),

-- Reservation 8, Session 4
(8, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 2 AND row_number = 1 AND seat_number = 3),
   6000.00, '2024-11-30 16:05:00'),

-- Reservation 9, Session 5
(9, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 2 AND row_number = 1 AND seat_number = 4),
   5800.00, '2024-11-30 17:05:00'),

-- Reservation 10, Session 5
(10, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 2 AND row_number = 1 AND seat_number = 5),
   6500.00, '2024-11-30 18:05:00'),

-- Reservation 11, Session 6
(11, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 2 AND row_number = 2 AND seat_number = 1),
   9500.00, '2024-12-01 09:05:00'),

-- Reservation 12, Session 7 -> Hall 3
(12, 1,
   (SELECT seat_id FROM seat WHERE hall_id = 3 AND row_number = 1 AND seat_number = 1),
   6000.00, '2024-12-01 10:05:00');


-- =======================
-- REVIEWS (60 rows)
-- =======================
WITH c AS (
    SELECT customer_id, row_number() OVER (ORDER BY customer_id) AS r
    FROM customer
),
m AS (
    SELECT movie_id, row_number() OVER (ORDER BY movie_id) AS r
    FROM movie
    WHERE movie_id <= 60
),
pairs AS (
    SELECT
        c.customer_id,
        m.movie_id,
        ((m.r - 1) % 5) + 1 AS rating,
        format('Customer %s review for movie %s', c.r, m.r) AS comment,
        row_number() OVER () AS rn
    FROM c
    CROSS JOIN m
)
INSERT INTO review (customer_id, movie_id, rating, comment)
SELECT customer_id, movie_id, rating, comment
FROM pairs
WHERE rn <= 60;

-- =========================
-- works_on (sample entries)
-- =========================
INSERT INTO works_on (person_id, movie_id, role, biography) VALUES
(11, 1, 'DIRECTOR', 'Director of Inception-like movie.'),
(11, 2, 'DIRECTOR', 'Also directed The Dark Knight-like movie.'),
(12, 3, 'DIRECTOR', 'Sci-fi epic director.'),
(13, 4, 'DIRECTOR', 'Romantic drama director.'),
(14, 5, 'DIRECTOR', 'Sci-fi blockbuster director.'),
(15, 6, 'DIRECTOR', 'Crime saga director.'),
(16, 7, 'DIRECTOR', 'Non-linear crime director.'),
(17, 8, 'DIRECTOR', 'Sci-fi action director.'),
(18, 9, 'DIRECTOR', 'Korean thriller director.'),
(19,10, 'DIRECTOR', 'Musical director.'),

(1,  1, 'ACTOR', 'Lead dream thief.'),
(2,  1, 'ACTOR', 'Partner in the heist.'),
(3,  2, 'ACTOR', 'Villain character.'),
(4,  2, 'ACTOR', 'Vigilante hero.'),
(5,  3, 'ACTOR', 'Space explorer.'),
(6,  4, 'ACTOR', 'Romantic lead.'),
(7,  5, 'ACTOR', 'Avatar main character.'),
(8,  8, 'ACTOR', 'Chosen one in the Matrix.'),
(9,  9, 'ACTOR', 'Poor family father.'),
(10,10,'ACTOR', 'Jazz musician character.');

-- =========================
-- monitors (sample entries)
-- =========================
INSERT INTO monitors (employee_id, session_id) VALUES
(16,1), (16,2), (16,3),
(17,4), (17,5),
(18,6),
(14,7), (14,8),
(15,9);

-- =========================
-- manages (sample entries)
-- =========================
INSERT INTO manages (employee_id, hall_id) VALUES
(12,1),
(13,2),
(11,3);
