# Docker OpenVPN Proxy

This container is designed to proxy traffic destined to the tun0 port of the OpenVPN client within the container to a host on your container's LAN.

## This does what? (Use Case)

So my reasoning behind this is simple enough - bypass firewall restrictions from my ISP. I have a dynamic IP at home, and they block some ports I'd like to be able to use. So, I pay for a cheap VPS and have an OpenVPN server installed on it.

I used to use [nginx-proxy](https://github.com/jwilder/nginx-proxy) on a single docker host, and just had an OpenVPN client running as a service. This worked fine, until I decided to make the plunge into kubernetes.

So now, I use this container to proxy requests to my on-prem kubernetes ingress load balancer IP.

## Usage

Its simple enough. To provide the openvpn config, either mount a file called `/vpn/client.ovpn` or base64 encode a file and pass it as an environment variable called `VPNCONF`. Then use an environment variable `HOSTIP` for the host you want to proxy.

```bash
# Base64 encoding the file
VPNCONF=$( cat client.ovpn | base64 -w 0 )
docker run -d --cap-add=NET_ADMIN --device /dev/net/tun -e VPNCONF=$VPNCONF -e HOSTIP=192.168.1.1 soarinferret/openvpnproxy

# Mount the file
docker run -d --cap-add=NET_ADMIN --device /dev/net/tun -v ${PWD}/test.ovpn:/vpn/client.ovpn -e HOSTIP=192.168.1.1 soarinferret/openvpnproxy
```

### Kubernetes

I mentioned above that I actually use this in Kubernetes. Well, provided here is a _very_ simple helm chart.

```bash
VPNCONF=$( cat client.ovpn | base64 -w 0 )

helm install --name openvpnproxy ./openvpnproxy-helm \
     --set vpnConf=$VPNCONF,hostip=192.168.1.1
```
