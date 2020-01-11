#!/bin/bash

PID=$$
msg=$1
debug=$2

log() {
        if (( debug ))
        then
                echo "Child [$PID]: $1"
        fi
}

start=$(date +%s%N)

log "child is running..."

dd if=/dev/zero of=/dev/null bs=100M count=100 &>/dev/null &
pid=$!

log "start dd with PID=$pid"

trap "log 'stop signal received'; echo 'stop signal received [PID=$PID]'; kill $pid; exit 0" SIGINT SIGTERM

wait

end=$(date +%s%N)

echo "$msg. [PID=$PID] Execution time - $(( ($end - $start) / 1000000 )) ms"

log "child is done. Exiting."
