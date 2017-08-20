#!/bin/bash

set -e
set -u
set -o pipefail

## retry settings
RETRIES=12
WAIT=5


## helper functions
function _log {
    >&2 echo $@
}

function stop_container {
    _log "Stopping containers"
    docker-compose down -v
}

function _exit {
    if [ $1 -ne 0 ]; then
        docker-compose logs
    fi
    stop_container
    _log $2
    exit $1
}


function test_login {
    curl --fail -s --header "Accept: application/json" --data 'username=demo&password=demo' -D- -o/dev/null http://localhost:8080/camunda/api/admin/auth/user/default/login/${1}
}

function test_invoice_process {
    local task_count=$(curl --fail -s http://localhost:8080/engine-rest/task/count?processDefinitionKey=invoice)
    test "${task_count}" = '{"count":4}'
}

function test_encoding {
    curl --fail -w "\n" http://localhost:8080/engine-rest/deployment/create -F deployment-name=testEncoding -F testEncoding.bpmn=@resources/testEncoding.bpmn
    curl --fail -w "\n" -H "Content-Type: application/json" -d '{}'  http://localhost:8080/engine-rest/process-definition/key/testEncoding/start
}

function poll {
    local cmd="$1"
    for i in $(seq $RETRIES); do
        _log "Polling $cmd for the $i. time"

        $cmd && return 0

        if [ $i -eq $RETRIES ]; then
            return 1
        else
            _log "Waiting for $WAIT seconds"
            sleep $WAIT
        fi
    done
}

function tests {
    local container=$1

    stop_container

    _log "Starting containers ${container}"

    docker-compose up -d ${container} || _exit 1 "Unable to start containers for ${container}"

    _log "Test web app logins for ${container}"

    poll "test_login admin" || _exit 2 "Unable to login to admin for ${container}"
    poll "test_login cockpit" || _exit 3 "Unable to login to cockpit for ${container}"
    poll "test_login tasklist" || _exit 4 "Unable to login to tasklist for ${container}"

    _log "Login successfull for ${container}"

    poll "test_invoice_process" || _exit 5 "Unable to find tasks for invoice process for ${container}"
    poll "test_encoding" || _exit 6 "Wrong encoding detected for ${container}"

    _log "Process tests successfull for ${container}"
}


## tests

for server in tomcat wildfly; do
    for db in h2 mysql postgresql; do
        tests "${server}-${db}"
        tests "${server}-alpine-${db}"
    done
done

_exit 0 "Test successfull"
