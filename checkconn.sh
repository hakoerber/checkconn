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

execute_test() {

    if [ "$(ping -c 1 "${_TARGET}" 2> /dev/null)" != "" ]; then
        echo "OK"
        return 0    
    fi
    
    echo "ERROR"
    return 1
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

while getopts t:i:h 2>/dev/null option
do
    case "${option}" in
        t) _TARGET=${OPTARG}
            ;;
        i) _INTERVAL=${OPTARG}
            ;;
        h) print_help
            ;;
        *) print "[Error] There are options that are not recognized."
            print_newline
            print "Usage:"
            print_newline
            print_help
            exit
            ;;
    esac
done

print_with_timestamp "Pinging ${_TARGET} every ${_INTERVAL} seconds."

#extract the handle of the first attempt outside the loop, so the loop is shorter and performant
#we also setup the connected variable right here

if [ "$(execute_test)" == "OK" ] ; then
    print_with_timestamp "Initial status: connected."
    connected=1
else
    print_with_timestamp "Initial status: disconnected."
    connected=0
fi
    
sleep "${_INTERVAL}"

#we enter the control loop, now is shorter and performant

while : ; do

    if [ "$(execute_test)" == "ERROR" ] ; then
        
        if [ $connected -eq 1 ] ; then
            print_newline
            print_with_timestamp "Connection lost."
        else
            print_sameline 'x'
        fi

        connected=0

    else
      
        if [ $connected -eq 0 ] ; then
            print_newline
            print_with_timestamp "Connection reestablished."
        else
            print_sameline '.'
        fi
        
        connected=1
    fi

    sleep "${_INTERVAL}"
done


