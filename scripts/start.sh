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
    nohup /usr/bin/conky -c app.cfg >/dev/null 2>&1 </dev/null &
    cd - || true
}

function main() {
    checkAPIkey
    start
}

main