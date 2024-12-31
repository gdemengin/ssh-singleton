FROM alpine:3.21.0

COPY ssh-singleton.sh /root/ssh-singleton.sh

RUN apk update && \
    apk upgrade && \
    apk add --no-cache openssh && \
    chmod +x /root/ssh-singleton.sh

ENTRYPOINT [ "/root/ssh-singleton.sh" ]
