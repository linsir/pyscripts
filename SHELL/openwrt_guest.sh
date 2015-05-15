#!/bin/sh
 
# This is supposed to be run on openwrt
 
# Written by Stanislav German-Evtushenko, 2014
# Based on http://wiki.openwrt.org/doc/recipes/guest-wlan
 
# Configure guest network
uci delete network.guest
uci set network.guest=interface
uci set network.guest.proto=static
uci set network.guest.ipaddr=192.168.0.254
uci set network.guest.netmask=255.255.255.0
 
# Configure guest Wi-Fi
uci delete wireless.guest
uci set wireless.guest=wifi-iface
uci set wireless.guest.device=radio0
uci set wireless.guest.mode=ap
uci set wireless.guest.network=guest
uci set wireless.guest.ssid=FreeWiFi
uci set wireless.guest.encryption=none
# uci set wireless.guest.dhcp_option '118.114.52.33'
 
# Configure DHCP for guest network
uci delete dhcp.guest
uci set dhcp.guest=dhcp
uci set dhcp.guest.interface=guest
uci set dhcp.guest.start=1
uci set dhcp.guest.limit=30
uci set dhcp.guest.leasetime=1h
 
# Configure firewall for guest network
## Configure guest zone
uci delete firewall.guest_zone
uci set firewall.guest_zone=zone
uci set firewall.guest_zone.name=guest
uci set firewall.guest_zone.network=guest
uci set firewall.guest_zone.input=REJECT
uci set firewall.guest_zone.forward=REJECT
uci set firewall.guest_zone.output=ACCEPT
## Allow Guest -> Internet
uci delete firewall.guest_forwarding
uci set firewall.guest_forwarding=forwarding
uci set firewall.guest_forwarding.src=guest
uci set firewall.guest_forwarding.dest=wan
## Allow DNS Guest -> Router
uci delete firewall.guest_rule_dns
uci set firewall.guest_rule_dns=rule
uci set firewall.guest_rule_dns.name='Allow DNS Queries'
uci set firewall.guest_rule_dns.src=guest
uci set firewall.guest_rule_dns.dest_port=53
uci set firewall.guest_rule_dns.proto=udp
uci set firewall.guest_rule_dns.target=ACCEPT
## Allow DHCP Guest -> Router
uci delete firewall.guest_rule_dhcp
uci set firewall.guest_rule_dhcp=rule
uci set firewall.guest_rule_dhcp.name='Allow DHCP request'
uci set firewall.guest_rule_dhcp.src=guest
uci set firewall.guest_rule_dhcp.src_port=68
uci set firewall.guest_rule_dhcp.dest_port=67
uci set firewall.guest_rule_dhcp.proto=udp
uci set firewall.guest_rule_dhcp.target=ACCEPT

# config redirect
# uci delete firewall.redirect
# uci set firewall.redirect=redirect
# uci set firewall.redirect.name='proxy'
# uci set firewall.redirect.src=guest
# uci set firewall.redirect.src_dport=80
# uci set firewall.redirect.proto=tcp
# uci set firewall.redirect.dest_ip=118.114.52.47
# uci set firewall.redirect.dest_port=3128
 
uci commit
 
# Configure wshaper (optional)
opkg update
opkg install wshaper
uci set wshaper.settings=wshaper
uci set wshaper.settings.network=guest
uci set wshaper.settings.downlink=500
uci set wshaper.settings.uplink=2000
## Work around for https://github.com/openwrt/packages/issues/565 (wshaper: settings are not applied on boot)
echo -e '#!/bin/sh\n\n[ "$ACTION" = ifup ] && /etc/init.d/wshaper enabled && /etc/init.d/wshaper start || exit 0' > /etc/hotplug.d/iface/10-wshaper
 
uci commit



# Enable the new wireless network
/etc/init.d/network restart
# Restart the firewall
/etc/init.d/firewall restart
# Restart the DHCP service
/etc/init.d/dnsmasq restart
# Start traffic shaping
/etc/init.d/wshaper start
# Make traffic shaping permanent
/etc/init.d/wshaper enable