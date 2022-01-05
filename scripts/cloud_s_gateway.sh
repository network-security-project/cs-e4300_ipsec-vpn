#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 172.30.30.1

## Outbound NAT
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## FULL CONE TO SERVER
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --source 172.18.18.18 --dport 8080 -j DNAT --to-destination 10.1.0.2:9999
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --source 172.16.16.16 --dport 8080 -j DNAT --to-destination 10.1.0.2:9998

## Iptables rules
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT  #Accept ike trrafic
iptables -A INPUT -p esp -i enp0s8 --source 172.16.16.16 -j ACCEPT      #Acccept esp encapsulated trrafic from enp0s8
iptables -A INPUT -p esp -i enp0s8 --source 172.18.18.18 -j ACCEPT      #Acccept esp encapsulated trrafic from enp0s8
iptables -A INPUT -i enp0s3 -j ACCEPT                                   #Accept vagrant ssh trrafic from enp0s3
iptables -A INPUT -i enp0s9 --source 10.1.0.0/16 -j ACCEPT              #ACCEPT internal trrafic from enp0s9
iptables -P INPUT DROP                                                  #DROP everything else policy

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6


echo 172.30.30.30 172.16.16.16 : PSK \"I9Z3jDbcZx5hJqU8HyaG4q2u9lQ7ZiUW0Yl63MEQJkpbHNH9x7HpH9vYyBVqo2nE9K2ZECFUH07emDzbf9CqinowTYC4HyZw101CMWm0mvBLQEWtlr05CFeJuqzucTtWuMqmQc7JWod19RxuFikQLRFV20nOXNLFDnfKe4EzbDRdB8Oldnm87E3JEP0GFhWIgjKGAyjIPMWjMgnldHCQpdXz9gLGjEqRj42Lp8UHtYaMi8QXMgqzD58rcOBWGlMa\" >> /etc/ipsec.secrets
echo 172.30.30.30 172.18.18.18 : PSK \"fyTHSqL0jlh8hs3o1uz0I8BQ45Kt4C2DXIsTf9oLQ7a6bD0zchC0M6SROH673UHq8aG3xUFF8bhlPrUOSBLAi65Ntpzjm2SnSQ2hlAJI17i6yvcrhioGE8c5dgMlDcEiW89zB856Y1I3EkzfAldwdsNFrCDpHiNcg1haomLK2IOonEchfpXos7ff2jiPeezyfaUFAAGh1TcmlNHkg0OPbZknZmSPp8ll8vzXb0Gi6yEl5GKV4xDh9hzudbYG2VWZ\" >> /etc/ipsec.secrets

## ipsec conf
cat > /etc/ipsec.conf <<EOL
config setup
        charondebug=all
        uniqueids=yes
        strictcrlpolicy=no
conn cloud-vpn
        type=tunnel
        keyexchange=ikev2
        authby=secret
        leftfirewall=yes
        left=172.30.30.30
        leftsubnet=172.30.30.30/32
        ike=aes256-sha2_256-modp2048!
        esp=aes256-sha2_256!
        dpdaction=restart
        auto=start
conn gateway-a-vpn
        also=cloud-vpn
        right=172.16.16.16
        rightsubnet=172.16.16.16/32
conn gateway-b-vpn
        also=cloud-vpn
        right=172.18.18.18
        rightsubnet=172.18.18.18/32
EOL

## restart ipsec
ipsec restart