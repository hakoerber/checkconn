#!/usr/bin/env bash

#default parameter values

_TARGET='8.8.8.8'
_INTERVAL=30 # seconds

#variables and functions from the script

connected=1

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

print_help() {
    print "Check you network connection against a target"
    print_newline
    print "parameters:"
    print_newline
    print "-t <TARGET> : Specifies the IP used as a target to check the connection (default to 8.8.8.8) "
    print "-i <INTERVAL> : Seconds for each check (defualt to 30 seconds)"
    print "-h : Prints this help"
    print_newline
    print "project: https://github.com/hakoerber/checkconn"
    exit;
}

#parse arguments in order to change parameter values

while getopts t:i:h option
do
    case "${option}"
    in
    t) _TARGET=${OPTARG};;
    i) _INTERVAL=${OPTARG};;
    h) print_help;;
    esac
done

print_with_timestamp "Pinging ${_TARGET} every ${_INTERVAL} seconds."

#extract the handle of the first attempt outside the loop, so the loop is shorter and performant
#we also setup the connected variable right here

ping_execution=`ping -c 1 "${_TARGET}" >/dev/null 2>&1`

if [ $? -ne 0 ] ; then
    print_with_timestamp "Initial status: disconnected."
    connected=0
else
    print_with_timestamp "Initial status: connected."
    connected=1
fi
    
sleep "${_INTERVAL}"

#we enter the control loop, now is shorter and performant

while : ; do

    ping_execution=`ping -c 1 "${_TARGET}" >/dev/null 2>&1`

    if [ $? -ne 0 ] ; then
        
        if (( $connected )) ; then
            print_newline
            print_with_timestamp "Connection lost."
        else
            print_sameline 'x'
        fi

        connected=0

    else
      
        if (( ! $connected )) ; then
            print_newline
            print_with_timestamp "Connection reestablished."
        else
            print_sameline '.'
        fi
        
        connected=1
    fi

    sleep "${_INTERVAL}"
done


