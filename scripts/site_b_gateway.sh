#!/usr/bin/env bash

## NAT traffic going to the internet
route add default gw 172.18.18.1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

##setting up virtual network
ip link add eth0 type dummy
ip addr add 10.1.0.99/16 brd + dev eth0 label eth0:0

##redirect to cloud
iptables -t nat -A PREROUTING -p tcp -d 10.1.0.99 --dport 8080 -j DNAT --to 172.30.30.30:8080

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo 172.18.18.18 172.30.30.30 : PSK \"fyTHSqL0jlh8hs3o1uz0I8BQ45Kt4C2DXIsTf9oLQ7a6bD0zchC0M6SROH673UHq8aG3xUFF8bhlPrUOSBLAi65Ntpzjm2SnSQ2hlAJI17i6yvcrhioGE8c5dgMlDcEiW89zB856Y1I3EkzfAldwdsNFrCDpHiNcg1haomLK2IOonEchfpXos7ff2jiPeezyfaUFAAGh1TcmlNHkg0OPbZknZmSPp8ll8vzXb0Gi6yEl5GKV4xDh9hzudbYG2VWZ\" >> /etc/ipsec.secrets

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
        left=172.18.18.18
        leftsubnet=172.18.18.18/32
        right=172.30.30.30
        rightsubnet=172.30.30.30/32
        ike=aes256-sha2_256-modp2048!
        esp=aes256-sha2_256!
        dpdaction=restart
        auto=start
EOL

## restart ipsec
ipsec restart