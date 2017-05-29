FROM ubuntu:latest

ENV TZ=Etc/UTC \
    LANG=en_US.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64  

# Camunda user and home/working directory
ARG CAMUNDA_USER=camunda
ARG CAMUNDA_HOME=/camunda

# Camunda distro artifact
ARG CAMUNDA_PROFILE=camunda-bpm
ARG CAMUNDA_GROUP_ID=org.camunda.bpm.tomcat
ARG CAMUNDA_ARTIFACT_ID=camunda-bpm-tomcat
ARG CAMUNDA_VERSION=7.7.0
ARG CAMUNDA_PACKAGING=tar.gz
ARG CAMUNDA_ARTIFACT=${CAMUNDA_GROUP_ID}:${CAMUNDA_ARTIFACT_ID}:${CAMUNDA_VERSION}:${CAMUNDA_PACKAGING}

# Database driver artifacts
ARG POSTGRESQL_ARTIFACT=org.postgresql:postgresql:9.3-1102-jdbc4:jar
ARG MYSQL_ARTIFACT=mysql:mysql-connector-java:5.1.21:jar

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jre-headless maven tzdata && \
    apt-get clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/*

# Maven settings file to download artifacts
ADD settings.xml /root/.m2/settings.xml

RUN mvn org.apache.maven.plugins:maven-dependency-plugin:unpack \
	-P ${CAMUNDA_PROFILE} \
	-Dartifact=${CAMUNDA_ARTIFACT} \
	-DoutputDirectory=/tmp \ 
	-Dproject.basedir=/tmp

RUN mv /tmp/server/apache* ${CAMUNDA_HOME}

RUN mvn org.apache.maven.plugins:maven-dependency-plugin:copy \
	-Dartifact=${POSTGRESQL_ARTIFACT} \
	-DoutputDirectory=${CAMUNDA_HOME}/lib \ 
	-Dproject.basedir=/tmp

RUN mvn org.apache.maven.plugins:maven-dependency-plugin:copy \
	-Dartifact=${MYSQL_ARTIFACT} \
	-DoutputDirectory=${CAMUNDA_HOME}/lib \ 
	-Dproject.basedir=/tmp

RUN useradd -d ${CAMUNDA_HOME} ${CAMUNDA_USER}

RUN chown -R ${CAMUNDA_USER}:${CAMUNDA_USER} ${CAMUNDA_HOME}

WORKDIR ${CAMUNDA_HOME}
USER ${CAMUNDA_USER}
