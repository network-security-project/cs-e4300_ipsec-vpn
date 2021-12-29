#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 10.1.0.1

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Install app
cd /home/vagrant/client_app
npm install

cat > config.json <<EOL
{
  "server_ip": "172.48.48.52",
  "server_port": "8080",
  "log_file": "/var/log/client.log"
}
EOL
