FROM alpine:latest as builder

WORKDIR /camunda

ARG DISTRO=tomcat
ARG VERSION=7.7.0
ARG NEXUS_USER=_
ARG NEXUS_PASS=_
ARG EE=false
ARG SLIM=false

RUN apk add --no-cache bash ca-certificates wget tar xmlstarlet rsync

COPY modules /tmp/modules/

ADD build/* /bin/

RUN download-camunda.sh


FROM openjdk:8-jre-alpine

ENV LANG=en_US.UTF-8 \
    TZ=UTC \
    DB_DRIVER=org.h2.Driver \
    DB_URL=jdbc:h2:./camunda-h2-dbs/process-engine;MVCC=TRUE;TRACE_LEVEL_FILE=0;DB_CLOSE_ON_EXIT=FALSE \
    DB_USERNAME=sa \
    DB_PASSWORD=sa

WORKDIR /camunda

COPY --from=builder /camunda/ .

RUN apk add --no-cache bash xmlstarlet ca-certificates

ADD run/configure-and-run.sh /bin/

CMD ["/bin/configure-and-run.sh"]
