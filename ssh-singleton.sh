#!/bin/sh

set -e

# remote port on the destination: only one ssh session can bind it
# make sure all clients use the same remote port
SINGLETON_PORT=${SINGLETON_PORT:-9999}

# local port: no real server listening needed
FAKE_LOCAL_PORT=8888

DEFAULT_SSH_OPTIONS="${DEFAULT_SSH_OPTIONS:--o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o TCPKeepAlive=yes}"

[ $(echo "${DEFAULT_SSH_OPTIONS} $*" | grep ExitOnForwardFailure | wc -l) != 0 ] && echo "ERROR: please do not try to set ssh option ExitOnForwardFailure in command line" >&2 && exit 1

[ "${VERBOSE}" ==  "1" ] && set -x
/usr/bin/ssh ${DEFAULT_SSH_OPTIONS} -R ${FAKE_LOCAL_PORT}:${SINGLETON_PORT} -o ExitOnForwardFailure=yes $*
