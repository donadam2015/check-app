#!/bin/bash


NUMTEST=$1
DOCKER_COMPOSE_FILE=docker-web-tester.yml
TESTCMD="web.test npm run test"
# TESTCMD="web.test sleep 10"

if [ -z "${NUMTEST}" ]; then
    cat <<EOF
    usage:
        $0 numberoftests

    spins up additional compose groups of the check web tests and a chromium driver

EOF
    exit
fi

dip () {
    CONT=$1
    local IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONT);
    if [ -z "${IP}" ]; then
	IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONT);
    fi
    echo $IP;
}

new_instance() {
    # use a different project name to differentiat the test instances
    local PROJECT=$1
    docker-compose -f $DOCKER_COMPOSE_FILE -p $PROJECT down
    
#    docker-compose -f $DOCKER_COMPOSE_FILE -p $PROJECT run -d $TESTCMD
    echo "http://$(dip ${PROJECT}_web.test_run_1):13333"
    echo "vnc://$(dip ${PROJECT}_chromedriver_1)"
}

    
main() {

    for I in $(seq 1 $NUMTEST); do
	new_instance webtester${I};
    done

}

main
