# Use lightweight Java runtime
FROM eclipse-temurin:11-jre-alpine

# App directory
WORKDIR /app

# Copy jar from target folder
COPY target/*.jar app.jar

# Expose app port
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
