#!/usr/bin/env bash
set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASEDIR"

# Ensure JDK 17 is used
if [[ -z "${JAVA_HOME:-}" ]]; then
  if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
    export JAVA_HOME="$("/usr/libexec/java_home" -v 17)"
    export PATH="$JAVA_HOME/bin:$PATH"
    echo "Using JAVA_HOME=$JAVA_HOME"
  else
    echo "WARNING: JDK 17 not found; please install or set JAVA_HOME to a JDK 17."
  fi
fi

echo "Starting Postgres via docker-compose..."
docker compose -f docker/docker-compose.yml up -d

echo "Running Spring Boot (JDK 17 required)..."
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL:-jdbc:postgresql://localhost:5433/cinema_app} \
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME:-cinema} \
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD:-cinema123} \
./mvnw spring-boot:run

echo "To run everything in Docker instead (avoids host networking issues), use:"
echo "  docker compose -f docker/docker-compose.yml up --build app"
