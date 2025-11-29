# CinemaFlow

CinemaFlow is a full-stack cinema management app: list movies, schedule sessions, price and pick seats, reserve and purchase tickets, apply promotions, leave reviews, and view operational reports. The backend is Spring Boot + PostgreSQL + Flyway; the frontend is React + Vite. Docker Compose runs the backend and database; the frontend runs via Vite dev server.

## Requirements
- Docker Desktop (for Postgres and backend container)
- JDK 17 (Temurin/OpenJDK) if running backend on host
- Node.js 20+ for frontend dev
- Maven Wrapper included (`./mvnw`), no global Maven needed

## Backend
### Run with Docker (recommended)
```bash
docker compose -f docker/docker-compose.yml up --build app
```
- DB: host port 5433, container name `cinema_db`.
- Backend: http://localhost:8080.

### Run DB in Docker, backend on host
```bash
docker compose -f docker/docker-compose.yml up -d db

SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5433/cinema_app \
SPRING_DATASOURCE_USERNAME=cinema \
SPRING_DATASOURCE_PASSWORD=cinema123 \
./mvnw spring-boot:run
```

### Migrations & data
- Flyway migrations live in `src/main/resources/db/migration` (V1–V8). V7 rebuilds schema from `schema/ddl/ddl.sql` + `schema/dml/dml.sql`; V8 imports extra movies from the CSV in `schema/dml`.
- Reports SQL reference: `schema/queries/dql.sql`.

### Tests
Automated tests are **not implemented**. CI builds run without tests.

## Frontend (React + Vite)
- Location: `frontend/`
- Dev: `cd frontend && npm install && npm run dev` (http://localhost:5173, proxies `/api` to http://localhost:8080)
- Build: `npm run build`

## API quickstart (examples)
- Auth: `POST /api/auth/register`, `POST /api/auth/login` → JWT.
- Movies: `GET /api/movies`
- Sessions: `GET /api/sessions?movieId=...`, `GET /api/sessions/{id}/seats`
- Reservations: `POST /api/reservations`, `POST /api/reservations/{id}/purchase`, `POST /api/reservations/cancel/{id}`, `GET /api/reservations/history`
- Reviews: `POST /api/reviews`, `DELETE /api/reviews/{id}`
- Promotions: `GET /api/promotions`, `GET /api/promotions/validate/{code}`
- Reports: revenue daily (`/api/reports/revenue/daily`), custom period (`/api/reports/revenue/period`), by movie/session, top customers, promotion effectiveness, movie performance, employee workload, cancellations, occupancy (`/api/reports/occupancy`)

## Feature map (controller highlights)
1. Auth & profile: `/api/auth/register`, `/api/auth/login`, `/api/customers/me` (update profile).
2. Movies & sessions: `MovieController` (`/api/movies`), `SessionController` (`/api/sessions`, seats).
3. Seats & pricing: seat map includes per-seat price (base + category multiplier + session price).
4. Reservations & purchase: create reservation (PENDING), confirm via `/api/reservations/{id}/purchase`; cancel forbids past-start.
5. History: `/api/reservations/history` returns session/hall/movie/ticket/promo/payment details.
6. Reviews: upsert + delete (`/api/reviews`).
7. Admin ops: `AdminMovieController`, `AdminHallController` (seat count guarded by hall capacity), `AdminSessionController` (overlap + 10-min buffer, delete), `AdminEmployeeController`, `AdminPromotionController`.

## CI/CD
- GitHub Actions: `.github/workflows/ci.yml` builds backend (`./mvnw -DskipTests package`) and frontend (`npm run build`) on push/PR. Tests are skipped because none are implemented yet.

## Notes
- REST endpoints start under `/api/*` with JWT auth (obtain via auth endpoints).
- Seeds are applied via Flyway migrations when the app starts with a fresh DB volume.***
