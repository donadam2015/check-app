#!/bin/bash

# change to where this script runs from 
SDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) 

DOCKER_COMPOSE_FILE=$SDIR/docker-web-tester.yml
TESTCMD="web.test npm run test"
# TESTCMD="web.test sleep 10"
PROJECT=webtester

usage() {
    cat <<EOF
    usage:
        $0 numberoftests
        $0 numberoftests close

    spins up additional compose groups of the check web tests and a chromium driver
	or closes the testers

EOF
    exit
}

dip () {
    CONT=$1
    local IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONT);
    if [ -z "${IP}" ]; then
	IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONT);
    fi
    echo $IP;
}

new_instance() {
    # use a different project name to differentiate the test instances
    local PROJECT=$1
    
    docker-compose -f $DOCKER_COMPOSE_FILE -p $PROJECT run -d $TESTCMD
    echo "http://$(dip ${PROJECT}_web.test_run_1):13333"
    echo "vnc://$(dip ${PROJECT}_chromedriver_1)"
}

all_down() {
    for I in $(seq 1 $NUMTEST); do
    	docker-compose -f $DOCKER_COMPOSE_FILE -p webtester${I} down
    done
}
    
main() {

    for I in $(seq 1 $NUMTEST); do
		new_instance ${PROJECT}${I};
    done
	exit
}

NUMTEST=$1
if [ -z "${NUMTEST}" ]; then
	usage
fi
if [ "close" == "${2}" ]; then
	all_down
	exit
fi

main
