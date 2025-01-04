#!/bin/bash

set -ex 

docker build -t ssh-server --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" .
