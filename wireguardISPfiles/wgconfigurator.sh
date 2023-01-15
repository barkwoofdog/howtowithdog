#!/bin/bash

#wireguard setup utility


#set file permissions. create file and add Private Key defintion to the file.
(umask 077 && printf "[Interface]\nPrivateKey = " | sudo tee /etc/wireguard/wg1.conf > /dev/null)

echo The following line is your Public Key

#generate public and private key. Append private to the file so that it fills the definition previously created
wg genkey | sudo tee -a /etc/wireguard/wg1.conf | wg pubkey | sudo tee /etc/wireguard/pubkey


#begin to define the host. If it is Listener/Forwarder then define listen port.
echo "Is this Host the VPS/Listening server? (y/n)"
read listenAnswer

if [ $listenAnswer = "y" ]; then

        echo please enter your Listen Port

        read userListen

        (printf "ListenPort = ") | tee -a /etc/wireguard/wg1.conf > /dev/null
        echo $userListen >>/etc/wireguard/wg1.conf

        echo Listen Port $userListen added.

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

     echo "PostUp = iptables -t nat -A PREROUTING -p tcp -i eth0 --match multiport '!' --dport 22 -j DNAT --to-destination HOMESERVER-WGIP; iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source THISHOST-IP
PostUp = iptables -t nat -A PREROUTING -p udp -i eth0 '!' --dport $userListen -j DNAT --to-destination HOMESERVER-WGIP;
PostDown = iptables -t nat -D PREROUTING -p tcp -i eth0 --match multiport '!' --dport 22 -j DNAT --to-destination HOMESERVER-WGIP; iptables -t nat -D POSTROUTING -o eth0 -j SNAT --to-source THISHOST-IP
PostDown = iptables -t nat -D PREROUTING -p udp -i eth0 '!' --dport $userListen -j DNAT --to-destination HOMESERVER-WGIP;" >> /etc/wireguard/wg1.conf

echo "" >> /etc/wireguard/wg1.conf

#adds peer definition
echo "[Peer]
PublicKey = 
AllowedIPs = /32" >> /etc/wireguard/wg1.conf

printf "\n"

echo "REMINDER. You need to add your Home Servers Wireguard IP and This Hosts IPv4 Address to the Firewall rules"
echo "These swaps are marked as HOMESERVER-WGIP (the IP of your other host inside wireguard) and THISHOST-IP"
echo "ALSO, be wary of your interface. This script has assumed that your public IPv4 is tied to eth0 "

printf "\n"

fi

#adds a peer definition for the home server, which is a little different from the Listener
if [ $listenAnswer = "n" ]; then
        echo "" >> /etc/wireguard/wg1.conf
        echo "[Peer]
PublicKey = 
AllowedIPs = 0.0.0.0/1, 128.0.0.0/1
Endpoint = 
PersistentKeepalive = 15" >> /etc/wireguard/wg1.conf
fi


echo "Dog's Wireguard Configurator has finished!"
