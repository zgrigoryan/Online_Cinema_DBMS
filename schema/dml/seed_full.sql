INSERT INTO person (person_id, first_name, last_name, email, phone, password_hash) VALUES
(1,  'Anna',   'Martirosyan', 'anna1@example.com',  '+37411111111', 'hash1'),
(2,  'David',  'Petrosyan',   'david2@example.com', '+37411111112', 'hash2'),
(3,  'Mariam', 'Sargsyan',    'mariam3@example.com','+37411111113', 'hash3'),
(4,  'Arman',  'Harutyunyan', 'arman4@example.com', '+37411111114', 'hash4'),
(5,  'Narek',  'Hakobyan',    'narek5@example.com', '+37411111115', 'hash5'),
(6,  'Lilit',  'Khachatryan', 'lilit6@example.com', '+37411111116', 'hash6'),
(7,  'Sona',   'Azaryan',     'sona7@example.com',  '+37411111117', 'hash7'),
(8,  'Tigran', 'Galstyan',    'tigran8@example.com','+37411111118', 'hash8'),
(9,  'Hayk',   'Vardanyan',   'hayk9@example.com',  '+37411111119', 'hash9'),
(10, 'Ani',    'Karapetyan',  'ani10@example.com',  '+37411111120', 'hash10'),
(11, 'Gor',    'Melikyan',    'gor11@example.com',  '+37411111121', 'hash11'),
(12, 'Lusine', 'Hovhannisyan','lusine12@example.com','+37411111122','hash12'),
(13, 'Arman',  'Grigoryan',   'armang13@example.com','+37411111123','hash13'),
(14, 'Suren',  'Avetisyan',   'suren14@example.com','+37411111124','hash14'),
(15, 'Karen',  'Kocharyan',   'karen15@example.com','+37411111125','hash15'),
(16, 'Nune',   'Simonyan',    'nune16@example.com', '+37411111126','hash16'),
(17, 'Mher',   'Babayan',     'mher17@example.com', '+37411111127','hash17'),
(18, 'Rita',   'Avagyan',     'rita18@example.com', '+37411111128','hash18'),
(19, 'Vahan',  'Stepanyan',   'vahan19@example.com','+37411111129','hash19'),
(20, 'Eva',    'Sahakyan',    'eva20@example.com',  '+37411111130','hash20');

INSERT INTO customer (customer_id, membership_status, registration_date) VALUES
(1,  'ACTIVE',   '2024-01-10 10:00:00'),
(2,  'ACTIVE',   '2024-01-15 15:30:00'),
(3,  'ACTIVE',   '2024-02-01 12:00:00'),
(4,  'INACTIVE', '2024-02-10 09:00:00'),
(5,  'ACTIVE',   '2024-02-20 11:00:00'),
(6,  'ACTIVE',   '2024-03-01 13:00:00'),
(7,  'SUSPENDED','2024-03-10 16:00:00'),
(8,  'ACTIVE',   '2024-03-20 18:00:00'),
(9,  'ACTIVE',   '2024-04-01 14:00:00'),
(10, 'ACTIVE',   '2024-04-05 17:00:00'),
(11, 'INACTIVE', '2024-04-10 19:00:00'),
(12, 'ACTIVE',   '2024-04-15 20:00:00');

INSERT INTO employee (employee_id, position, salary, works_for_id) VALUES
(13, 'General Manager', 750000.00, NULL),
(14, 'Hall Manager',    550000.00, 13),
(15, 'Hall Manager',    550000.00, 13),
(16, 'Cashier',         350000.00, 14),
(17, 'Cashier',         350000.00, 14),
(18, 'Projectionist',   380000.00, 15),
(19, 'Usher',           300000.00, 15),
(20, 'Usher',           300000.00, 15);

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
(10, 'La La Land', 'A jazz musician and actress fall in love.',       'Musical',    128, '2016-12-09', 8.00),
(11, 'The Shawshank Redemption','Two imprisoned men bond over years.','Drama',     142, '1994-09-23', 9.30),
(12, 'Fight Club', 'An office worker finds meaning in violence.',     'Drama',      139, '1999-10-15', 8.80),
(13, 'The Lion King', 'A lion cub becomes king.',                     'Animation',   88, '1994-06-24', 8.50),
(14, 'Spirited Away', 'A girl trapped in a magical bathhouse.',       'Animation',  125, '2001-07-20', 8.60),
(15, 'Toy Story', 'Toys come to life when humans are not around.',    'Animation',   81, '1995-11-22', 8.30);

INSERT INTO cinema_hall (hall_id, name, capacity, type) VALUES
(1, 'Hall 1', 120, 'REGULAR'),
(2, 'Hall 2', 80,  'VIP'),
(3, 'Hall 3', 60,  'REGULAR');

INSERT INTO seat (seat_id, hall_id, row_number, seat_number, base_price, category) VALUES
-- Hall 1 (Standard)
(1, 1, 1, 1, 5000.00, 'Standard'),
(2, 1, 1, 2, 5000.00, 'Standard'),
(3, 1, 1, 3, 5000.00, 'Standard'),
(4, 1, 1, 4, 5000.00, 'Standard'),
(5, 1, 1, 5, 5000.00, 'Standard'),
(6, 1, 2, 1, 5000.00, 'Standard'),
(7, 1, 2, 2, 5000.00, 'Standard'),
(8, 1, 2, 3, 5000.00, 'Standard'),
(9, 1, 2, 4, 5000.00, 'Standard'),
(10,1, 2, 5, 5000.00, 'Standard'),

-- Hall 2 (VIP)
(11,2, 1, 1, 8000.00, 'VIP'),
(12,2, 1, 2, 8000.00, 'VIP'),
(13,2, 1, 3, 8000.00, 'VIP'),
(14,2, 1, 4, 8000.00, 'VIP'),
(15,2, 1, 5, 8000.00, 'VIP'),
(16,2, 2, 1, 8000.00, 'VIP'),
(17,2, 2, 2, 8000.00, 'VIP'),
(18,2, 2, 3, 8000.00, 'VIP'),
(19,2, 2, 4, 8000.00, 'VIP'),
(20,2, 2, 5, 8000.00, 'VIP'),

-- Hall 3 (Standard)
(21,3, 1, 1, 4500.00, 'Standard'),
(22,3, 1, 2, 4500.00, 'Standard'),
(23,3, 1, 3, 4500.00, 'Standard'),
(24,3, 1, 4, 4500.00, 'Standard'),
(25,3, 1, 5, 4500.00, 'Standard'),
(26,3, 2, 1, 4500.00, 'Standard'),
(27,3, 2, 2, 4500.00, 'Standard'),
(28,3, 2, 3, 4500.00, 'Standard'),
(29,3, 2, 4, 4500.00, 'Standard'),
(30,3, 2, 5, 4500.00, 'Standard');

INSERT INTO promotion (promotion_id, code, discount_amount, start_date, end_date) VALUES
(1, 'SPRING10', 10.00, '2024-03-01 00:00:00', '2024-04-30 23:59:59'),
(2, 'WEEKEND15',15.00, '2024-05-01 00:00:00', '2024-06-30 23:59:59'),
(3, 'STUDENT5', 5.00,  '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
(4, 'VIP20',    20.00, '2024-07-01 00:00:00', '2024-12-31 23:59:59');

INSERT INTO session (session_id, movie_id, hall_id, start_time, end_time, available_seats, show_date, session_price) VALUES
-- Hall 1
(1, 1, 1, '2024-12-20 10:00:00', '2024-12-20 12:30:00', 120, '2024-12-20', 6000.00),
(2, 2, 1, '2024-12-20 13:00:00', '2024-12-20 15:30:00', 120, '2024-12-20', 6000.00),
(3, 3, 1, '2024-12-20 16:00:00', '2024-12-20 18:30:00', 120, '2024-12-20', 6500.00),

-- Hall 2
(4, 4, 2, '2024-12-20 09:30:00', '2024-12-20 12:00:00', 80, '2024-12-20', 9000.00),
(5, 5, 2, '2024-12-20 12:30:00', '2024-12-20 15:00:00', 80, '2024-12-20', 9000.00),
(6, 6, 2, '2024-12-20 15:30:00', '2024-12-20 18:00:00', 80, '2024-12-20', 9500.00),

-- Hall 3
(7, 7, 3, '2024-12-20 10:15:00', '2024-12-20 12:30:00', 60, '2024-12-20', 5500.00),
(8, 8, 3, '2024-12-20 13:00:00', '2024-12-20 15:15:00', 60, '2024-12-20', 5500.00),
(9, 9, 3, '2024-12-20 15:45:00', '2024-12-20 18:00:00', 60, '2024-12-20', 6000.00);

INSERT INTO payment (payment_id, promotion_id, final_amount, payment_method, payment_date) VALUES
(1,  1, 12000.00, 'CARD',  '2024-12-01 10:00:00'),
(2,  NULL, 6000.00, 'CASH', '2024-12-01 11:00:00'),
(3,  2, 15300.00, 'CARD',  '2024-12-01 12:00:00'),
(4,  3, 5500.00,  'ONLINE','2024-12-01 13:00:00'),
(5,  NULL, 9000.00,'CARD', '2024-12-02 10:00:00'),
(6,  1, 11000.00, 'ONLINE','2024-12-02 11:30:00'),
(7,  4, 18000.00, 'CARD',  '2024-12-02 12:30:00'),
(8,  NULL, 6000.00,'CASH', '2024-12-02 14:00:00'),
(9,  3, 5800.00,  'ONLINE','2024-12-03 10:00:00'),
(10, NULL, 6500.00,'CARD', '2024-12-03 11:00:00'),
(11, 2, 18000.00, 'CARD',  '2024-12-03 12:30:00'),
(12, NULL, 5500.00,'CASH', '2024-12-03 14:30:00'),
(13, 1, 12000.00,'CARD',   '2024-12-04 10:00:00'),
(14, NULL, 9000.00,'CARD', '2024-12-04 11:00:00'),
(15, 4, 19000.00,'ONLINE', '2024-12-04 12:00:00'),
(16, 3, 5800.00, 'CARD',   '2024-12-04 13:00:00'),
(17, NULL, 6000.00,'CASH', '2024-12-05 10:00:00'),
(18, 1, 11500.00,'CARD',   '2024-12-05 11:00:00'),
(19, 2, 14000.00,'ONLINE', '2024-12-05 12:00:00'),
(20, NULL, 5500.00,'CASH', '2024-12-05 13:00:00');

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
(11,11, 6, 11,  'CONFIRMED', 19000.00, '2024-12-01 09:00:00'),
(12,12, 6, 12,  'CANCELLED', 5500.00,  '2024-12-01 10:00:00'),
(13,1,  7, 13,  'CONFIRMED', 12000.00, '2024-12-01 11:00:00'),
(14,2,  7, 14,  'CONFIRMED', 9000.00,  '2024-12-01 12:00:00'),
(15,3,  8, 15,  'CONFIRMED', 20000.00, '2024-12-01 13:00:00'),
(16,4,  8, 16,  'PENDING',   5800.00,  '2024-12-01 14:00:00'),
(17,5,  9, 17,  'CONFIRMED', 6000.00,  '2024-12-01 15:00:00'),
(18,6,  9, 18,  'CONFIRMED', 11500.00, '2024-12-01 16:00:00'),
(19,7,  1, 19,  'CONFIRMED', 14000.00, '2024-12-01 17:00:00'),
(20,8,  2, 20,  'CONFIRMED', 5500.00,  '2024-12-01 18:00:00');

INSERT INTO ticket (reservation_id, ticket_number, seat_id, ticket_price, purchase_date) VALUES
-- Reservation 1 (Session 1 -> Hall 1, seats 1 & 2)
(1, 1, 1, 6000.00, '2024-11-30 09:05:00'),
(1, 2, 2, 6000.00, '2024-11-30 09:05:00'),

-- Reservation 2 (Session 1 -> Hall 1)
(2, 1, 3, 6000.00, '2024-11-30 10:05:00'),

-- Reservation 3 (Session 2 -> Hall 1, two tickets)
(3, 1, 4, 8500.00, '2024-11-30 11:05:00'),
(3, 2, 5, 8500.00, '2024-11-30 11:05:00'),

-- Reservation 4 (Session 2)
(4, 1, 6, 5500.00, '2024-11-30 12:05:00'),

-- Reservation 5 (Session 3)
(5, 1, 7, 9000.00, '2024-11-30 13:05:00'),

-- Reservation 6 (Session 3, two seats)
(6, 1, 8, 6000.00, '2024-11-30 14:05:00'),
(6, 2, 9, 6000.00, '2024-11-30 14:05:00'),

-- Reservation 7 (Session 4 -> Hall 2, VIP seats 11,12)
(7, 1, 11, 10000.00, '2024-11-30 15:05:00'),
(7, 2, 12, 10000.00, '2024-11-30 15:05:00'),

-- Reservation 8 (Session 4)
(8, 1, 13, 6000.00, '2024-11-30 16:05:00'),

-- Reservation 9 (Session 5)
(9, 1, 14, 5800.00, '2024-11-30 17:05:00'),

-- Reservation 10 (Session 5)
(10, 1, 15, 6500.00, '2024-11-30 18:05:00'),

-- Reservation 11 (Session 6, two VIP seats)
(11, 1, 16, 9500.00, '2024-12-01 09:05:00'),
(11, 2, 17, 9500.00, '2024-12-01 09:05:00'),

-- Reservation 12 (Session 6)
(12, 1, 18, 5500.00, '2024-12-01 10:05:00'),

-- Reservation 13 (Session 7 -> Hall 3)
(13, 1, 21, 6000.00, '2024-12-01 11:05:00'),
(13, 2, 22, 6000.00, '2024-12-01 11:05:00'),

-- Reservation 14 (Session 7)
(14, 1, 23, 9000.00, '2024-12-01 12:05:00'),

-- Reservation 15 (Session 8)
(15, 1, 24, 10000.00,'2024-12-01 13:05:00'),
(15, 2, 25, 10000.00,'2024-12-01 13:05:00'),

-- Reservation 16 (Session 8)
(16, 1, 26, 5800.00, '2024-12-01 14:05:00'),

-- Reservation 17 (Session 9)
(17, 1, 27, 6000.00, '2024-12-01 15:05:00'),

-- Reservation 18 (Session 9)
(18, 1, 28, 5500.00, '2024-12-01 16:05:00'),

-- Reservation 19 (Session 1)
(19, 1, 10, 7000.00,'2024-12-01 17:05:00'),

-- Reservation 20 (Session 2)
(20, 1, 19, 5500.00,'2024-12-01 18:05:00');

INSERT INTO review (review_id, customer_id, movie_id, rating, comment, review_date) VALUES
(1, 1, 1, 5, 'Amazing sci-fi!',     '2024-12-21'),
(2, 2, 1, 4, 'Very good.',          '2024-12-21'),
(3, 3, 2, 5, 'Best Batman movie.',  '2024-12-21'),
(4, 4, 3, 4, 'Great visuals.',      '2024-12-21'),
(5, 5, 4, 4, 'Emotional.',          '2024-12-21'),
(6, 6, 5, 4, 'Loved Pandora.',      '2024-12-21'),
(7, 7, 6, 5, 'Classic masterpiece.', '2024-12-21'),
(8, 8, 7, 4, 'Very stylish.',       '2024-12-21'),
(9, 9, 8, 5, 'Mind-blowing.',       '2024-12-21'),
(10,10,9, 5, 'Deserved the Oscar.', '2024-12-21'),
(11,1, 10,4, 'Nice musical.',       '2024-12-22'),
(12,2, 11,5, 'My favorite movie.',  '2024-12-22'),
(13,3, 12,4, 'Interesting story.',  '2024-12-22'),
(14,4, 13,5, 'Childhood classic.',  '2024-12-22'),
(15,5, 14,5, 'Beautiful animation.', '2024-12-22'),
(16,6, 15,4, 'Fun family film.',    '2024-12-22'),
(17,7, 2, 4, 'Great Joker.',        '2024-12-23'),
(18,8, 3, 5, 'Loved it.',           '2024-12-23'),
(19,9, 4, 4, 'Very moving.',        '2024-12-23'),
(20,10,5, 4, 'Nice visuals.',       '2024-12-23');

INSERT INTO works_on (person_id, movie_id, role, biography) VALUES
(13, 1, 'DIRECTOR', 'Christopher Nolan-like director.'),
(13, 2, 'DIRECTOR', 'Same director for The Dark Knight.'),
(13, 3, 'DIRECTOR', 'Also directed Interstellar.'),
(14, 4, 'DIRECTOR', 'Inspired by James Cameron.'),
(15, 5, 'DIRECTOR', 'Sci-fi visionary.'),
(16, 6, 'DIRECTOR', 'Crime film director.'),
(17, 7, 'DIRECTOR', 'Non-linear storytelling.'),
(18, 8, 'DIRECTOR', 'Sci-fi action director.'),
(19, 9, 'DIRECTOR', 'Korean director.'),
(20,10, 'DIRECTOR', 'Musical film director.'),

(1,  1, 'ACTOR', 'Lead dream thief.'),
(2,  1, 'ACTOR', 'Partner in the heist.'),
(3,  2, 'ACTOR', 'Plays the Joker-like villain.'),
(4,  2, 'ACTOR', 'Plays Batman-like hero.'),
(5,  3, 'ACTOR', 'Space explorer protagonist.'),
(6,  4, 'ACTOR', 'Romantic lead.'),
(7,  5, 'ACTOR', 'Avatar main character.'),
(8,  8, 'ACTOR', 'Chosen one in the Matrix.'),
(9,  9, 'ACTOR', 'Poor family father.'),
(10,10,'ACTOR', 'Jazz musician.'),
(11,11,'ACTOR', 'Banker in prison.'),
(12,12,'ACTOR', 'Tyler-like character.'),

(14,13,'PRODUCER', 'Animation producer.'),
(15,14,'PRODUCER', 'Anime producer.'),
(16,15,'PRODUCER', 'Pixar-style producer.'),
(17,6, 'WRITER',   'Crime story writer.'),
(18,7, 'WRITER',   'Non-linear script writer.'),
(19,8, 'WRITER',   'Sci-fi script writer.'),
(20,9, 'WRITER',   'Thriller script writer.');

INSERT INTO monitors (employee_id, session_id) VALUES
(18,1), (18,2), (18,3),
(19,4), (19,5),
(20,6),
(16,7), (16,8),
(17,9),
(14,1), (14,4), (14,7),
(15,2), (15,5), (15,8);

INSERT INTO manages (employee_id, hall_id) VALUES
(14,1),
(15,2),
(13,3);
