#!/bin/bash
set -e

echo 'Starting Vagrant VM for docker builds...'
# See README for why we do this.
cd docker_vm && vagrant up && vagrant halt && vagrant up && cd ..
alias docker='docker -H tcp://127.0.0.1:4243/'
export DOCKER_HOST="tcp://127.0.0.1:4243/"

echo "Building all images..."
packer build packer.json
cd docker_vm && vagranthalt && cd ..

echo "Done!"