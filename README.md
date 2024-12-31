**connect to remote server, using ssh, while making sure only one client is connected**<br>
(for example to uses non-sharable resources among multiple automated tasks)

_the unicity detection is done by binding a port on the remote server (default 9999),_<br>
_the port must be available for binding on the remote server_

- only one client can connect using this command<br>
`docker run --rm -it [-v /path/to/.ssh:/root/.ssh] ssh-singleton <ssh args>`
- any other client shall fail with this error:<br>
`Error: remote port forwarding failed for listen port 9999`

**variables**:
- `SINGLETON_PORT=9999`<br>
remote port used to detect unicity 
- `VERBOSE=0`
- `DEFAULT_SSH_OPTIONS="-o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o TCPKeepAlive=yes"`<br>
ssh options used in addition to `<ssh args>`<br>
one can change those via env var, or override them via command line options (`<ssh args>`)

**examples**:

`docker run --rm -it -v ~/.ssh:/root/.ssh ssh-singleton user@remote echo 1`<br>
<br>
`docker run --rm -it -v ~/.ssh:/root/.ssh -e SINGLETON_PORT=8080 ssh-singleton user@remote`<br>
`docker run --rm -it -v ~/.ssh:/root/.ssh -e VERBOSE=1 ssh-singleton user@remote`<br>
`docker run --rm -it -v ~/.ssh:/root/.ssh ssh-singleton -o TcpKeepAlive=no user@remote`<br>
`docker run --rm -it -v ~/.ssh:/root/.ssh -e DEFAULT_SSH_OPTIONS=" " ssh-singleton user@remote`
