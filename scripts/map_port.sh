#!/bin/bash

if [[ -n `which boot2docker` ]]; then
  echo Mapping port: $1
  VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "tcp-port$1" &>/dev/null;
  VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "udp-port$1" &>/dev/null;

  VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port$1,tcp,,$1,,$1" &>/dev/null;
  VBoxManage modifyvm "boot2docker-vm" --natpf1 "udp-port$1,udp,,$1,,$1" &>/dev/null;
fi
