**connect to remote server, using ssh, while making sure only one client is connected**<br>
(for example to uses non-sharable resources among multiple automated tasks)

_the unicity detection is done by binding a port on the remote server (default 9999),_<br>
_the port must be available for binding on the remote server_

- only one client can connect using this command<br>
`docker run --rm -it [-v </path/to/.ssh:/root/.ssh>] ssh-singleton <ssh args>`<br>
- any other client trying to connect at the same time shall fail with this error:<br>
`Error: remote port forwarding failed for listen port 9999`

Note: if/when ssh dies, children processes shall receive HUP signal to end their lives.

**limitations on ssh options**
- ssh option 'ExitOnForwardFailure' is set to 'yes' and cannot be overriden
- ssh option '-t -t' is used and cannot be overriden (option '-T' is forbidden)
- the remote server must allow port forwarding (AllowTcpForwarding=yes in sshd_config)


**variables**:
- `SINGLETON_PORT=9999`<br>
remote port used to detect unicity. must be available for binding on the remote server
- `VERBOSE=1`
- `DEFAULT_SSH_OPTIONS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o TCPKeepAlive=yes"`<br>
default ssh options to use.


**examples**:

`docker run --rm -it -v ~/.ssh/id_rsa:/ssh_key ssh-singleton -i /ssh_key user@remote echo "I am alone on remote host"`<br>
`docker run --rm -it -v ~/.ssh/:/root/.ssh ssh-singleton user@remote echo "I am alone on remote host"`


**practical use case: share host between multiple jenkins instances**

Say, 2 jenkins instances run tasks, and sometimes need to access the same host "shared-host" to use a precious resource,<br>
but they cannot use the resource at the same time.
- On both jenkins server configure a docker label 'singleton-shared-host' with
  - image: `ssh-singleton:latest`
  - entrypoint arguments: the usual arguments for jenkins agents with ssh parameters in front of it
    - `-i`
    - `/path/to/ssh_key`
    - `jenkins@shared-host`
    - `set -x && (killall -9 java || true) && rm -f agent.jar && wget ${JENKINS_URL}jnlpJars/agent.jar && /opt/java/openjdk/bin/java -jar agent.jar -url ${JENKINS_URL} -secret ${JNLP_SECRET} -name ${NODE_NAME}`
- when multiple jobs run simultaneously on both instances, only one job shall access the host at any given time

Note: the java agent shall get a signal and die when ssh session dies<br>
however, the `killall` command is a necessary precaution to make sure the resource is not accessed by a remaining process<br>
and more precautions might be needed to kill other remaining process started by the jenkins java agent
