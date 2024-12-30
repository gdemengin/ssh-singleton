# connect to remote server using ssh while making sure only one client is connected
# for example to uses non-sharable resources among multiple automated tasks

# only one task can connect using this command
`docker run --rm -it -v ./.ssh:/root/.ssh ssh-singleton [ssh options] user@remote [command]`

# any other task shall fail with this error:
`docker run --rm -it -v ./.ssh:/root/.ssh ssh-singleton [ssh options] user@remote [command]`
`Error: remote port forwarding failed for listen port 9999`

# the default port is 9999, it must not be available for binding on remote server
# to use a different port, use env var SINGLETON_PORT
`docker run --rm -it -v ./.ssh:/root/.ssh -e SINGLETON_PORT=8080 ssh-singleton [ssh options] user@remote [command]`
