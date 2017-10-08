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

function has_auth {
    [ "${NEXUS_USER}" != "_" -a "${NEXUS_PASS}" != "_" ]
}

if is_ee; then
    REPOSITORY="camunda-bpm-ee"
    # Camunda enterprise artifact has additional ee part
    ARTIFACT="camunda-bpm-ee-${DISTRO}"
    if ! is_snapshot; then
        # Camunda enterprise version as a -ee prefix if its not a SNAPSHOT
        VERSION="${VERSION}-ee"
    fi
else
    REPOSITORY="camunda-bpm"
    ARTIFACT="camunda-bpm-${DISTRO}"
fi

if is_snapshot; then
    REPOSITORY="${REPOSITORY}-snapshots"
fi


# nexus url to download distro
URL="${NEXUS}?r=${REPOSITORY}&g=org.camunda.bpm.${DISTRO}&a=${ARTIFACT}&v=${VERSION}&p=tar.gz"

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
