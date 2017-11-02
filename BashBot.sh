#!/bin/bash

echo " ____            _       ____        _"
echo "| __ )  __ _ ___| |__   | __ )  ___ | |_"
echo "|  _ \ / _' / __| '_ \  |  _ \ / _ \| __|"
echo "| |_) | (_| \__ \ | | | | |_) | (_) | |_"
echo "|____/ \__,_|___/_| |_| |____/ \___/ \__|"
echo
echo "Script written by Samuel Langborgh and Ian McMenamin"
echo
echo "Note: This script will not complete the CyberPatriot Ubuntu Box,"
echo "but it will simplify a lot of the process"
echo
echo "Press any key to continue"
read -n 1 -s
echo

if [ "$EUID" -eq 0 ]; then
	apt-get update
	apt-get upgrade

	#Installs Synaptic
	apt-get install synaptic

	#Enables and configures firewall
	echo "Enabling and configuring firewall"
	ufw enable
	ufw default deny incoming
	ufw  default allow incoming
	echo

	#Enforces password policy
	echo "Checking if cracklib is installed"
	if [ -n "$( apt-cache policy libpam-cracklib )" ]; then
		echo "Cracklib installed"
	else
		echo "Cracklib is not installed"
		echo "Installing cracklib now"
		echo
		apt-get install libpam-cracklib
		echo "Cracklib installed"
		echo
	fi
	echo "Password policy to be implemented"
	echo

	#Disables guest account
	guestpath="/etc/lightdm/"
	guestfile="lightdm.conf"
	if [ -n "$( find $guestpath -name $guestfile )" ]; then
		echo "File $guestfile exists"
		echo "Checking to see if guest account is disabled"
		echo
		if [ -z $( grep allow-guest=false $guestpath$guestfile ) ]; then
			if [ -z $( grep allow-guest=true $guestpath$guestfile ) ]; then
				echo "Guest account status not specified"
				echo "Disabling guest account"
				echo -e "allow-guest=false" >> $guestpath$guestfile
				echo "Guest account disabled"
				echo
			else
				echo "Guest account enabled"
				echo "Disabling guest account"
				sed -i  's/true/false/g' $guestpath$guestfile
				echo "Guest account disabled"
				echo
			fi
		else
			echo "Guest account disabled"
			echo
		fi
	else
		echo "File $guestfile does not exist"
		echo "Creating file now"
		echo -e "[SeatDefaults]\nuser-session=ubuntu\ngreeter-session=unity-greeter\nallow-guest=false" > $guestpath$guestfile
		echo "$guestfile created and guest account disabled"
		echo
	fi
else
	echo "Please run as root"
	read -n 1 -s
	exit
fi
