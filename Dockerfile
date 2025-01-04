FROM jenkins/agent:latest-alpine3.21-jdk21

ARG ssh_pub_key

USER root

RUN apk add openssh \
    && mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh \
    && echo "$ssh_pub_key" > /root/.ssh/authorized_keys \
    && chmod 0600 /root/.ssh/authorized_keys \
    && ssh-keygen -A \
    && echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && echo -e "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
    && sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config \
    && echo 'jenkins:jenkins' | chpasswd

USER jenkins

RUN mkdir -p /home/jenkins/.ssh \
    && chmod 0700 /home/jenkins \
    && chmod 0700 /home/jenkins/.ssh \
    && echo "$ssh_pub_key" > /home/jenkins/.ssh/authorized_keys \
    && chmod 0600 /home/jenkins/.ssh/authorized_keys \
    && ssh-keygen -A

USER root

EXPOSE 22

ENTRYPOINT [ "/usr/sbin/sshd", "-D", "-e" ]
