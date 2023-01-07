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

echo What is this Hosts IP Address in the Wireguard Network?

read addr

(printf "Address = ") | tee -a /etc/wireguard/wg1.conf > /dev/null

echo "$addr" >> /etc/wireguard/wg1.conf

if [ $listenAnswer = "y" ]; then
        #add firewall rules inside here, be sure to account for the IP variable

fi

#add peer definitions
