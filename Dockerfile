FROM alpine:3.21.0

COPY ssh-singleton.sh /root/ssh-singleton.sh
COPY ack_server.py /root/acq_server.py

RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash python3 openssh && \
    chmod +x /root/ssh-singleton.sh

ENTRYPOINT [ "/root/ssh-singleton.sh" ]
