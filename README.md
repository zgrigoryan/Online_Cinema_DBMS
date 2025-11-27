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
