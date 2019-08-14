FROM alpine:latest

RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add iptables openvpn && \
    rm -rf /tmp/* && \
    mkdir /vpn

COPY openvpn.sh /

# Set permissions
RUN chmod +x /openvpn.sh

CMD [ "/openvpn.sh" ]