#!/bin/bash
set -e

echo 'Starting Vagrant VM for docker builds...'
# See README for why we do this.
echo "Building image..."
packer build packer.json

echo "Done!"
