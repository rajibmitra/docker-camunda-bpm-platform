FROM ubuntu:latest

# install java and tools
RUN apt-get -qq update && \
    apt-get -qq -y install --no-install-recommends openjdk-8-jre xmlstarlet ca-certificates locales wget tzdata > /dev/null && \
    locale-gen en_US.UTF-8 && \
    apt-get -qq clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/*

WORKDIR /camunda

ENV LANG=en_US.UTF-8 \
    DISTRO=tomcat \
    SERVER=apache-tomcat-8.0.24 \
    LIB_DIR=/camunda/lib/ \
    SERVER_CONFIG=/camunda/conf/server.xml \
    NEXUS=https://app.camunda.com/nexus/service/local/artifact/maven/redirect \
    DB_DRIVER=org.h2.Driver \
    DB_URL=jdbc:h2:./camunda-h2-dbs/process-engine;MVCC=TRUE;TRACE_LEVEL_FILE=0;DB_CLOSE_ON_EXIT=FALSE \
    DB_USERNAME=sa \
    DB_PASSWORD=sa

ARG VERSION=7.6.0

# add camunda distro
RUN wget -nv -O - "${NEXUS}?r=public&g=org.camunda.bpm.${DISTRO}&a=camunda-bpm-${DISTRO}&v=${VERSION}&p=tar.gz" | \
    tar xzf - -C /camunda/ server/${SERVER} --strip 2

# add scripts
ADD bin/* /usr/local/bin/

# add database drivers
RUN /usr/local/bin/download-database-drivers.sh "${NEXUS}?r=public&g=org.camunda.bpm&a=camunda-database-settings&v=${VERSION}&p=pom"

EXPOSE 8080

CMD ["/usr/local/bin/configure-and-run.sh"]
