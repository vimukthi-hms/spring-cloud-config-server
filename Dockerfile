FROM adoptopenjdk/openjdk11:alpine-slim as builder
LABEL maintainer="hyness <hyness@freshlegacycode.org>"
WORKDIR /build

COPY . ./
RUN sh gradlew -DjvmTarget=11 -console verbose --no-build-cache --no-daemon assemble && mv build/libs/* .
RUN java -Djarmode=layertools -jar spring-cloud-config-server.jar extract

FROM adoptopenjdk/openjdk11:alpine-slim
ARG SPRING_CLOUD_CONFIG_SERVER_GIT_URI
ARG SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME
ARG SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD
ARG SPRING_PROFILES_ACTIVE

ENV SPRING_CLOUD_CONFIG_SERVER_GIT_URI=${SPRING_CLOUD_CONFIG_SERVER_GIT_URI}
ENV SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME=${SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME}
ENV SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD=${SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD}
ENV SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}
ENV SPRING_CLOUD_CONFIG_SERVER_GIT_CLONE_ON_START="true"


WORKDIR /opt/spring-cloud-config-server
COPY --from=builder /build/dependencies/ ./
COPY --from=builder /build/spring-boot-loader/ ./
COPY --from=builder /build/application/ ./
COPY entrypoint.sh ./

WORKDIR /
EXPOSE 8888
VOLUME /config
VOLUME /config-git-base
ENTRYPOINT ["sh", "/opt/spring-cloud-config-server/entrypoint.sh"]