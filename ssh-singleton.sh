#!/bin/sh

set -e

VERBOSE=${VERBOSE:-1}

# remote port on the destination: only one ssh session can bind it
# make sure all clients use the same remote port
SINGLETON_PORT=${SINGLETON_PORT:-9999}

# local port: no real server listening needed
FAKE_LOCAL_PORT=8888

DEFAULT_SSH_OPTIONS="${DEFAULT_SSH_OPTIONS:--o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o TCPKeepAlive=yes}"

# look for options incompatible with '-o ExitOnForwardFailure=yes' or '-t -t'
previous=
for option in ${DEFAULT_SSH_OPTIONS} "$@"; do
    if [ "${previous}" == "-o" ] && [ "${option}" == "ExitOnForwardFailure=no" ]; then
        echo "ERROR: cannot set ssh option '-o ExitOnForwardFailure=no' in command line or DEFAULT_SSH_OPTIONS" >&2
        exit 1
    fi
    if [ "${option}" == "-T" ]; then
        echo "ERROR: cannot set ssh option '-T' in command line or DEFAULT_SSH_OPTIONS" >&2
        exit 1
    fi
    # stop after first @ (assuming this is the end of ssh options)
    if [ "$(echo ${option} | grep '@' | wc -l)" != "0" ]; then
        break
    fi
    previous=${option}
done

# -R + ExitOnForwardFailure to guarantee only one ssh client using this port on remote host
# -t -t to force signal propagation when ssh dies (https://unix.stackexchange.com/a/210356)
SSH_OPTIONS="${DEFAULT_SSH_OPTIONS} -t -t -R ${FAKE_LOCAL_PORT}:${SINGLETON_PORT} -o ExitOnForwardFailure=yes"

[ "${VERBOSE}" ==  "1" ] && set -x
/usr/bin/ssh ${SSH_OPTIONS} "$@"
