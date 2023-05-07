#!/bin/sh
#20200426 chongshengB
#20210410 xumng123
PROG=/usr/bin/zerotier-one
PROGCLI=/usr/bin/zerotier-cli
PROGIDT=/usr/bin/zerotier-idtool
config_path="/etc/storage/zerotier-one"
start_instance() {
	cfg="$1"
	echo $cfg
	port=""
	args=""
	moonid="$(nvram get zerotier_moonid)"
	secret="$(nvram get zerotier_secret)"
	enablemoonserv="$(nvram get zerotiermoon_enable)"
	if [ ! -d "$config_path" ]; then
		mkdir -p $config_path
	fi
	mkdir -p $config_path/networks.d
	if [ -n "$port" ]; then
		args="$args -p$port"
	fi
	if [ -z "$secret" ]; then
		logger -t "zerotier" "Device key is empty, generating key, please wait..."
		sf="$config_path/identity.secret"
		pf="$config_path/identity.public"
		$PROGIDT generate "$sf" "$pf"  >/dev/null
		[ $? -ne 0 ] && return 1
		secret="$(cat $sf)"
		#rm "$sf"
		nvram set zerotier_secret="$secret"
		nvram commit
	fi
	if [ -n "$secret" ]; then
		logger -t "zerotier" "Key found, writing to file, please wait..."
		echo "$secret" >$config_path/identity.secret
		$PROGIDT getpublic $config_path/identity.secret >$config_path/identity.public
		#rm -f $config_path/identity.public
	fi

	add_join $(nvram get zerotier_id)

	$PROG $args $config_path >/dev/null 2>&1 &
		
	rules
	
	if [ -n "$moonid" ]; then
		$PROGCLI -D$config_path orbit $moonid $moonid
		logger -t "zerotier" "orbit moonid $moonid ok!"
	fi


	if [ -n "$enablemoonserv" ]; then
		if [ "$enablemoonserv" -eq "1" ]; then
			logger -t "zerotier" "Create moon start"
			creat_moon
		else
			logger -t "zerotier" "Remove moon start"
			remove_moon
		fi
	fi
}

add_join() {
		touch $config_path/networks.d/$1.conf
}


rules() {
	while [ "$(ifconfig | grep zt | awk '{print $1}')" = "" ]; do
		sleep 1
	done
	nat_enable=$(nvram get zerotier_nat)
	zt0=$(ifconfig | grep zt | awk '{print $1}')
	logger -t "zerotier" "zt interface $zt0 is started!"
	del_rules
	iptables -A INPUT -i $zt0 -j ACCEPT
	iptables -A FORWARD -i $zt0 -o $zt0 -j ACCEPT
	iptables -A FORWARD -i $zt0 -j ACCEPT
	if [ $nat_enable -eq 1 ]; then
		iptables -t nat -A POSTROUTING -o $zt0 -j MASQUERADE
		ip_segment="$(ip route | grep "dev $zt0 proto" | awk '{print $1}')"
		iptables -t nat -A POSTROUTING -s $ip_segment -j MASQUERADE
		zero_route "add"
	fi

}


del_rules() {
	zt0=$(ifconfig | grep zt | awk '{print $1}')
	ip_segment=`ip route | grep "dev $zt0  proto" | awk '{print $1}'`
	iptables -D FORWARD -i $zt0 -j ACCEPT 2>/dev/null
	iptables -D FORWARD -o $zt0 -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i $zt0 -o $zt0 -j ACCEPT
	iptables -D INPUT -i $zt0 -j ACCEPT 2>/dev/null
	iptables -t nat -D POSTROUTING -o $zt0 -j MASQUERADE 2>/dev/null
	iptables -t nat -D POSTROUTING -s $ip_segment -j MASQUERADE 2>/dev/null
}

zero_route(){
	rulesnum=`nvram get zero_staticnum_x`
	for i in $(seq 1 $rulesnum)
	do
		j=`expr $i - 1`
		route_enable=`nvram get zero_enable_x$j`
		zero_ip=`nvram get zero_ip_x$j`
		zero_route=`nvram get zero_route_x$j`
		if [ "$1" = "add" ]; then
			if [ $route_enable -ne 0 ]; then
				ip route add $zero_ip via $zero_route dev $zt0
				echo "$zt0"
			fi
		else
			ip route del $zero_ip via $zero_route dev $zt0
		fi
	done
}

start_zero() {
	logger -t "zerotier" "Starting service..."
	kill_z
	start_instance 'zerotier'

}
kill_z() {
	zerotier_process=$(pidof zerotier-one)
	if [ -n "$zerotier_process" ]; then
		logger -t "zerotier" "Stopping service..."
		killall zerotier-one >/dev/null 2>&1
		kill -9 "$zerotier_process" >/dev/null 2>&1
	fi
}
stop_zero() {
	del_rules
	zero_route "del"
	kill_z
	rm -rf $config_path
}

#Create a moon node
creat_moon(){
	moonip="$(nvram get zerotiermoon_ip)"
	logger -t "zerotier" "moonip $moonip"
	#Check for legal ip
	regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
	ckStep2=`echo $moonip | egrep $regex | wc -l`

	logger -t "zerotier" "Building ZeroTier Moon transit server and generating moon configuration file..."
	if [ -z "$moonip" ]; then
		#Get wan ip automatically
		ip_addr=`ifconfig -a ppp0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
	#elif [ $ckStep2 -eq 0 ]; then
		#No ip
	#	ip_addr = `curl $moonip`
	else
		ip_addr=$moonip
	fi
	logger -t "zerotier" "moonip $ip_addr"
	if [ -e $config_path/identity.public ]; then

		$PROGIDT initmoon $config_path/identity.public > $config_path/moon.json
		if `sed -i "s/\[\]/\[ \"$ip_addr\/9993\" \]/" $config_path/moon.json >/dev/null 2>/dev/null`; then
			logger -t "zerotier" "Generate moon configuration file successfully!"
		else
			logger -t "zerotier" "Failed to generate moon configuration file!"
		fi

		logger -t "zerotier" "Generating signature file..."
		cd $config_path
		pwd
		$PROGIDT genmoon $config_path/moon.json
		[ $? -ne 0 ] && return 1
		logger -t "zerotier" "Creating a moons.d folder and moving the signature file into the folder..."
		if [ ! -d "$config_path/moons.d" ]; then
			mkdir -p $config_path/moons.d
		fi
		
		#服务器加入moon server
		mv $config_path/*.moon $config_path/moons.d/ >/dev/null 2>&1
		logger -t "zerotier" "ZeroTier Moon has been created!"

		zmoonid=`cat moon.json | awk -F "[id]" '/"id"/{print$0}'` >/dev/null 2>&1
		zmoonid=`echo $zmoonid | awk -F "[:]" '/"id"/{print$2}'` >/dev/null 2>&1
		zmoonid=`echo $zmoonid | tr -d '"|,'`

		nvram set zerotiermoon_id="$zmoonid"
		nvram commit
	else
		logger -t "zerotier" "identity.public does not exist!"
	fi
}

remove_moon(){
	zmoonid="$(nvram get zerotiermoon_id)"
	
	if [ ! -n "$zmoonid"]; then
		rm -f $config_path/moons.d/000000$zmoonid.moon
		rm -f $config_path/moon.json
		nvram set zerotiermoon_id=""
		nvram commit
	fi
}

case $1 in
start)
	start_zero
	;;
stop)
	stop_zero
	;;
*)
	echo "check"
	#exit 0
	;;
esac
