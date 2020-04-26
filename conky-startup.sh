#!/bin/bash

API_KEY=$1

function checkAPIkey() {
    if [[ -z "${API_KEY}" ]]; then
        echo " ERROR :("
        echo
        echo " Missing API key!"
        echo " - You have to pass the key as an argument:"
        echo "   ..."
        echo "   ./conky-startup.sh <YOUR-API-KEY>"
        echo "   ..."
        echo
        exit 1
    fi
}

function start() {
    sleep 10

    export OPENWEATHER_API_KEY=${API_KEY}
    /home/$(whoami)/.conky/Clock-With-Weather-Conky/start.sh
}

function main() {
    checkAPIkey
    start
}

main

