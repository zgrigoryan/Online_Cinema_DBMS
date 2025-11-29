# Online_Cinema_DBMS

Spring Boot + Postgres + Flyway backend with a React/Vite frontend for an online cinema: movies, sessions, seat maps, reservations, promotions, payments (stub), reviews, and reports. Docker Compose can run both the DB and the app.

## Requirements
- Docker Desktop (for Postgres and optional app container)
- JDK 17 (Temurin/OpenJDK) if running the backend on host
- Node.js 20+ (for frontend dev) or run frontend via a Node container

## Backend
### Run everything in Docker (recommended)
```bash
docker compose -f docker/docker-compose.yml up --build app
```
- DB on internal network (`db:5432`), exposed host port 5433.
- Backend exposed at http://localhost:8080.

### Run DB in Docker, backend on host
```bash
# start Postgres on host port 5433
docker compose -f docker/docker-compose.yml up -d db

# ensure JDK 17 in PATH
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# run Spring Boot
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5433/cinema_app \
SPRING_DATASOURCE_USERNAME=cinema \
SPRING_DATASOURCE_PASSWORD=cinema123 \
./mvnw spring-boot:run
```

### Tests
- With local JDK 17:
  ```bash
  ./mvnw test
  ```
- In Docker (no local Java):
  ```bash
  docker run --rm \
    -v "$PWD":/workspace -w /workspace \
    -v /var/run/docker.sock:/var/run/docker.sock \
    maven:3.9.6-eclipse-temurin-17 ./mvnw test
  ```

## Frontend (React + Vite)
- Location: `frontend/`
- Dev: `cd frontend && npm install && npm run dev` (http://localhost:5173, proxies `/api` to http://localhost:8080)
- Build: `npm run build`
- Optional: run in Node container:
  ```bash
  docker run --rm -it -v "$PWD/frontend":/app -w /app -p 5173:5173 node:20 \
    bash -lc "npm install && npm run dev -- --host 0.0.0.0 --port 5173"
  ```

## Convenience scripts
- `./scripts/dev-backend.sh` — starts Postgres (port 5433) then runs Spring Boot on host.
- `./scripts/dev-frontend.sh` — installs frontend deps and starts Vite dev server on :5173.

## Architecture & Data
- Flyway migrations: `src/main/resources/db/migration` (`V1__initial_schema.sql`, seeds, bulk data).
- Reporting queries: `schema/queries/queries.sql`.
- Docker Compose services:
  - `db`: Postgres 15 (alpine), host port 5433.
  - `app`: builds and runs the Spring Boot app in Docker, exposed on 8080.

## API quickstart
- Auth: `POST /api/auth/register`, `POST /api/auth/login` → JWT.
- Movies: `GET /api/movies`
- Sessions: `GET /api/sessions?movieId=...`, `GET /api/sessions/{id}/seats`
- Reservations: `POST /api/reservations` (customer JWT), `POST /api/reservations/cancel/{id}`
- Reviews: `POST /api/reviews` (customer JWT)
- Promotions: `GET /api/promotions`, `GET /api/promotions/validate/{code}`
- Reports: `GET /api/reports/revenue/daily`, `GET /api/reports/occupancy`

## Notes
- Flyway migrations live in `src/main/resources/db/migration`.
- Test data seeds are in `V2__seed_data.sql`.
- REST entrypoints start under `/api/*` with JWT auth. Use `/api/auth/register` or `/api/auth/login` to obtain a token.


#### repo
- TicketRepository.java findByReservation_Session_Id, findByReservation_Customer_Id, findByReservation_Session, existsByReservation_SessionAndSeat
- SessionRepository.java findByMovie, findByMovieIdNullable, findOverlappingSessions 
- SeatRepository.java findByHall
- ReviewRepository.java findByCustomerAndMovie, averageRatingForMovie
- ReservationRepository.java existsByCustomer, findByCustomerOrderByReservationDateDesc
- PromotionRepository.java findActiveByCode
- PersonRepository.java findByEmail
- PaymentRepository.java revenueByDay, revenueByMovie, revenueBySession

#### CONTROLLER LAYER and funcitonality mapping 
1.  Customer sign-in is handled via `/api/auth/register` in `src\main\java\com\cinema\web\controller\AuthController.java` which delefates to `AuthService.refisterCustomer(...)` in `src\main\java\com\cinema\service\AuthService.java` (1.1 Specifies customer can update their info, not yet implemented)
2.   Browsing Movies and Sessions: Movies list: `src/main/java/com/cinema/web/controller/MovieController.java` → `GET /api/movies` returns all `Movie` records with their fields (title, genre, durationMinutes, description, movieRating, etc.). There’s no “currently available” filter yet.
Sessions per movie: `src/main/java/com/cinema/web/controller/SessionController.java` → `GET /api/sessions?movieId=...` uses `SessionRepository.findByMovieIdNullable` `(src/main/java/com/cinema/repository/SessionRepository.java)` to list sessions for a given movie (or all if no param).
3. Viewing seat map and availability: Implemented seat `map/availability` endpoint: `src/main/java/com/cinema/web/controller/SessionController.java` → `GET /api/sessions/{id}/seats` delegates to `SessionService.getSeatAvailability(...)`.
Logic for availability: `src/main/java/com/cinema/service/SessionService.java` fetches tickets for the session and seats for the hall; marks each seat as `BOOKED` if any ticket exists for that seat, otherwise `AVAILABLE`. It builds `SeatAvailability` DTOs (`src/main/java/com/cinema/web/dto/session/SeatAvailability.java`), using a r`owNumber-seatNumber` label and returning row/number/status.
4. Creating reservations and purchasing tickets: Main flow is in `src/main/java/com/cinema/web/controller/ReservationController.java` and implemented in `src/main/java/com/cinema/service/ReservationService.java` (method `createReservation`):
5. Reservation and ticket cancellation: `POST /api/reservations/cancel/{id}` (`ReservationController` → `ReservationService.cancelReservation`):
   - Confirms caller owns the reservation, sets `Reservation.status` to `CANCELLED`, increments `Session.available_seats`. Tickets aren’t separately marked; refunds/negative payments are not created yet.
6. Viewing purchase history: `GET /api/reservations/history` (`ReservationController` → `ReservationService.getHistory` → `ReservationRepository.findByCustomerOrderByReservationDateDesc`):
   - Returns reservations for the authenticated customer; ticket/hall/movie/promotion details are not currently expanded.
7. Writing reviews: `POST /api/reviews` (`ReviewController` → `ReviewService.addOrUpdateReview`):
   - Ensures the customer attended a past session for the movie (checks tickets by customer/movie/endTime).
   - Upserts a `Review` (rating/comment/review_date) and recalculates `Movie.movie_rating`. Delete/window restrictions are not implemented; only upsert is supported.

