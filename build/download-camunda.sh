#!/bin/bash -eux

set -o pipefail

NEXUS=https://app.camunda.com/nexus/service/local/artifact/maven/redirect

function is_ee {
    [ "${EE}" = "true" ]
}

function is_snapshot {
    [[ "${VERSION}" == *SNAPSHOT ]]
}

function is_slim {
    [ "${SLIM}" = "true" ]
}

function is_wildfly {
    [ "${DISTRO}" = "wildfly" ]
}

function has_auth {
    [ "${NEXUS_USER}" != "_" -a "${NEXUS_PASS}" != "_" ]
}

if is_ee; then
    REPOSITORY="camunda-bpm-ee"
    # Camunda enterprise artifact has additional ee part
    ARTIFACT="camunda-bpm-ee-${DISTRO}"
    ARTIFACT_GROUP="camunda-bpm-ee-${DISTRO}"
    if ! is_snapshot; then
        # Camunda enterprise version as a -ee prefix if its not a SNAPSHOT
        ARTIFACT_VERSION="${VERSION}-ee"
    fi
else
    REPOSITORY="camunda-bpm"
    ARTIFACT="camunda-bpm-${DISTRO}"
    ARTIFACT_GROUP="camunda-bpm-${DISTRO}"
    ARTIFACT_VERSION="${VERSION}"
fi

if is_wildfly; then
    # use wildfly 10 instead of 8
    ARTIFACT="${ARTIFACT}10"
fi

if is_snapshot; then
    REPOSITORY="${REPOSITORY}-snapshots"
fi


# nexus url to download distro
URL="${NEXUS}?r=${REPOSITORY}&g=org.camunda.bpm.${DISTRO}&a=${ARTIFACT}&v=${ARTIFACT_VERSION}&p=tar.gz"

# if NEXUS_USER and NEXUS_PASS is specified pass it to wget
if has_auth; then
    AUTH_PARAMS="--user=${NEXUS_USER} --password=${NEXUS_PASS}"
else
    AUTH_PARAMS=""
fi

# create download folder to unpack distro
mkdir download

# download distro
wget -nv -O - ${AUTH_PARAMS} "${URL}" | tar xzf - -C /camunda/download

# only move server folder to /camunda
mv /camunda/download/server/*/* /camunda

# remove everthing except for camunda webapps and engine-rest if slim image
if is_slim; then
    case "${DISTRO}" in
        "tomcat")
            find /camunda/webapps/ -type d -mindepth 1 -maxdepth 1 \( -path /camunda/webapps/camunda -o -path /camunda/webapps/engine-rest \) -prune -o -exec rm -rf {} \;
            ;;
        "wildfly")
            cd /camunda/standalone/deployments
            ls | grep -v camunda-webapp | grep -v camunda-engine-rest | xargs rm -rf
            cd /camunda
            ;;
    esac
fi

# fetch database driver versions
POM=$(wget -nv -O- "${NEXUS}?r=public&g=org.camunda.bpm&a=camunda-database-settings&v=${VERSION}&p=pom")
MYSQL_VERSION=$(echo $POM | xmlstarlet sel -t -v //_:version.mysql)
POSTGRESQL_VERSION=$(echo $POM | xmlstarlet sel -t -v //_:version.postgresql)

case "${DISTRO}" in
    "tomcat")
        wget -nv -O /camunda/lib/mysql-connector-java-${MYSQL_VERSION}.jar "${NEXUS}?r=public&g=mysql&a=mysql-connector-java&v=${MYSQL_VERSION}&p=jar"
        wget -nv -O /camunda/lib/postgresql-${POSTGRESQL_VERSION}.jar "${NEXUS}?r=public&g=org.postgresql&a=postgresql&v=${POSTGRESQL_VERSION}&p=jar"
        ;;
    "wildfly")
        rsync -av /tmp/modules/ /camunda/modules
        MYSQL_DIR=/camunda/modules/mysql/mysql-connector-java/main/
        POSTGRESQL_DIR=/camunda/modules/org/postgresql/postgresql/main/

        wget -nv -O ${MYSQL_DIR}/mysql-connector-java-${MYSQL_VERSION}.jar "${NEXUS}?r=public&g=mysql&a=mysql-connector-java&v=${MYSQL_VERSION}&p=jar"
        sed -i "s/@version.mysql@/${MYSQL_VERSION}/g" ${MYSQL_DIR}/module.xml

        wget -nv -O ${POSTGRESQL_DIR}/postgresql-${POSTGRESQL_VERSION}.jar "${NEXUS}?r=public&g=org.postgresql&a=postgresql&v=${POSTGRESQL_VERSION}&p=jar"
        sed -i "s/@version.postgresql@/${POSTGRESQL_VERSION}/g" ${POSTGRESQL_DIR}/module.xml
        ;;
esac
