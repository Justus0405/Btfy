#!/usr/bin/env bash
#
# Termux-API Battery Monitoring via Discord Webhook
#
# Author: Justus0405
# Date: 05.09.2025
# License: MIT

export scriptVersion="1.0"

## USER CONFIGURATION START

# Discord webhook
export WEBHOOK_URL=""

# Interval for battery check
export INTERVAL="60s"

## USER CONFIGURATION STOP

### COLOR CODES ###
export black="\e[1;30m"
export red="\e[1;31m"
export green="\e[1;32m"
export yellow="\e[1;33m"
export blue="\e[1;34m"
export purple="\e[1;35m"
export cyan="\e[1;36m"
export lightGray="\e[1;37m"
export gray="\e[1;90m"
export lightRed="\e[1;91m"
export lightGreen="\e[1;92m"
export lightYellow="\e[1;93m"
export lightBlue="\e[1;94m"
export lightPurple="\e[1;95m"
export lightCyan="\e[1;96m"
export white="\e[1;97m"
export bold="\e[1m"
export faint="\e[2m"
export italic="\e[3m"
export underlined="\e[4m"
export blinking="\e[5m"
export reset="\e[0m"

### FUNCTIONS ###
logMessage() {
    local type="$1"
    local message="$2"
    case "${type}" in
    "info" | "INFO")
        echo -e "[  ${cyan}INFO${reset}  ] ${message}"
        ;;
    "done" | "DONE")
        echo -e "[  ${green}DONE${reset}  ] ${message}"
        exit 0
        ;;
    "warning" | "WARNING")
        echo -e "[ ${red}FAILED${reset} ] ${message}"
        ;;
    "error" | "ERROR")
        echo -e "[  ${red}ERROR${reset} ] ${message}"
        exit 1
        ;;
    *)
        echo -e "[UNDEFINED] ${message}"
        ;;
    esac
}

getArguments() {
    case "$1" in
    "start")
        checkEnviroment
        getEnviroment
        startScript
        ;;
    "stop")
        stopScript
        ;;
    "help")
        printHelp
        ;;
    "version")
        printVersion
        ;;
    "")
        logMessage "error" "No operation specified. Use $(basename "$0") help"
        ;;
    *)
        logMessage "error" "Unrecognized option '$1'. Use $(basename "$0") help"
        ;;
    esac
}

checkEnviroment() {
    # Simple check for looking if all dependencies are installed and if a webhook is defined.

    command -v curl >/dev/null 2>&1 || logMessage "error" "curl is not installed."
    command -v jq >/dev/null 2>&1 || logMessage "error" "jq is not installed."

    if [ -z "${WEBHOOK_URL}" ]; then
        logMessage "error" "Missing discord webhook url."
    fi
}

getEnviroment() {
    # Tries to get the manufacturer and model name of the device.
    # Used as Title for sendMessage().

    manufacturer=$(getprop ro.product.manufacturer)
    model=$(getprop ro.product.model)

    # Fallback
    if [ -z "${manufacturer}" ]; then
        manufacturer=$(getprop ro.vendor.product.manufacturer)
    fi

    # Fallback
    if [ -z "${model}" ]; then
        model=$(getprop ro.vendor.product.model)
    fi

    if [ -z "${manufacturer}" ]; then
        manufacturer="Unknown"
    fi

    if [ -z "${model}" ]; then
        model="Unknown"
    fi

    # Neat trick with ^ which makes the first letter capital.
    export embedName="${manufacturer^} ${model}"
}

startScript() {

    logMessage "info" "Started battery notifier"
    export lastChargingState=""

    while :; do
        # shellcheck disable=SC2155,SC2030
        export chargingState=$(termux-battery-status | jq -r '.status')
        # shellcheck disable=SC2155,SC2030
        export batteryPercentage=$(termux-battery-status | jq -r '.percentage')

        # When the current charging state differs from the last charging state,
        # send a message announcing the new state.
        if [[ "${chargingState}" != "${lastChargingState}" ]]; then

            if [[ "${chargingState}" == "FULL" ]]; then
                # shellcheck disable=SC2155,SC2030
                export embedTitle="Your Device is fully charged!"
                # shellcheck disable=SC2155,SC2030
                export embedColor="16376495"
                getBatteryInfo
            fi

            if [[ "${chargingState}" == "CHARGING" ]]; then
                export embedTitle="Your Device is Charging!"
                export embedColor="10937249"
                getBatteryInfo
            fi

            if [[ "${chargingState}" == "DISCHARGING" ]]; then
                export embedTitle="Your Device is Discharging!"
                export embedColor="16429959"
                getBatteryInfo
            fi

        fi

        # Sends a low battery warning when at 15%.
        if [[ "${sendPercentageNotification}" == false ]]; then

            if [[ ${batteryPercentage} -lt 16 ]]; then
                export sendPercentageNotification=true
                export embedTitle="Your Device needs to be charged!"
                export embedColor="15961000"
                getBatteryInfo
            fi

        fi

        # Unlocks the low battery warning at 17% again.
        if [[ ${batteryPercentage} -gt 16 ]]; then
            export sendPercentageNotification=false
        fi

        sleep ${INTERVAL}
    done &
}

stopScript() {
    logMessage "info" "Stopping battery notifier..."
    pkill -f "sleep ${INTERVAL}" 2>&1
    pkill -f "$(basename "$0")" 2>&1
}

getBatteryInfo() {
    # Reads the json of termux-battery-status and format every entry to have
    # a newline at the end, this makes for a dynamic info message depending on
    # the battery model.

    export embedMessage=""
    # shellcheck disable=SC2031
    export lastChargingState=${chargingState}

    while IFS= read -r line; do
        export embedMessage+="$line"$'\n'
    done < <(termux-battery-status | jq -r 'to_entries[] | "\(.key): \(.value)"')

    sendMessage
}

sendMessage() {
    currentTime=$(date -Iseconds)
    message=$(jq -n \
        --arg username "${embedName}" \
        --arg avatar_url "https://emoji.aranja.com/emojis/google/1f50c.png" \
        --arg title "${embedTitle}" \
        --arg description "${embedMessage}" \
        --arg timestamp "${currentTime}" \
        --argjson color "${embedColor}" \
        '{
            username: $username,
            avatar_url: $avatar_url,
            embeds:[
                {
                    title: $title,
                    description: $description,
                    timestamp: $timestamp,
                    color: $color
                }
            ]
        }')

    curl -H "Content-Type: application/json" \
        -X POST \
        -d "${message}" \
        "${WEBHOOK_URL}"
}

printHelp() {
    echo -e "usage: $(basename "$0") [...]"
    echo -e "arguments:"
    echo -e "\t start"
    echo -e "\t stop"
    echo -e "\t help"
    echo -e "\t version"
    echo -e ""
    exit 0
}

printVersion() {
    echo -e "               $(basename "$0") v${scriptVersion} - GNU bash, version 5.3"
    echo -e "               Copyright (C) 2025-present Justus0405"
    echo -e ""
    exit 0
}

### PROGRAM START ###
getArguments "$@"
