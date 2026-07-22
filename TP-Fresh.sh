#!/bin/bash

########################################
#
# TP Linux Setup Script
#
# Checks and sets up any Debian instance with 
# TP Flavor, tools, and scripts
# 
# Author: Tony Pajamas
# Date: 2/6/2022
#
########################################

########## Gobals ##########

x=""
optPATH="/opt/TonyPajamas"

########## Functions ##########

#### Color Sets

function sprint {

	local red=`tput setaf 1`
	local yellow=`tput setaf 3`
	local green=`tput setaf 2`
	local cyan=`tput setaf 6`
	local bold=`tput bold`
	local reset=`tput sgr0`

	#echo "${red} ${bold}[-] testings ${yellow}[!] testings ${green}[+] testings ${cyan}[?] testings"
	#echo "${reset}"

	if [ $# -lt 2 ]
	then
        echo "sprint error: Please call Sprint right!"
        exit
    fi

	case "$1" in

	+)  echo "${green}${bold}[+] ${reset}$2"
		echo "${reset}"
		;;
	-)  echo "${red} ${bold}[-] ${reset}$2"
	    echo "${reset}"
	    ;;
	!)  echo "${yellow}${bold}[!] ${reset}$2"
	    echo "${reset}"
	    ;;
	?)	echo "${cyan}${bold}[*] ${reset}$2"
	  	echo "${reset}"
		;;
	*)	echo ""
		;;
	esac
}

function initial {

	apt-get clean

	if apt-get update ; then
		clear
		echo ""
		sprint + "Initial apt Updates Complete"
	else
	    	sprint - "Inital Apt Failed"
	fi
	
	clear; echo "" ; echo "---- TP Items ----"; echo ""
	
	# Locate
	if [[ $(which locate) ]]; then
		sprint + "locate Installed: $(which locate)"
	else
		#apt-get install mlocate
		sprint - "Locate not installed: apt install mlocate"
	fi

	# wget
	if [[ $(which wget) ]]; then
		sprint + "WGET Installed: $(which wget)"
	else
		#apt-get install mlocate
		sprint - "WGET not installed: apt install wget"
	fi

	# ZSH
	if [[ $(which zsh) ]]; then
		sprint + "ZSH Installed: $(which zsh)"
	else
		#apt-get install mlocate
		sprint - "ZSH not installed: apt install zsh"
	fi

	# Python2
	if [[ $(which python) ]]; then
		sprint + "Python Installed: $(which python)"
	else
		#apt-get install mlocate
		sprint - "Python not installed: apt install python"
	fi

	# Python3
	if [[ $(which python3) ]]; then
		sprint + "Python3 Installed: $(which python3)"
	else
		#apt-get install mlocate
		sprint - "Python3 not installed: apt install python3"
	fi
}

function TP {

	if cat /etc/shells | grep bash >/dev/null; then
		cp /opt/TonyPajamas/bashrc /root/.bashrc
		sprint + "BASH installed: copied /opt/TonyPajamas/bashrc to /root/.bashrc"
	else
		sprint - "No BASH installed"
		return 1
	fi

	if cat /etc/shells | grep zsh >/dev/null; then
		cp /opt/TonyPajamas/zshrc /root/.zshrc
		sprint + "ZSH installed: copied /opt/TonyPajamas/zshrc to /root/.zshrc"
	else
		sprint - "No ZSH Installed"
		return 1
	fi

	mkdir -p /root/Works /root/Works/Mains
	chmod +rwx /root/Works/Mains
	sprint + "TP Folder Check: created /root/Works, /root/Works/Mains"
	ls /root/
	echo ""

}

function extras {

	echo "" ; echo "---- Extra Tools ----"; echo ""

	# pipx
	if command -v pipx &>/dev/null; then
		sprint + "pipx Installed: $(command -v pipx)"
	else
		sprint - "pipx not installed: apt-get install -y pipx"
	fi

	# jq
	if command -v jq &>/dev/null; then
		sprint + "jq Installed: $(command -v jq)"
	else
		sprint - "jq not installed: apt-get install -y jq"
	fi

	# SecLists
	if [ -d /usr/share/seclists ]; then
		sprint + "SecLists Installed: /usr/share/seclists"
	else
		sprint - "SecLists not installed: apt-get install -y seclists"
	fi
}


########## Main ##########

if [ "$(id -u)" -ne 0 ]; then
	sprint - "This script must be run as root. Please re-run with sudo or as root."
	exit 1
fi

initial
TP
extras
#banners

sprint + "COMPLETE: Move Onto SSH Full SSH Server"

