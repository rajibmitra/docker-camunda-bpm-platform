#!/bin/bash -ex

set -o pipefail

docker build -t menski/camunda-single-file:${DISTRO}-${VERSION} \
    --build-arg DISTRO=${DISTRO} \
    --build-arg VERSION=${VERSION} \
    --build-arg EE=${EE} \
    --build-arg NEXUS_USER=${NEXUS_USER} \
    --build-arg NEXUS_PASS=${NEXUS_PASS} \
    .
