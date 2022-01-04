#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 10.1.0.1

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6


##install docker
cd /home/vagrant
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

##build image
cd /home/vagrant/server_app
docker build . -t cloud/node-web-app

##run containers
docker run -p 9999:8080 -d cloud/node-web-app
docker run -p 9998:8080 -d cloud/node-web-app
