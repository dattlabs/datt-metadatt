#!/bin/bash

sudo apt-get update
sudo apt-get install docker.io
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io

sudo apt-get install make

sudo gpasswd -a ${USER} docker
sudo service docker restart

wget https://dl.bintray.com/mitchellh/serf/0.6.1_linux_amd64.zip
apt-get install unzip
unzip 0.3.0_linux_amd64.zip
sudo mv serf /usr/local/bin
rm 0.6.1_linux_amd64.zip
