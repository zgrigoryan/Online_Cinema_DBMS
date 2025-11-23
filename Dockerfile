FROM maven:3.9.7-eclipse-temurin-17 AS builder
WORKDIR /app

COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src src
RUN mvn -B -q package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=builder /app/target/online-cinema-dbms-0.0.1-SNAPSHOT.jar app.jar

ENV SPRING_PROFILES_ACTIVE=default
EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
