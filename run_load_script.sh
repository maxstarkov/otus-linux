#!/bin/bash

PROGNAME=$(basename $0)
DIR=$(dirname $0)
PID=$$
debug=0

log() {
        if (( debug ))
        then
                echo "Parent [$PID]: $1"
        fi
}

run() {

        log "starting..."
        log "launching child script..."

        nice -n 19 $DIR/cpu_load.sh "Run with nice: 19" $debug &
        pid1=$!
        log "child (PID=$pid1) launched."

        $DIR/cpu_load.sh "Run with default nice" $debug &
        pid2=$!
        log "child (PID=$pid2) launched."

        trap "log 'kill child process $pid1 $pid2'; kill $pid1 $pid2" SIGINT SIGTERM

        echo "Runed two process with low [PID=$pid1] and default [PID=$pid2] nice. Please wait for processes to complete or press CTRL+C."
        log "pausing to wait for child to finish..."
        wait

        log "child is finished. Continuing..."
        log "parent is done. Exiting."

}

usage() {

        echo "This bash script run two CPU load process with low and default nice."
        echo "$PROGNAME: usage $PROGNAME [-d | -h]"
        echo "-d: debug mode, print log in stdout;"
        echo "-h: print help.\n"

}

case $1 in
        -d | --debug)   debug=1
                        ;;
        -h | --help)    usage
                        exit
                        ;;
esac

run