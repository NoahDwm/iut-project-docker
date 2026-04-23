FROM eclipse-temurin:25-jdk AS builder
WORKDIR /app
COPY . .
RUN ./gradlew build -x test --no-daemon
RUN jlink \
	--add-modules java.base,java.naming,java.logging,java.management,java.security.jgss,java.desktop,java.xml,java.instrument \
        --strip-debug \
        --no-man-pages \
        --no-header-files \
        --compress=2 \
	--output /javaruntime

FROM debian:buster-slim
WORKDIR /app
ENV PATH "/opt/java/openjdk/bin:${PATH}"
COPY --from=builder /javaruntime /opt/java/openjdk
RUN mkdir /opt/app
COPY --from=builder /app/build/libs/app.jar /opt/app/app.jar
EXPOSE 8080

CMD ["java", "-jar", "/opt/app/app.jar"]
