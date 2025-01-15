#!/bin/bash

set -e

VERBOSE=${VERBOSE:-1}

# remote port on the destination: only one ssh session can bind it
# make sure all clients use the same remote port
SINGLETON_PORT=${SINGLETON_PORT:-9999}

# local port
LOCAL_PORT=8888

DEFAULT_SSH_OPTIONS="${DEFAULT_SSH_OPTIONS:--o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o TCPKeepAlive=yes}"

# look for options incompatible with '-o ExitOnForwardFailure=yes' or '-t -t'
previous=
option_loglevel=
[ "${VERBOSE}" !=  "1" ] && option_loglevel="-o LogLevel=ERROR"
for option in ${DEFAULT_SSH_OPTIONS} ${SSH_OPTIONS}; do
    if [ "${previous}" == "-o" ] && [ "$(echo ${option} | grep -i 'ExitOnForwardFailure=no' | wc -l)" != "0" ]; then
        echo "ERROR: cannot set ssh option '-o ExitOnForwardFailure=no' in command line or DEFAULT_SSH_OPTIONS" >&2
        exit 1
    fi
    if [ "${option}" == "-T" ]; then
        echo "ERROR: cannot set ssh option '-T' in command line or DEFAULT_SSH_OPTIONS" >&2
        exit 1
    fi

    if [ "${previous}" == "-o" ] && [ "$(echo ${option} | grep -i 'LogLevel=' | wc -l)" != "0" ]; then
        option_loglevel=
    fi
    previous=${option}
done

# -R + ExitOnForwardFailure to guarantee only one ssh client using this port on remote host
# -t -t to force signal propagation when ssh dies (https://unix.stackexchange.com/a/210356)
SSH_OPTIONS="${DEFAULT_SSH_OPTIONS} -t -t -R localhost:${SINGLETON_PORT}:localhost:${LOCAL_PORT} -o ExitOnForwardFailure=yes ${option_loglevel} ${SSH_OPTIONS}"

mkdir -p /root/ssh-singleton
cd /root/ssh-singleton

# start server to receive ack from remote server
if [ "${VERBOSE}" !=  "1" ]; then
    XTRACE_ON=true
    CURL_OPT="-s -o /dev/null"

    python3 ../acq_server.py ${LOCAL_PORT} >/dev/null 2>&1 &
else
    XTRACE_ON="set -x"
    CURL_OPT=""

    python3 ../acq_server.py ${LOCAL_PORT} &
fi

ret=0
IFS=',' read -r -a array_servers <<< "${SSH_SERVERS}"
[ "${#array_servers[@]}" == "0" ] && echo "ERROR missing env var SSH_SERVERS" && exit 1
for server in "${array_servers[@]}"; do
    ret=0
    ${XTRACE_ON}
    /usr/bin/ssh ${SSH_OPTIONS} ${server} ${XTRACE_ON} \&\& curl ${CURL_OPT} localhost:${SINGLETON_PORT}/ack \&\& "$@" || ret=$?
    { set +x; } 2>/dev/null
    if [ -e ack ] && [ ${#SSH_SERVERS} -gt 1 ]; then
        [ "${VERBOSE}" ==  "1" ] && echo "ack was received from remove server, do not try any other servers"
        break
    fi
done
${XTRACE_ON}
exit $ret
