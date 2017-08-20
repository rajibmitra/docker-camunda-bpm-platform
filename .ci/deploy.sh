#!/bin/bash

set -e
set -o pipefail

docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

if [ -n "${TRAVIS_TAG}" ]; then

    echo "Pushing tag ${TRAVIS_TAG}"

    dir=${TRAVIS_TAG%%-*}
    make -C ${dir} tag push VERSION=${TRAVIS_TAG}

    latest=$(find . -type f -name Makefile -exec grep VERSION {} \; | cut -d = -f 2 | grep -v SNAPSHOT | sort -n | tail -n 1)

    if [ "${latest}" = "${TRAVIS_TAG}" ]; then
        make -C ${dir} tag-latest push-latest VERSION=${TRAVIS_TAG}
    fi

elif [ "${TRAVIS_EVENT_TYPE}" = "cron" ]; then
    echo "Pushing SNAPSHOT"

    dir=$(find . -type f -name Makefile -exec grep '^VERSION' {} \; | cut -d = -f 2 | grep SNAPSHOT | tail -n 1)
    dir=${dir%-SNAPSHOT}

    make -C ${dir} tag push
fi

