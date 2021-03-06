#!/bin/sh

if  [ ! -f /vpn/client.ovpn ] && [ -z "$VPNCONF" ]; then
    echo "Either /vpn/client.ovpn must exist or environment variable VPNCONF must be set."; exit 1;
elif [ -z "$HOSTIP" ]; then
    echo "Env variable HOSTIP must be set"; exit 1;
fi

if [ ! -f /vpn/client.ovpn ]; then
    echo $VPNCONF | base64 -d > /vpn/client.ovpn
fi

# Setup tun device
if [ ! -f /dev/net/tun ]; then
    echo "Setting up /dev/net/tun"
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

# Set IP tables rules
iptables -t nat -A PREROUTING -i eth0 -j DNAT --to-destination ${HOSTIP} > /dev/null 2>&1

## ...and check for privileged access real quickly like
if ! [ $? -eq 0 ]; then
    echo "Sorry, this container requires the '--cap-add=NET_ADMIN' and '--device /dev/net/tun' flag to be set in order to use for VPN functionality"
    exit 1;
fi

iptables -t nat -A PREROUTING -i tun0 -j DNAT --to-destination ${HOSTIP}
iptables -t nat -A POSTROUTING -j MASQUERADE


# VPN Loop
while [ true ]; do
    echo "------------ VPN Starts ------------"
    /usr/sbin/openvpn --config /vpn/client.ovpn --auth-nocache
    echo "------------ VPN exited ------------"
    sleep 10
done
