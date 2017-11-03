#!/bin/bash

RED='\033[0;31m' #Alert
BLUE='\033[0;34m' #Status message
GREEN='\033[0;32m' #Success
ORANGE='\033[0;33m' #Input
NC='\033[0m'

echo " ____            _       ____        _"
echo "| __ )  __ _ ___| |__   | __ )  ___ | |_"
echo "|  _ \ / _' / __| '_ \  |  _ \ / _ \| __|"
echo "| |_) | (_| \__ \ | | | | |_) | (_) | |_"
echo "|____/ \__,_|___/_| |_| |____/ \___/ \__|"
echo
echo -e "${BLUE}Script written by Samuel Langborgh and Ian McMenamin"
echo
echo -e "${RED}Note: This script will not complete the CyberPatriot Ubuntu Box,"
echo -e "but it will simplify a lot of the process${NC}"
echo
echo -e "${ORANGE}Press any key to continue"
read -n 1 -s
echo

if [ "$EUID" -eq 0 ]; then
	echo -e "${BLUE}Checking for and running system updates${NC}"
	apt-get update
	apt-get upgrade
	echo

	#Installs Synaptic
	echo -e "${BLUE}Installing Synaptic${NC}"
	apt-get install synaptic
	echo
	#Enables and configures firewall
	echo -e "${BLUE}Enabling and configuring firewall${NC}"
	ufw enable
	ufw default deny incoming
	ufw  default allow incoming
	echo

	#Enforces password policy
	echo -e "${BLUE}Checking if cracklib is installed"
	if [ -n "$( apt-cache policy libpam-cracklib )" ]; then
		echo -e "${GREEN}Cracklib installed"
	else
		echo -e "${RED}Cracklib is not installed"
		echo -e "${BLUE}Installing cracklib now${NC}"
		apt-get install libpam-cracklib
		echo -e "${GREEN}Cracklib installed"
		echo
	fi
	echo -e "${RED}Password policy to be implemented"
	echo

	#Disables guest account
	guestpath="/etc/lightdm/"
	guestfile="lightdm.conf"
	echo -e "${BLUE}Checking if $guestfile exists"
	if [ -n "$( find $guestpath -name $guestfile )" ]; then
		echo -e "${GREEN}File $guestfile exists"
		echo -e "${BLUE}Checking to see if guest account is disabled"
		if [ -z $( grep allow-guest=false $guestpath$guestfile ) ]; then
			if [ -z $( grep allow-guest=true $guestpath$guestfile ) ]; then
				echo -e "${RED}Guest account enabled"
				echo -e "${BLUE}Disabling guest account"
				echo "allow-guest=false" >> $guestpath$guestfile
				echo -e "${GREEN}Guest account disabled"
				echo
			else
				echo -e "${RED}Guest account enabled"
				echo -e "${BLUE}Disabling guest account"
				sed -i  's/true/false/g' $guestpath$guestfile
				echo -e "${GREEN}Guest account disabled"
				echo
			fi
		else
			echo -e "${GREEN}Guest account disabled"
			echo
		fi
	else
		echo -e "${RED}File $guestfile does not exist"
		echo -e "${BLUE}Creating $guestfile now"
		echo -e "[SeatDefaults]\nuser-session=ubuntu\ngreeter-session=unity-greeter\nallow-guest=false" > $guestpath$guestfile
		echo -e "${GREEN}$guestfile created and guest account disabled"
		echo
	fi

	#Secures SSH
	sshpath="/etc/ssh/"
	sshconfig="sshd_config"
	echo -e "${BLUE}Securing SSH"
	if [ -n "$( find $sshpath -name $sshconfig )" ]; then
		echo -e "${GREEN}File $sshconfig exists"
		echo -e "${BLUE}Checking if SSH root login is disabled"
		if [ -n "$( grep 'PermitRootLogin yes' $sshpath$sshconfig )" ]; then
			echo -e "${RED}SSH root login enabled"
			echo -e "${BLUE}Disabling SSH root login"
			sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' $sshpath$sshconfig
			echo -e "${GREEN}SSH root login disabled"
		else
			if [ -n "$( grep 'PermitRootLogin no' $sshpath$sshconfig )" ]; then
				echo -e "${GREEN}SSH root login disabled"
			else
				echo -e "${RED}SSH root login preferences not specified"
			fi
		fi
		echo
		echo -e "${BLUE}Checking if Protocol 2 is enabled"
		if [ -n "$( grep 'Protocol 2' $sshpath$sshconfig )" ]; then
			echo -e "${GREEN}Protocol 2 enabled"
		else
			echo -e "${RED}Protocol 1 enabled"
			echo -e "${BLUE}Enabling Protocol 2"
			sed -i 's/Protocol 1/Protocol 2/g' $sshpath$sshconfig
			echo -e "${GREEN}Protocol 2 enabled"
		fi
		echo
		echo -e "${BLUE}Checking if PAM is enabled"
		if [ -n "$( grep 'UsePAM yes' $sshpath$sshconfig )" ]; then
			echo -e "${GREEN}PAM enabled"
		else
			if [ -n "$( grep 'UsePAM no' $sshpath$sshconfig )" ]; then
				echo -e "${RED}PAM disabled"
				echo -e "${BLUE}Enabling PAM"
				sed -i 's/UsePAM no/UsePAM yes/g' $sshpath$sshconfig
				echo -e "${GREEN}PAM enabled"
			else
				echo -e "${RED}PAM settings not specified"
				echo -e "${BLUE}Enabling PAM"
				echo "UsePAM yes" >> $sshpath$sshconfig
				echo -e "${GREEN}PAM enabled"
			fi
		fi
		echo
		echo -e "${ORANGE}Please input allowed SSH users (Enter 'none' if no SSH users are desired)"
		read users
		if [ "$users" = "none" ]; then
			if [ -n "$( grep 'AllowUsers *' $sshpath$sshconfig )" ]; then
				echo -e "${BLUE}Removing all SSH users"
				sed -i '/AllowUsers/d' $sshpath$sshconfig
				echo -e "${GREEN}All SSH users removed"
			else
				echo -e "${GREEN}No Authorized SSH users"
			fi
		else
			if [ -n "$( grep 'AllowUsers *' $sshpath$sshconfig )" ]; then
				echo -e "${BLUE}Replacing existing SSH users"
				sed -i "/AllowUsers/c\AllowUsers $users" $sshpath$sshconfig
				echo -e "${GREEN}SSH users replaced"
			else
				echo -e "${BLUE}Adding SSH users"
				echo "AllowUsers $users" >> $sshpath$sshconfig
				echo -e "${GREEN}SSH users added"
			fi
		fi
	else
		echo -e "${RED}File $sshconfig does not exist"
		echo
	fi
else
	echo -e "${RED}Please run as root"
	read -n 1 -s
	exit
fi
