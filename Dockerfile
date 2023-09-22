# BUILD stage

FROM openjdk:17-jdk-slim AS builder

WORKDIR /workspace/app

COPY gradle gradle
COPY build.gradle settings.gradle gradlew ./
COPY src src

RUN ./gradlew bootJar
RUN mkdir -p build/libs/dependency && (cd build/libs/dependency; jar -xf ../*.jar)

# RUN stage

FROM openjdk:17-jdk-slim

VOLUME /tmp

ARG DEPENDENCY=/workspace/app/build/libs/dependency

COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app

ENTRYPOINT ["java", "-cp", "app:app/lib/*", "hello.hellospring.HelloSpringApplication"]