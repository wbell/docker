FROM openjdk:8-jre-alpine

LABEL com.dotcms.contact "support@dotcms.com"
LABEL com.dotcms.vendor "dotCMS LLC"
LABEL com.dotcms.description "dotCMS Content Management System"

ENV HZ_VERSION 3.9.2
ENV HZ_HOME /srv/
WORKDIR $HZ_HOME


RUN apk --no-cache upgrade \
    && apk add --no-cache bash openssl ca-certificates gnupg grep s6-dns \
    && update-ca-certificates

ENV S6_OVERLAY_VERSION v1.21.4.0

# RUN curl https://keybase.io/justcontainers/key.asc | gpg --import \
#    && gpg --verify s6-overlay-amd64.tar.gz.sig s6-overlay-amd64.tar.gz
# https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz.sig

RUN wget --quiet https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
    && tar -xzf s6-overlay-amd64.tar.gz -C / \
    && rm s6-overlay-amd64.tar.gz


ENV DOCKERIZE_VERSION v0.6.0
RUN wget --quiet https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz


RUN mkdir -p $HZ_HOME
# Download hazelcast jars from maven repo.
ADD https://repo1.maven.org/maven2/com/hazelcast/hazelcast-all/$HZ_VERSION/hazelcast-all-$HZ_VERSION.jar ./
# Adding JCache
ADD https://repo1.maven.org/maven2/javax/cache/cache-api/1.0.0/cache-api-1.0.0.jar ./


COPY ROOT/ /
RUN find /etc/cont-init.d/ /etc/fix-attrs.d/ /srv/ -type f -name "*.sh" -exec chmod 500 {} \; 

ENV SERVICE_DELAY_DEFAULT_MIN 1
ENV SERVICE_DELAY_DEFAULT_STEP 3
ENV SERVICE_DELAY_DEFAULT_MAX 30

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

EXPOSE 5701

ENTRYPOINT ["/init"]

