# Build stage
FROM eclipse-temurin:8-jdk-alpine AS builder
WORKDIR /build
COPY pom.xml .
COPY mvnw .
COPY mvnw.cmd .
COPY .mvn .mvn
COPY src src
RUN ./mvnw clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:8-jdk-alpine
WORKDIR /app
COPY --from=builder /build/target/*.jar /app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1
CMD ["java", "-jar", "/app.jar"]
