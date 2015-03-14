#!/usr/bin/env bash

_TARGET='8.8.8.8'
_INTERVAL=30 # seconds

connected=1
first=1

print() {
    printf '%s\n' "$*"
}

print_with_timestamp() {
    printf '%s\n' "[$(date +%FT%T)] $*"
}

print_sameline() {
    printf '%s' "$*"
}

print_newline() {
    printf '\n'
}

print_with_timestamp "Pinging ${_TARGET} every ${_INTERVAL} seconds."

while : ; do
    if ! ping -c 1 "${_TARGET}" >/dev/null 2>&1 ; then
        if (( $first )) ; then
            print_with_timestamp "Initial status: disconnected."
            connected=0
            first=0
        elif (( $connected )) ; then
            print_newline
            print_with_timestamp "Connection lost."
            connected=0
        else
            print_sameline 'x'
        fi
    else
        if (( $first )) ; then
            print_with_timestamp "Initial status: connected."
            connected=1
            first=0
        elif (( ! $connected )) ; then
            print_newline
            print_with_timestamp "Connection reestablished."
            connected=1
        else
            print_sameline '.'
        fi
    fi
    sleep "${_INTERVAL}"
done


