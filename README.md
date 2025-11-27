# Online_Cinema_DBMS

Spring Boot + Postgres + Flyway project for an online cinema DBMS.

## Prerequisites
- Docker (Desktop) running — required for Testcontainers.
- JDK 17 if you want to run locally (or use the Maven wrapper inside the Maven 17 Docker image, see below).

## Build & Test
- Local JDK 17:
  ```bash
  ./mvnw test
  ```
- Using Maven + JDK 17 in Docker (no local Java needed; mounts Docker socket for Testcontainers):
  ```bash
  docker run --rm \
    -v "$PWD":/workspace -w /workspace \
    -v /var/run/docker.sock:/var/run/docker.sock \
    maven:3.9.6-eclipse-temurin-17 ./mvnw test
  ```

## Run the app (against docker-compose Postgres)
1) Start the database:
   ```bash
   docker compose -f docker/docker-compose.yml up -d
   ```
2) Run Spring Boot:
   ```bash
   ./mvnw spring-boot:run
   ```
   Uses `SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cinema_app`, user `cinema`, password `cinema123` by default (see `src/main/resources/application.yml`).

## Docker images
- Build the app image:
  ```bash
  docker build -t online-cinema-app .
  ```

## Frontend (React + Vite)
- Location: `frontend/`
- Install deps: `cd frontend && npm install`
- Run dev server: `npm run dev` (proxies `/api` to `http://localhost:8080`)
- Build: `npm run build`

## Notes
- Flyway migrations live in `src/main/resources/db/migration`.
- Test data seeds are in `V2__seed_data.sql`.
- REST entrypoints start under `/api/*` with JWT auth. Use `/api/auth/register` or `/api/auth/login` to obtain a token.
