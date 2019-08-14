#!/bin/sh

if  [ ! -f /vpn/client.ovpn ] && [ -z "$VPNCONF" ]; then
  echo "Either /vpn/client.ovpn must exist or environment variable VPNCONF must be set."; exit 1;
elif [ -z "$HOSTIP" ]; then
  echo "Env variable HOSTIP must be set"; exit 1;
fi

if [ ! -f /vpn/client.ovpn ]; then
  echo $VPNCONF | base64 -d > /vpn/client.ovpn
fi

# Set IP tables rules
iptables -t nat -A PREROUTING -i tun0 -j DNAT --to-destination ${HOSTIP} > /dev/null 2>&1

## ...and check for privileged access real quickly like
if ! [ $? -eq 0 ]; then
    echo "Sorry, this container requires the '--cap-add=NET_ADMIN' and '--device /dev/net/tun' flag to be set in order to use for VPN functionality"
    exit 1;
fi

iptables -t nat -A POSTROUTING -j MASQUERADE

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

# VPN Loop
while [ true ]; do
  echo "------------ VPN Starts ------------"
  /usr/sbin/openvpn --config /vpn/client.ovpn --auth-nocache
  echo "------------ VPN exited ------------"
  sleep 10
done