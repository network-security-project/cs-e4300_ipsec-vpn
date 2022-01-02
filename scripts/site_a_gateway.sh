#!/usr/bin/env bash

## NAT traffic going to the internet
route add default gw 172.16.16.1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

##setting up virtual network
ip link add eth0 type dummy
ip addr add 10.1.0.99/16 brd + dev eth0 label eth0:0

##redirect to cloud
iptables -t nat -A PREROUTING -p tcp -d 10.1.0.99 --dport 8080 -j DNAT --to 172.30.30.30:8080

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo 172.16.16.16 172.30.30.30 : PSK \"I9Z3jDbcZx5hJqU8HyaG4q2u9lQ7ZiUW0Yl63MEQJkpbHNH9x7HpH9vYyBVqo2nE9K2ZECFUH07emDzbf9CqinowTYC4HyZw101CMWm0mvBLQEWtlr05CFeJuqzucTtWuMqmQc7JWod19RxuFikQLRFV20nOXNLFDnfKe4EzbDRdB8Oldnm87E3JEP0GFhWIgjKGAyjIPMWjMgnldHCQpdXz9gLGjEqRj42Lp8UHtYaMi8QXMgqzD58rcOBWGlMa\" >> /etc/ipsec.secrets

## ipsec conf
cat > /etc/ipsec.conf <<EOL
config setup
        charondebug=all
        uniqueids=yes
        strictcrlpolicy=no
conn gateway-a-to-cloud
        type=tunnel
        keyexchange=ikev2
        authby=secret
        left=172.16.16.16
        leftsubnet=172.16.16.16/32
        right=172.30.30.30
        rightsubnet=172.30.30.30/32
        ike=aes256-sha2_256-modp2048!
        esp=aes256-sha2_256!
        dpdaction=restart
        auto=start
EOL

## restart ipsec
ipsec restart
