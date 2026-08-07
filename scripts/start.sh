#!/bin/bash

API_KEY=$1

# If no key was passed as an argument, fall back to the git-ignored .api_key
# file in the widget folder (first line).
if [[ -z "${API_KEY}" ]]; then
    WIDGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [[ -f "${WIDGET_DIR}/.api_key" ]]; then
        API_KEY="$(head -n1 "${WIDGET_DIR}/.api_key")"
    fi
fi

function checkAPIkey() {
    if [[ -z "${API_KEY}" ]]; then
        echo " ERROR :("
        echo
        echo " Missing API key!"
        echo " - You have to pass the key as an argument:"
        echo "   ..."
        echo "   bash start.sh <YOUR-API-KEY>"
        echo "   ..."
        echo " - Or create the git-ignored file .api_key in the widget folder:"
        echo "   ..."
        echo "   printf '<YOUR-API-KEY>\n' > .api_key && chmod 600 .api_key"
        echo "   ..."
        echo
        exit 1
    fi
}

function get_monitor_count() {
    local count=0
    for status_file in /sys/class/drm/card*-*/status; do
        if [[ -f "$status_file" && $(cat "$status_file") == "connected" ]]; then
            ((count++))
        fi
    done
    # Fallback to xrandr if /sys/class/drm is empty or not accessible
    if [[ $count -eq 0 ]]; then
        count=$(xrandr --listmonitors | grep -c "^\s*[0-9]\+:")
    fi
    echo "$count"
}

function start() {
    export OPENWEATHER_API_KEY=${API_KEY}

    killall conky &> /dev/null
    sleep 1 # Wait for old processes to clean up
    
    cd /home/$(whoami)/.conky/Clock-With-Weather-Conky || true

    # Detect monitors
    MONITORS=$(get_monitor_count)
    
    # Check if panel is enabled in configuration
    local panel_enabled=$(grep -c "START_PANEL_ENABLED = true" panelApp.lua)

    if [[ "$MONITORS" -le 1 ]]; then
        nohup /usr/bin/conky -c cwApp.lua >/dev/null 2>&1 </dev/null &
        if [[ $panel_enabled -gt 0 ]]; then
            sleep 0.5
            nohup /usr/bin/conky -c panelApp.lua -m 0 >/dev/null 2>&1 </dev/null &
        fi
    else
        for (( i=0; i<$MONITORS; i++ )); do
            nohup /usr/bin/conky -c cwApp.lua -m $i >/dev/null 2>&1 </dev/null &
            if [[ $panel_enabled -gt 0 ]]; then
                sleep 0.5
                nohup /usr/bin/conky -c panelApp.lua -m $i >/dev/null 2>&1 </dev/null &
            fi
            sleep 0.5
        done
    fi

    cd - > /dev/null || true
    echo "$MONITORS"
}

function monitor_changes() {
    local last_monitors="$1"
    # Note: avoid killing the current script if running
    while true; do
        sleep 5
        local current_monitors=$(get_monitor_count)
        if [[ "$current_monitors" -ne "$last_monitors" ]]; then
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
