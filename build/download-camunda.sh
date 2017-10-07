#!/bin/bash -eux

set -o pipefail

if [ "${EE}" = "true" ]; then
    # Camunda enterprise version as a -ee prefix
    VERSION="${VERSION}-ee"
    # Camunda enterprise artifact has additional ee part
    ARTIFACT="camunda-bpm-ee-${DISTRO}"
    if [ "${REPOSITORY}" = "camunda-bpm" ]; then
        # If the user did not specify another repository for the ee version change to camunda-bpm-ee repository assuming that the camunda nexus is used
        REPOSITORY="${REPOSITORY}-ee"
    fi
else
    ARTIFACT="camunda-bpm-${DISTRO}"
fi


# nexus url to download distro
URL="${NEXUS}?r=${REPOSITORY}&g=org.camunda.bpm.${DISTRO}&a=${ARTIFACT}&v=${VERSION}&p=tar.gz"

# if NEXUS_USER and NEXUS_PASS is specified pass it to wget
if [ "${NEXUS_USER}" != "_" -a "${NEXUS_PASS}" != "_" ]; then
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

