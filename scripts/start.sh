#!/bin/bash

API_KEY=$1

function checkAPIkey() {
    if [[ -z "${API_KEY}" ]]; then
        echo " ERROR :("
        echo
        echo " Missing API key!"
        echo " - You have to pass the key as an argument:"
        echo "   ..."
        echo "   bash start.sh <YOUR-API-KEY>"
        echo "   ..."
        echo
        exit 1
    fi
}

function start() {
    export OPENWEATHER_API_KEY=${API_KEY}

    killall conky &> /dev/null
    cd /home/$(whoami)/.conky/Clock-With-Weather-Conky || true

    # Detect monitors
    MONITORS=$(xrandr --listmonitors | grep -c "^\s*[0-9]\+:")

    if [[ "$MONITORS" -le 1 ]]; then
        nohup /usr/bin/conky -c app.cfg >/dev/null 2>&1 </dev/null &
    else
        for (( i=0; i<$MONITORS; i++ )); do
            nohup /usr/bin/conky -c app.cfg -m $i >/dev/null 2>&1 </dev/null &
        done
    fi

    cd - > /dev/null || true
    echo "$MONITORS"
}

function monitor_changes() {
    local last_monitors="$1"
    while true; do
        sleep 5
        local current_monitors=$(xrandr --listmonitors | grep -c "^\s*[0-9]\+:")
        if [[ "$current_monitors" -ne "$last_monitors" ]]; then
            # We don't want to capture the echo output here, just update the value
            start > /dev/null
            last_monitors="$current_monitors"
            echo "Monitor change detected. Updated to $current_monitors monitor(s)."
        fi
    done
}

function main() {
    checkAPIkey
    local initial_monitors=$(start)
    monitor_changes "$initial_monitors"
}

main