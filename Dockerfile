# Based on https://medium.com/@RoussiAbdelghani/optimizing-java-base-docker-images-size-from-674mb-to-58mb-c1b7c911f622
# and https://hub.docker.com/_/eclipse-temurin
# First stage, build the custom JRE

ARG JRE_BASE_IMAGE

# jre-builder Image to create custom JRE instance
FROM ${JRE_BASE_IMAGE} AS jre-builder

# Extract JRE version from base image
ARG JRE_VERSION
RUN echo "Building with JRE version: ${JRE_VERSION}"

# Install binutils, required by jlink
RUN apk update && \
    apk add binutils

# Build small JRE image. In version 24, the modules must be explicitly specified, see
# https://adoptium.net/blog/2025/03/eclipse-temurin-jdk24-JEP493-enabled/#:~:text=Generating%20a%20runtime%20using%20jlink%20with%20ALL%2DMODULE%2DPATH%20no%20longer%20seems%20to%20work
RUN $JAVA_HOME/bin/jlink \
    --verbose \
    --add-modules java.base,java.logging,java.xml,java.sql,java.naming,java.desktop,java.management,java.prefs,java.net.http,jdk.unsupported,jdk.crypto.ec,java.instrument \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /optimized-jdk-${JRE_VERSION}

# Second stage,
# base Use the custom JRE and build the final app image
FROM alpine:latest AS base
ARG JRE_VERSION
ENV JAVA_HOME=/opt/jdk/jdk-${JRE_VERSION}
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# copy JRE from the base image
COPY --from=jre-builder /optimized-jdk-${JRE_VERSION} $JAVA_HOME

# APP_USER Create a user to run the application, don't run as root
ARG APP_USER=osmosis
RUN addgroup --system ${APP_USER} && adduser --system ${APP_USER} --ingroup ${APP_USER}

# Create the application directory
ENV OSMOSIS_HOME=/opt/osmosis
RUN mkdir ${OSMOSIS_HOME} && chown -R ${APP_USER} ${OSMOSIS_HOME}

COPY --chown=${APP_USER}:${APP_USER} osmosis ${OSMOSIS_HOME}

# Make osmosis executable and create symlink
RUN chmod +x ${OSMOSIS_HOME}/bin/osmosis && \
    ln -s ${OSMOSIS_HOME}/bin/osmosis /usr/local/bin/osmosis

USER ${APP_USER}

# Set entrypoint
ENTRYPOINT ["osmosis"]
