#!/bin/bash

set -e
set -o pipefail

if [ -n "${TRAVIS_TAG}" ]; then
    echo "Building tag ${TRAVIS_TAG}"
    dir=${TRAVIS_TAG%%-*}
    make -C ${dir} VERSION=${TRAVIS_TAG}
elif [ "${TRAVIS_EVENT_TYPE}" = "cron" ]; then
    echo "Building SNAPSHOT"
    dir=$(find . -type f -name Makefile -exec grep '^VERSION' {} \; | cut -d = -f 2 | grep SNAPSHOT | tail -n 1)
    dir=${dir%-SNAPSHOT}
    make -C ${dir}
else
    echo "Building commit"
    for dir in $(find . -mindepth 2 -maxdepth 2 -type f -name Makefile -exec dirname {} \;); do
        make -C ${dir} build
    done
fi

