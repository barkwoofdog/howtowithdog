#!/bin/bash

#wireguard setup utility


#set file permissions. create file and add Private Key value to the file.
(umask 077 && printf "[Interface] \n PrivateKey = " | sudo tee /etc/wireguard/wg1.conf) > /dev/null)

echo The following line is your Public Key\n

#generate public and private key. Append private to last line in the config file.
wg genkey | sudo tee -a /etc/wireguard/wg1.conf | wg pubkey | sudo tee /etc/wireguard/pubkey

echo "Is this Host the VPS/Listening server? (y/n)"
read listenAnswer

if [ $listenAnswer = "y" ]; then

        echo please enter your Listen Port

        read userListen

        (printf "ListenPort = ") | tee -a /etc/wireguard/wg1.conf > /dev/null
        echo $userListen >>/etc/wireguard/wg1.conf

        echo Listen Port $listenAnswer added.

fi

printf "\n"

echo What is this Hosts IP Address in the Wireguard Network? [INCLUDE SUBNET MASK]

read addr

(printf "Address = ") | tee -a /etc/wireguard/wg1.conf > /dev/null

echo "$addr" >> /etc/wireguard/wg1.conf


#adds forwarding rules for the host firewall, in this case iptables
#user will need to add their forward host into here
if [ $listenAnswer = "y" ]; then

     echo "" >> /etc/wireguard/wg1.conf   

     echo "PostUp = iptables -t nat -A PREROUTING -p tcp -i eth0 --match multiport '!' --dports 22 -j DNAT --to-destination HOMESERVER-WGIP; iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source THISHOST-IP
PostUp = iptables -t nat -A PREROUTING -p udp -i eth0 '!' --dport $userListen -j DNAT --to-destination HOMESERVER-WGIP;

PostDown = iptables -t nat -D PREROUTING -p tcp -i eth0 --match multiport '!' --dports 22 -j DNAT --to-destination HOMESERVER-WGIP; iptables -t nat -D POSTROUTING -o eth0 -j SNAT --to-source THISHOST-IP
PostDown = iptables -t nat -D PREROUTING -p udp -i eth0 '!' --dport $userListen -j DNAT --to-destination HOMESERVER-WGIP;" >> /etc/wireguard/wg1.conf

printf "\n"

echo "REMINDER. You need to add your Home Servers Wireguard IP and This Host's IPv4 Address to the Firewall rules "
echo "ALSO, be wary of your interface. This script has assumed that your public IPv4 is tied to eth0 "

printf "\n"

fi
 
#adds a peer definition for the other server.

echo "[Peer]
PublicKey = 
AllowedIPs = /32" >> /etc/wireguard/wg1.conf


echo "Dog's Wireguard Configurator has finished!"

