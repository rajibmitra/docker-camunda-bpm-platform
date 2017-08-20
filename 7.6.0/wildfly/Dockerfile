FROM ubuntu:latest

# install java and tools
RUN apt-get -qq update && \
    apt-get -qq -y install --no-install-recommends openjdk-8-jre xmlstarlet ca-certificates locales wget tzdata > /dev/null && \
    locale-gen en_US.UTF-8 && \
    apt-get -qq clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/*

WORKDIR /camunda

ENV LANG=en_US.UTF-8 \
    GROUP=wildfly \
    DISTRO=wildfly10 \
    SERVER=wildfly-10.1.0.Final \
    LIB_DIR=/camunda/modules \
    SERVER_CONFIG=/camunda/standalone/configuration/standalone.xml \
    PREPEND_JAVA_OPTS="-Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0" \
    NEXUS=https://app.camunda.com/nexus/service/local/artifact/maven/redirect \
    LAUNCH_JBOSS_IN_BACKGROUND=TRUE \
    DB_DRIVER=h2 \
    DB_URL=jdbc:h2:./camunda-h2-dbs/process-engine;DB_CLOSE_DELAY=-1;MVCC=TRUE;DB_CLOSE_ON_EXIT=FALSE \
    DB_USERNAME=sa \
    DB_PASSWORD=sa

ARG VERSION=7.6.0

# add camunda distro
RUN wget -nv -O - "${NEXUS}?r=public&g=org.camunda.bpm.${GROUP}&a=camunda-bpm-${DISTRO}&v=${VERSION}&p=tar.gz" | \
    tar xzf - -C /camunda/ server/${SERVER} --strip 2

# add wildfly modules
COPY modules /camunda/modules/

# add scripts
ADD bin/* /usr/local/bin/

# add database drivers
RUN /usr/local/bin/download-database-drivers.sh "${NEXUS}?r=public&g=org.camunda.bpm&a=camunda-database-settings&v=${VERSION}&p=pom"

EXPOSE 8080

CMD ["/usr/local/bin/configure-and-run.sh"]
