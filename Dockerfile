FROM alpine:3.21.0

# remote port on the destination: only one ssh session can bind it
# make sure all clients use the same remote port
ENV SINGLETON_PORT=9999

# local port: no real server listening needed
ENV FAKE_LOCAL_PORT=8888

RUN apk add --no-cache openssh

ENTRYPOINT [ "/usr/bin/ssh", "-R", "${FAKE_LOCAL_PORT}:${SINGLETON_PORT}", "-o", "ExitOnForwardFailure=yes", "-o", "LogLevel=ERROR", "-o", "UserKnownHostsFile=/dev/null", "-o", "StrictHostKeyChecking=no", "-o", "TCPKeepAlive=yes" ]
