# darkroom, for developing images


This script builds distribution images for VirtualBox, VMware Fusion, Amazon AWS (AMI), DigitalOcean, and Docker.

## Dependencies:

I'm running this on my Mac. Not sure how to configure it on Linux.

- [Packer](http://packer.io/)
- [Vagrant](http://www.vagrantup.com/)
- Vagrant AWS plugin (install by running `vagrant plugin install vagrant-aws`)
- [VMware Fusion](http://www.vmware.com/products/fusion/)
- [VirtualBox](https://www.virtualbox.org/)
- [Docker (client binary)](http://docs.docker.io/en/latest/installation/binaries/)


## Usage

First set these values in your environment:

    AWS_ACCESS_KEY
    AWS_SECRET_KEY
    DIGITALOCEAN_API_KEY
    DIGITALOCEAN_CLIENT_ID

Then add the GitHub deployment SSH keys at:

    ./ssh/id_rsa
    ./ssh/id_rsa.pub

Now run `./build.sh` and go make some tea. Images will be created with corresponding Vagrant boxes in the current directory. If all goes well, you should see something like this at the end.

    ==> Builds finished. The artifacts of successful builds are:
    --> digitalocean: A snapshot was created: 'inboxapp-server 1390117404' in region 'New York 1'
    --> digitalocean: 'digitalocean' provider box: inboxapp_digitalocean.box
    --> amazon-ebs: AMIs were created:

    us-west-2: ami-cc9cfdfc
    --> amazon-ebs: 'aws' provider box: inboxapp_aws.box
    --> virtualbox-iso: VM files in directory: output-virtualbox-iso
    --> virtualbox-iso: 'virtualbox' provider box: inboxapp_virtualbox.box
    --> vmware-iso: VM files in directory: output-vmware-iso
    --> vmware-iso: 'vmware' provider box: inboxapp_vmware.box
    --> docker: Exported Docker file: inboxapp_docker.box.tar


This sets up a few things and then calls `packer build packer.json`. You can enable debugging output by setting the environment variable `PACKER_LOG=1`.


## Notes on building the Docker image

Because of the dependencies (VMware Fusion specifically), I'm not sure this can run on non-Mac. Here's how I configured Docker to work with Packer.

Docker runs within it's own VirtualBox VM that is configured by the `Vagrantfile` in `docker_vm`. This does a few things:

- Shares the folder `/var/folders` with the host OS, which is used to transfer scripts.
- Fowards port 4243 to expose `docker` network commands.
- Modifies `/etc/init/docker` to include `-H tcp://0.0.0.0:4243` when starting the `docker` daemon.

I got the initial idea from [here](http://moinz.de/2013/09/running-the-docker-client-on-mac-os), though it required more changes.

When the build script begins, it sets the `DOCKER_HOST` environment variable to `tcp://127.0.0.1:4243/` and also runs `alias docker='docker -H tcp://127.0.0.1:4243/'`. This allows Packer to act as-if it's running on the local OS, but actually send commands to the remote instance within the VirtualBox VM. Kind of hacky, but it works.

## Future work

- [ ] Tighten up SSH configs for docker provisioner
- [ ] Cleanup/delete Docker VM after building
- [ ] Combine docker image with Dockerfile for startup metadata
- [ ] Auto-upload images to server (and Docker container to public index)
- [ ] Figure out a less hacky way to use a VM with docker. (see [dvm](https://github.com/fnichol/dvm) project)
- [ ] Fork Packer's docker provisioner and make it not suck so badly
- [ ] Figure out basic `Vagrantfile` for the various boxes
- [ ] Add Vagrant's public key for easier ssh access. Something like this...

```
{
  "type": "shell",
  "only": ["virtualbox-iso", "vmware-iso"],
  "inline": [
    "useradd vagrant",
    "echo 'vagrant    ALL = NOPASSWD: ALL' > /etc/sudoers",
    "mkdir -p /home/vagrant/.ssh",
    "wget --no-check-certificate -O authorized_keys 'https://github. /mitchellh/vagrant/raw/master/keys/vagrant.pub'",
    "mv authorized_keys ~/vagrant/.ssh/",
    "chown -R vagrant ~/vagrant/.ssh"
  ]
},
```


