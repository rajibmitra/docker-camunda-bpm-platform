#!/bin/sh

if [ -f bin/catalina.sh ]; then
    bin/catalina.sh run
elif [ -f bin/standalone.sh ]; then
    export PREPEND_JAVA_OPTS="-Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0"
    export LAUNCH_JBOSS_IN_BACKGROUND=TRUE
    bin/standalone.sh
else
    echo "Unable to detect distro and start camunda"
    exit 1
fi
