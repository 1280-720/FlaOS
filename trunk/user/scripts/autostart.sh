#!/bin/sh
#nvram set ntp_ready=0

mkdir -p /tmp/dnsmasq.dom
logger -t "To prevent dnsmasq from failing to start, create /tmp/dnsmasq.dom/"

smartdns_conf="/etc/storage/smartdns_custom.conf"
dnsmasq_Conf="/etc/storage/dnsmasq/dnsmasq.conf"
smartdns_Ini="/etc/storage/smartdns_conf.ini"
sdns_port=$(nvram get sdns_port)
if [ $(nvram get sdns_enable) = 1 ] ; then
   if [ -f "$smartdns_conf" ] ; then
       sed -i '/去广告/d' $smartdns_conf
       sed -i '/adbyby/d' $smartdns_conf
       sed -i '/no-resolv/d' "$dnsmasq_Conf"
       sed -i '/server=127.0.0.1#'"$sdns_portd"'/d' "$dnsmasq_Conf"
       sed -i '/port=0/d' "$dnsmasq_Conf"
       rm  -f "$smartdns_Ini"
   fi
logger -t "Autostart" "Starting SmartDNS"
/usr/bin/smartdns.sh start
fi


logger -t "Autostart" "Checking if router is connected to Internet"
count=0
while :
do
	ping -c 1 -W 1 -q 8.8.8.8 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		break
	fi
	sleep 5
	ping -c 1 -W 1 -q google.com 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		break
	fi
	sleep 5
	count=$((count+1))
	if [ $count -gt 18 ]; then
		break
	fi
done

if [ $(nvram get pppoemwan_enable) = 1 ] ; then
sleep 20
fi

if [ $(nvram get adbyby_enable) = 1 ] ; then
logger -t "Autostart" "Starting adbyby plus+"
/usr/bin/adbyby.sh start
fi

if [ $(nvram get aliddns_enable) = 1 ] ; then
logger -t "Autostart" "Starting aliddns"
/usr/bin/aliddns.sh start
fi

if [ $(nvram get ss_enable) = 1 ] ; then
logger -t "Autostart" "Starting Shadowshocks"
/usr/bin/shadowsocks.sh start
fi

if [ $(nvram get adg_enable) = 1 ] ; then
logger -t "Autostart" "Starting AdGuard Home"
/usr/bin/adguardhome.sh start
fi

if [ $(nvram get zerotier_enable) = 1 ] ; then
logger -t "Autostart" "Starting zerotier"
/usr/bin/zerotier.sh start
fi

if [ $(nvram get ddnsto_enable) = 1 ] ; then
logger -t "Autostart" "Starting ddnsto"
/usr/bin/ddnsto.sh start
fi

if [ $(nvram get aliyundrive_enable) = 1 ] ; then
logger -t "Autostart" "Starting Allyundrive"
/usr/bin/aliyundrive-webdav.sh start
fi

if [ $(nvram get wireguard_enable) = 1 ] ; then
logger -t "Autostart" "Starting Wireguard"
/usr/bin/wireguard.sh start
fi

if [ $(nvram get sqm_enable) = 1 ] ; then
logger -t "Autostart" "Starting SQM QOS"
/usr/lib/sqm/run.sh
fi

if [ $(nvram get frpc_enable) = 1 ] ; then
logger -t "Autostart" "Starting frp client"
/usr/bin/frp.sh start
fi
