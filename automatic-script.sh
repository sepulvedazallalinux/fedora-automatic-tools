#!/bin/bash
#Create and modify by Brian Dao - D3spere@ux
#This tool uses for Exercises LPI (Linux Professional Institute) or person who working in Fedora distro field.
#########################################################4####################################################

#Global Variables (GV)
		BLUE='\033[1;34m'
		RED='\033[1;31m'
		YELLOW='\033[1;33m'
		NC='\033[0m'
		CYAN='\033[1;36m'
		BLINK='\033[5m'

		PAKTC="${BLINK}${YELLOW}Press ${RED}ANY KEY${YELLOW} to continue..."${NC}
		PAKTGB="${BLINK}${YELLOW}Press ${RED}ANY KEY${YELLOW} to go back..."${NC}
#Code to read from keyboard without return
		READAK="read -n 1"
		
#########################################################4####################################################

#Export GV
		export BLUE
		export RED
		export YELLOW
		export NC
		export CYAN
		export BLINK
		
		export PAKTC
		export PAKTGB
		export READAK
		
##############################################################################################################

#Banner Setup
f_banner(){
		f_root
        echo
        echo -e "${YELLOW}
            ######################################################################
            #            _        _    _    _    _     _    __     __            #
            #           | |      | |  | \  | |  | |   | |   \ \   / /            #
            #           | |      | |  |  \ | |  | |   | |    \ \_/ /             #
            #           | |      | |  |   \| |  | |   | |    /  _  \             #
            #           | |___   | |  | |\   |  | |___| |   / /   \ \            #
            #           |_____|  |_|  |_| \__|  |_______|  /_/     \_\           #
            #           ${RED}By D3spere@ux${YELLOW}                                            #
            #                                                                    #
            ###################################################################### "${NC}   
        echo
        echo
       }
	export -f f_banner

##############################################################################################################

#Invalid Input Function
f_error() {
		echo
		echo -e "${RED}${BLINK} *** Invalid choice or entry *** "${NC}
		echo
		exit
	}
		export -f f_error

##############################################################################################################

#Force using ROOT
f_root () {
	if [[ "$UID" -ne 0 ]]; then
	echo
	echo -e "${YELLOW}Sorry, you need to run this as ${RED}'root'" ${NC}
	echo
	exit
	fi
	}
		export -f f_root
		
##############################################################################################################

#Exercise 1: Setup Static IP 
f_setip () {
		clear
		echo -e "${YELLOW} [*] Choose your option:"${NC}
		echo
	#Choose between 3 options (Static IP, DHCP Client, DHCP Server)
		select config_network in "Static IP" "DHCP Client" "DHCP Server"
		do
		case $config_network in
	"Static IP")
	f_staticip_data () {		
			clear
			echo
	#Get data from user (IP - Gateway - DNS)
		echo -e "${BLUE} Input IP information: "${NC}
		echo
        echo -e -n "${YELLOW}   [+] Static IP: "${NC}   
            read staticip
        echo -e -n "${YELLOW}   [+] Gateway  : "${NC}
			read gateway
		echo -e -n "${YELLOW}   [+] DNS-1    : "${NC}
			read dns1
		echo -e -n "${YELLOW}   [+] DNS-2    : "${NC}
			read dns2
			echo
	#Confirm data from user
		f_staticip_confirmdata() {	
			echo -e -n "${YELLOW}Please confirm again [YES/NO]: "${NC}
				read staticip_confirmdata
				echo
			case $staticip_confirmdata in
				yes|Yes|YES|y|Y)
			#Backup ifcfg-ens33
					echo
					cp -a /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-ens33.bk
			#Config files
					echo "
					TYPE=Ethernet
					DEVICE=ens33
					NAME=ens33
					BOOTPROTO=static
					IPADDR=$staticip
					PREFIX=24
					GATEWAY=$gateway
					DNS1=$dns1
					DNS2=$dns2
					ONBOOT=YES" > /etc/sysconfig/network-scripts/ifcfg-ens33

					clear
					echo
					echo -e "${YELLOW}${BLINK}Backing up & Assigning the Static IP ...$NC"
			#Restart network services
					systemctl restart network.service
					ifconfig ens33
					cat /etc/resolv.conf
					clear
			#Check ping
					echo
					echo -e -n "${RED}${BLINK} CHECKING..."${NC}
						sleep 5
						echo
						echo
						if ping -q -c 1 -W 1 google.com >/dev/null; then
							echo
							clear
							echo
							echo -e "${YELLOW}Alright, Your Local IP: ${BLUE}$staticip ${YELLOW}- Gateway: ${BLUE}$gateway "${NC}
							else
							clear
							echo
							echo -e "${RED}FAILED!!!"${NC}
							echo
			#Restore backup files				
							echo -e "${YELLOW}Restore to previous IP setup via the backup files."${NC}
							mv /etc/sysconfig/network-scripts/ifcfg-ens33.bk /etc/sysconfig/network-scripts/ifcfg-ens33
							systemctl restart network.service
							echo
							echo -e "${YELLOW}Please check your network connection and try again."${NC}
							fi
								;;
				no|No|NO|n|N)
					echo -e "${BLUE}Alright, slow down. Let's try again!"${NC}
					sleep 2
					f_staticip_data
					;;
				*)
					echo -e "${RED}${BLINK} *** Invalid Entry *** "${NC}
					echo
					echo -e "${YELLOW}Please input: 'YES' or 'NO'"${NC}
					sleep 2
					clear
				#Show data for user again
					echo
					echo -e "${CYAN} [*] Your Input: "${NC}
					echo
					echo -e "${YELLOW}[+] Static IP: $staticip"${NC}
					echo -e "${YELLOW}[+] Gateway  : $gateway"${NC}
					echo -e "${YELLOW}[+] DNS-1    : $dns1"${NC}
					echo -e "${YELLOW}[+] DNS-2    : $dns2"${NC}
					echo
					f_staticip_confirmdata
					;;
					esac
			}
			f_staticip_confirmdata
		}
		f_staticip_data
		break
	;;
	"DHCP Client")
			clear
			echo
			echo -e "${YELLOW} [*] Choose your Client OS: "${NC}
			echo
			select client_os in "Fedora" "Debian" "OpenSUSE" "Windows" "Mac OS"
			do
			case $client_os in
				"Fedora")
					clear
					echo
					echo -e "${YELLOW} [*] Follow the instructions below to configure ${CYAN}DHCP Client${YELLOW}:"${NC}
					echo
					echo
					echo -e "${YELLOW} [+] Step 1: To configure a DHCP client manually, make sure you know the Network Device Name on Client (Example: ${BLUE}ens33, eth0${YELLOW})."${NC}
					echo -e "${YELLOW} [+] Step 2: Open the ${BLUE}/etc/sysconfig/network-scripts/ifcfg-eth0${YELLOW} file ${CYAN}(Remember to change the Interface Name)${YELLOW} (${CYAN}HINT${YELLOW}: Using ${BLUE}'vi'${YELLOW} or ${BLUE}'vim'${YELLOW})."${NC}
					echo -e "${YELLOW} [+] Step 3: Confirm the configuration file must contain the following lines:"${NC}
					echo -e "${BLUE}             DEVICE=eth0"${NC}
					echo -e "${BLUE}             BOOTPROTO=DHCP"${NC}
					echo -e "${BLUE}             ONBOOT=YES"${NC}
					echo -e "${YELLOW} [+] Step 4: Save & Close the configuration file and type: ${BLUE}'systemctl restart network'${YELLOW} to restart the network."${NC}
					echo -e "${YELLOW} [+] Step 5: Type: ${BLUE}'ifconfig'${YELLOW} and confirm your Client has been requested new IP automatic successfully!"${NC}
					break
				;;
				"Debian")
					clear
					echo
					echo -e "${YELLOW} [*] Follow the instructions below to configure ${CYAN}DHCP Client${YELLOW}:"${NC}
					echo
					echo
					echo -e "${YELLOW} [+] Step 1: To configure a DHCP client manually, make sure you know the Network Device Name on Client (Example: ${BLUE}lo, eth0${YELLOW})."${NC}
					echo -e "${YELLOW} [+] Step 2: Open the ${BLUE}/etc/network/interfaces${YELLOW} file (${CYAN}HINT${YELLOW}: Using ${BLUE}'vi'${YELLOW} or ${BLUE}'vim'${YELLOW})."${NC}
					echo -e "${YELLOW} [+] Step 3: Confirm the configuration file must contain the following lines:"${NC}
					echo -e "${BLUE}             auto eth0"${NC}
					echo -e "${BLUE}             iface eth0 inet dhcp"${NC}
					echo -e "${YELLOW} [+] Step 4: Save & Close the configuration file and type: ${BLUE}'ifdown eth0; ifup eth0'${YELLOW} to restart the network."${NC}
					echo -e "${YELLOW} [+] Step 5: Type: ${BLUE}'ifconfig'${YELLOW} and confirm your Client has been requested new IP automatic successfully!"${NC}
					break
				;;
				"OpenSUSE")
					clear
					echo
					echo -e "${YELLOW} [*] Follow the instructions below to configure ${CYAN}DHCP Client${YELLOW}:"${NC}
					echo
					echo
					echo -e "${YELLOW} [+] Step 1: To configure a DHCP client manually, make sure you know the Network Device Name on Client (Example: ${BLUE}eth0${YELLOW})."${NC}
					echo -e "${YELLOW} [+] Step 2: Open the ${BLUE}/etc/sysconfig/network/ifcfg-eth0${YELLOW} file ${CYAN}(Remember to change the Interface Name)${YELLOW} (${CYAN}HINT${YELLOW}: Using ${BLUE}'vi'${YELLOW} or ${BLUE}'vim'${YELLOW})."${NC}
					echo -e "${YELLOW} [+] Step 3: Confirm the configuration file must contain the following lines:"${NC}
					echo -e "${BLUE}             BOOTPROTO='dhcp'"${NC}
					echo -e "${BLUE}             BROADCAST=''"${NC}
					echo -e "${BLUE}             IPADDR=''"${NC}
					echo -e "${BLUE}             NETMASK=''"${NC}
					echo -e "${BLUE}             NETWORK=''"${NC}
					echo -e "${YELLOW} [+] Step 4: Open the ${BLUE}/etc/sysconfig/network/routes${YELLOW} and confirm the configuration file must contain the following line:"${NC}
					echo -e "${BLUE}             #default 10.0.0.1 - eth0"${NC}
					echo -e "${YELLOW} [+] Step 5: Save & Close both configuration files and type: ${BLUE}'systemctl restart wickedd wickedd-dhcp4 wicked'${YELLOW} to restart the network."${NC}
					echo -e "${YELLOW} [+] Step 6: Type: ${BLUE}'ifconfig'${YELLOW} and confirm your Client has been requested new IP automatic successfully!"${NC}
					break
				;;
				"Windows")
					clear
					echo
					echo -e "${YELLOW} [*] Follow the instructions below to configure ${CYAN}DHCP Client${YELLOW}:"${NC}
					echo
					echo
					echo -e "${YELLOW} [+] Step 1: Using key combine '${CYAN}Windows + R${YELLOW}' to open RUN windows then type: ${BLUE}'ncpa.cpl'${YELLOW} to open the Network Connections."${NC}
					echo -e "${YELLOW} [+] Step 2: Right-click to the Network Interface Card and choose ${BLUE}'Properties'${YELLOW} > Double left-click to ${BLUE}'Internet Protocol Version 4 (TCP/IP)'${YELLOW}."${NC}
					echo -e "${YELLOW} [+] Step 3: Choose ${BLUE}'Obtain an IP address automatically'${YELLOW} & ${BLUE}'Obtain DNS server address automatically'${YELLOW}."${NC}
					echo -e "${YELLOW} [+] Step 4: Open new Terminal Command Prompt then type: ${BLUE}'ipconfig /release && ipconfig /renew && ipconfig /all'${YELLOW}."${NC}
					echo -e "${YELLOW}             Confirm your Client has been requested new IP automatic successfully!"${NC}
					break
				;;
				"Mac OS")
					clear
					echo
					echo -e "${YELLOW} [*] Follow the instructions below to configure ${CYAN}DHCP Client${YELLOW}:"${NC}
					echo
					echo
					echo -e "${YELLOW} [+] Step 1: On Client Mac, choose ${BLUE}'Apple menu (Icon Apple)'${YELLOW} > ${BLUE}'System Preferences'${YELLOW}, then click to the ${BLUE}'Network'${YELLOW}."${NC}
					echo -e "${YELLOW} [+] Step 2: Select the Network Connection you want to use (such as ${CYAN}Ethernet${YELLOW}) in the list."${NC}
					echo -e "${YELLOW} [+] Step 3: From the Location drop-down list, choose ${BLUE}'Using DHCP'${YELLOW}."${NC}
					echo -e "${YELLOW} [+] Step 4: Open new Terminal and type: ${BLUE}'ifconfig | grep "inet " | grep -v 127.0.0.1'${YELLOW}."${NC}
					echo -e "${YELLOW}             Confirm your Client has been requested new IP automatic successfully!"${NC}
					break
				;;
				*)
					echo
					echo -e "${RED} *** Invalid Choice *** "${NC}
					break
				;;    
				esac 
				done
		break
	;;
	"DHCP Server")
	#Configuring a DHCP Server
		clear
		echo
		echo -e "${YELLOW}${BLINK} [+] Installing ${BLUE}DHCP${YELLOW} packages..."${NC}
	#Force kill Yum
		echo
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1`
		yum remove -y -q dhcp; yum install -y -q dhcp; yum update -y -q dhcp
		yum install -y -q firewalld; yum update -y -q firewalld
		clear
	f_dhcpserver_data() {	
	#Check listening port 67
		echo
		echo -e "${YELLOW} [+] Check listen and enable on port ${BLUE}67${YELLOW}..." ${NC}
		lsof -i :67 > /dev/null 2>&1
		if [ $? -eq 0 ]; then
		clear
			echo
			echo -e "${YELLOW}It looks like another software is listening on port ${BLUE}67${YELLOW}:"${NC}
			echo
			lsof -i :67
			echo
			echo -e "${YELLOW}Please disable or uninstall it before installing DHCP Server ${BLUE}(kill -9 PID)${YELLOW}."${NC}
			while [[ $CONTINUE != "Y" && $CONTINUE != "N" ]]; do
			echo
			read -rp "Do you still want to run the script? DHCP Server might not work... [Y/N]: " -e CONTINUE
			done
			if [[ "$CONTINUE" = "N" ]]; then
				echo
				echo
				echo -e "$PAKTGB"
				$READAK
				echo
				exit 2
			fi
		fi
	#Get data from User
		clear
		echo
		echo -e "${YELLOW} [*] Input your network information to create DHCP Server:"${NC}
		echo
		echo -e "${CYAN}		[1] Options:"${NC}
		echo
		echo -e -n "${YELLOW} [+] Your Subnet (Example:${BLUE} 192.168.1.0${YELLOW}): "${NC}
			read dhcp_subnet
		echo -e -n "${YELLOW} [+] Your Netmask (Example:${BLUE} 255.255.255.0${YELLOW}): "${NC}
			read dhcp_netmask
		echo -e -n "${YELLOW} [+] Your Gateway (Example:${BLUE} 192.168.1.1${YELLOW}): "${NC}
			read dhcp_gateway
		echo -e -n "${YELLOW} [+] Your Broadcasst Address (Example:${BLUE} 192.168.1.255${YELLOW}): "${NC}
			read dhcp_broadcast
		echo -e -n "${YELLOW} [+] Your Domain Name (Example:${BLUE} example.com${YELLOW}): "${NC}
			read dhcp_domain
		echo -e -n "${YELLOW} [+] Your DNS Primary Server (Example:${BLUE} 192.168.15.210${YELLOW}): "${NC}
			read dhcp_dns1
		echo -e -n "${YELLOW} [+] Your DNS Secondary Server (Example:${BLUE} 192.168.15.220${YELLOW}): "${NC}
			read dhcp_dns2
		echo
		echo -e "${CYAN}		[2] Scope Range:"${NC}
		echo
		echo -e -n "${YELLOW} [+] From (Example:${BLUE} 192.168.1.10${YELLOW}): "${NC}
			read dhcp_range1
		echo -e -n "${YELLOW} [+] To (Example:${BLUE} 192.168.1.100${YELLOW}): "${NC}
			read dhcp_range2	
		echo
		echo -e "${CYAN}		[3] Lease-time (Second):"${NC}
		echo
		echo -e -n "${YELLOW} [+] Default Time (Example:${BLUE} 600${YELLOW}): "${NC}
			read dhcp_defaultleasetime
		echo -e -n "${YELLOW} [+] Max Time (Example:${BLUE} 86400${YELLOW}): "${NC}
			read dhcp_maxleasetime
		echo
	#Confirm data from user
		f_dhcpserver_confirmdata() {
		echo
		echo -e -n "${YELLOW}Please confirm again [YES/NO]: "${NC}
				read dhcpserver_confirmdata
				echo
			case $dhcpserver_confirmdata in
				yes|Yes|YES|y|Y)
	#Create Backup files
		echo
		echo -e "${YELLOW} [*] Backup and config files DHCPD (dhcpd.conf)."${NC}
		echo
		cp -a /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bk
	#Add data to dhcpd.conf
		echo "
	option domain-name \"${dhcp_domain}\";
	option domain-name-servers ${dhcp_dns1}, ${dhcp_dns2};
	default-lease-time ${dhcp_defaultleasetime};
	max-lease-time ${dhcp_maxleasetime};
	lease-file-name \"/var/lib/dhcpd/dhcpd.leases\";
	authoritative;
		
	subnet ${dhcp_subnet} netmask ${dhcp_netmask} {
		range ${dhcp_range1} ${dhcp_range2};
		default-lease-time $dhcp_defaultleasetime;
		max-lease-time $dhcp_maxleasetime;
		option subnet-mask $dhcp_netmask;
		option routers $dhcp_gateway;
		option time-offset -18000; # Eastern Standard Time
		option broadcast-address $dhcp_broadcast;
		option domain-name-servers ${dhcp_dns1}, ${dhcp_dns2};
		}" >> /etc/dhcp/dhcpd.conf
	#Start DHCP Server
		clear
		echo
		echo -e "${YELLOW} [*] DHCPD service status: "${NC}
		echo
		systemctl enable dhcpd; systemctl restart dhcpd; systemctl status dhcpd
	#Enable port 67 (USING IPTABLES or Firewalld)
		echo
		echo -e "${YELLOW} [+] Enable DHCP service (Firewalld). "${NC}
		echo
		firewall-cmd --add-service=dhcp --permanent; firewall-cmd --reload
	#Check status on DHCP (67)
		netstat -lnup | grep 67
		ps aux | grep dhcp | grep -v "grep"
			echo
			echo -e "${YELLOW} [*] Configure DHCP Server successfully!"${NC}
				break
				;;
				no|No|NO|n|N)
					echo -e "${BLUE}Alright, slow down. Let's try again!"${NC}
					sleep 2
					clear
					f_dhcpserver_data
				;;
				*)
					echo -e "${RED}${BLINK} *** Invalid Entry *** "${NC}
					echo
					echo -e "${YELLOW}Please input: 'YES' or 'NO'"${NC}
					sleep 2
					clear
				#Show data for user again
					echo
					echo -e "${CYAN} [*] Your Input: "${NC}
					echo
					echo -e "${YELLOW}[+] Subnet            : $dhcp_subnet"${NC}
					echo -e "${YELLOW}[+] Netmask           : $dhcp_netmask"${NC}
					echo -e "${YELLOW}[+] Gateway           : $dhcp_gateway"${NC}
					echo -e "${YELLOW}[+] DNS-1             : $dhcp_dns1"${NC}
					echo -e "${YELLOW}[+] DNS-2             : $dhcp_dns2"${NC}
					echo -e "${YELLOW}[+] Range IP          : $dhcp_range1 - $dhcp_range2"${NC}
					echo -e "${YELLOW}[+] Default Lease Time: $dhcp_defaultleasetime"${NC}
					echo -e "${YELLOW}[+] Max Lease Time    : $dhcp_maxleasetime"${NC}
					echo
					f_dhcpserver_confirmdata
				;;
				esac
			}	
			f_dhcpserver_confirmdata
		}
		f_dhcpserver_data
		break
	;;
	*)
			echo
			echo -e "${RED} *** Invalid Choice *** "${NC}
			break
			;;
		esac
		done
			echo
			echo
			echo -e "$PAKTGB"
			echo
			$READAK
	}

##############################################################################################################

#Exercise 2: Connect Putty on Windows
f_putty() {
		clear
		echo
		echo -e "${YELLOW}  Follow the instructions below to connect to Linux Server (SSH) in Windows Environment via PuTTY:"${NC}
		echo
		echo -e "${BLUE} [+] Step 1: ${YELLOW}Download PuTTY${BLUE}(https://www.putty.org)${YELLOW}, use key combination (Windows + R) and type: ${BLUE}putty${YELLOW}."${NC}
		echo -e "${BLUE} [+] Step 2: ${YELLOW}Input the target IP (SSH) and click Open."${NC}
		echo -e "${BLUE} [+] Step 3: ${YELLOW}Click 'Yes' if you see the notice then log-in your account."${NC}
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}
	
##############################################################################################################

#Exercise 3: Config Hostname
f_hostname() {
		clear
		echo
		echo -e -n "${YELLOW}Input new hostname: "${NC}
		read hostname
		hostnamectl set-hostname $hostname
		clear
		echo
		echo -e "${YELLOW}Here is your new hostname: "${NC} 
		echo
		hostname
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}

##############################################################################################################

#Exercise 4: Create New User and add sudo
f_newuser() {
		clear
	#Single User
		echo
		echo -e "${BLUE} Input New User Information: "${NC}
		echo
		echo -e -n "${YELLOW}   [+] Enter Fullname: "${NC}
		read fullname
		echo -e -n "${YELLOW}   [+] Enter Username: "${NC}
		read username
		echo -e -n "${YELLOW}   [+] New Password  : "${NC}
		read password
		useradd -m $username -c "$fullname"
		echo "$username:$password" | chpasswd
		echo
		echo
		echo -e "$PAKTC"
		$READAK		
		clear
	#Ask for sudoer privilege
		f_answersudo () {
			echo
			echo -e -n "${YELLOW}Do you want to add user ${BLUE}'$username'${YELLOW} to group sudoers(wheel)? [YES/NO]: "${NC}
				read answersudo
				echo
				clear
				echo
			case $answersudo in
				yes|Yes|YES|y|Y)
					echo -e "${YELLOW}Here is user ${BLUE}'$username'${YELLOW} information details: "${NC}
					echo
					usermod -aG wheel $username; id $username; grep "$username" /etc/passwd
					echo
					echo -e "${YELLOW}Welldone, added user ${BLUE}'$username'${YELLOW} to group sudoers(wheel) successfully!"${NC}
					;;
				no|No|NO|n|N)
					echo -e "${YELLOW}Welldone, created user ${BLUE}'$username'${YELLOW} successfully!"${NC}
					;;
				*)
					echo -e "${RED}${BLINK} *** Invalid Entry *** "${NC}
					echo
					echo -e "${YELLOW}Please input: 'YES' or 'NO'"${NC}
					sleep 2
					clear
					f_answersudo
					;;
					esac
			}
			f_answersudo
	#Multi Users
			echo
			echo
			echo -e "$PAKTGB"
			$READAK
	}
	
##############################################################################################################

#Exercise 5: Config Timedate
f_timedate() {
		clear
		echo
		echo -e "${YELLOW} [*] Your Choice:"${NC}
		echo
	#Choose between 2 options (Primary and Secondary)
		select config_time in Manual Automatic
		do
		case $config_time in
			"Manual")
				clear
				echo
				echo -e -n "${YELLOW}Input Date (Example: 2019-10-23): "${NC}
				read date
				echo -e -n "${YELLOW}Input Time (Example: 19:30:50)  : "${NC}
				read time
				timedatectl set-ntp false
				timedatectl set-local-rtc 0
				timedatectl set-time $date
				timedatectl set-time $time
				timedatectl set-timezone Asia/Ho_Chi_Minh
				clear
				echo
				echo -e "${YELLOW} Here is your new time & date status: "${NC}
				echo
				date
				break
			;;
			"Automatic")
				clear
				echo
				echo -e "${YELLOW} [+] Set up NTP:"${NC}
				echo
				timedatectl set-timezone Asia/Ho_Chi_Minh
				timedatectl set-ntp 1
				systemctl enable chronyd; systemctl start chronyd; systemctl status -l chronyd
				echo
				echo -e "${YELLOW}${BLINK} [*] Waiting to synchronize NTP..."${NC}
				sleep 10
				clear
				echo
				echo -e "${YELLOW} Here is your new time & date status: "${NC}
				echo
				timedatectl status
				break
			;;
			*)
				echo
				echo -e "${RED} *** Invalid Choice *** "${NC}
				break
			;;
		esac
		done
			echo
			echo
			echo -e "$PAKTGB"
			$READAK		
	}
	
	export -f f_timedate

##############################################################################################################	

#Exercise 6: Create new Logical Volume Management (LVM)	
f_newlvm() {
		clear
		echo
		echo -e "${BLUE}Your disk information:"${NC}
		echo
		fdisk -l | grep "/dev/s" #Check disk device information
		echo
		echo -e "${YELLOW}*Make sure you was added ${BLUE}a new Hard Disk ${YELLOW}and located it done (fdisk -l). "${NC}
		echo
		echo -e -n "${YELLOW}Enter disk name (Example: ${BLUE}sdb${YELLOW}): "${NC}
		read newdisk
		echo -e -n "${YELLOW}Enter disk space (Example: ${BLUE}+100M${YELLOW}): "${NC}
		read space
	#Create partition and set to Linux LVM (8e)
		echo "n
		p


		$space
		t

		8e
		w" | fdisk /dev/$newdisk
	#Show partition
		clear
		echo
		echo -e "${YELLOW}Here is the disk ${BLUE}(/dev/$newdisk)${YELLOW} partitions details:"${NC}
		echo
		fdisk -l | grep "/dev/$newdisk"
		echo
	#Identified the new disk info
		echo -e -n "${YELLOW}[+] Input the disk partition to create LVM (Example: ${BLUE}sdb1${YELLOW}): "${NC}
		read diskinfo
	#Create Physical Volume
		pvcreate /dev/$diskinfo
		echo
	#Create Volume Group
		echo -e -n "${YELLOW}[+] Input the volume group name (Example: ${BLUE}VGDATA${YELLOW}): "${NC}
		read vgdata
		vgcreate $vgdata /dev/$diskinfo
		echo
	#Create Logical Volume
		echo -e -n "${YELLOW}[+] Input the logical volume name (Example: ${BLUE}LVDATA${YELLOW}): "${NC}
		read lvdata
		echo
		echo -e -n "${YELLOW}[+] Input the logical volume space (Example: ${BLUE}25%,50%,...${YELLOW}): "${NC}
		read lvspace
		lvcreate -n $lvdata -l ${lvspace}FREE $vgdata
	#Config after
		mkfs.xfs /dev/$vgdata/$lvdata
		mkdir /files
		echo "/dev/$vgdata/$lvdata /files xfs defaults 1 2" >> /etc/fstab
		mount -a
		clear
		echo
		echo -e "${YELLOW}Here is the new Logical Volume Managent (LVM) information: "${NC}
		echo
	#Check data correctly
		df -h /dev/mapper/$vgdata-$lvdata
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}

##############################################################################################################
	
#Exercise 7: Config firewalld to allow user access to server through protocols (http,ftp,...)
f_openservice() {
		clear
	#Check install Firewalld
		echo
		echo -e "${YELLOW}${BLINK}[+] Installing ${BLUE}Firewalld${YELLOW}... "${NC}
		echo
	#Force stop YUM
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; yum install -y -q firewalld; yum update -y -q firewalld
		clear
	#Add single service
		echo
		echo -e -n "${YELLOW}Input service to enable (Example: ${BLUE}'http' ${YELLOW}or ${BLUE}'ftp'${YELLOW}): "${NC}
		read service
		firewall-cmd --add-service=$service --permanent; firewall-cmd --reload
		echo
		echo -e -n "${YELLOW}Input port to enable (Example: ${BLUE}'21' ${YELLOW}or ${BLUE}'2022'${YELLOW}): "${NC}
		read service_port
		echo
		echo -e -n "${YELLOW}Input your protocol (Example: ${BLUE}tcp, udp, sctp, dccp${YELLOW}): "${NC}
		read service_protocol
		firewall-cmd --add-port=${service_port}/${service_protocol} --permanent; firewall-cmd --reload
	#Restart firewalld
		clear
		echo
		echo -e "${YELLOW}Firewalld.service status:"${NC}
		echo		
		systemctl enable firewalld; systemctl restart firewalld; systemctl status firewalld;
		echo
	#Checking services added
		echo -e "${YELLOW}Lists your current services running:"${NC}
		echo
		firewall-cmd --list-services; firewall-cmd --list-ports
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}

##############################################################################################################	
	
#Exercise 8: Install and config Basic Web Server
f_webserver() {
		clear
	#Install Basic Web Server & Elinks package
		echo
		echo -e "${YELLOW}${BLINK}[+] Installing ${BLUE}"Basic Web Server"${YELLOW} and ${BLUE}Elinks${YELLOW}..."${NC}
		echo
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; yum install -y -q dnf; yum update -y -q dnf
		dnf groupinstall -y -q "Basic Web Server";dnf groupupdate -y -q "Basic Web Server"
		yum install -y -q elinks; yum update -y -q elinks
		clear
	#Backup file httpd.conf && Create Basic Index.html
		echo
		echo -e "${YELLOW} [+] Back up file httpd.conf & Create Index.html ${BLUE}(/var/www/html/index.html)${YELLOW}."${NC}
		cp -a /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bk
		echo
		echo -e -n "${YELLOW} [+] Input data to index file (Example: ${BLUE}Hello World!${YELLOW}): "${NC}
		read web_data
		echo "$web_data" > /var/www/html/index.html
	#Restart httpd service
		systemctl start httpd; systemctl enable httpd; systemctl restart httpd
		clear
		echo -e "${YELLOW}  Alright, 2 ways to see the result: "${NC}
		echo
		echo -e "${YELLOW} [+] Open new tab and type: ${BLUE}elinks http://localhost. "${NC}
		echo -e "${YELLOW} [+] Open Web Browser and redirect to: ${BLUE}http://localhost. "${NC}
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}

##############################################################################################################

#Exercise 9: Install and config FTP Anonymous Drop Box with a shared folder.
f_anon_dropbox() {
		clear
	#Install VSFTPD package
		echo
		echo -e "${YELLOW}${BLINK}[+] Installing ${BLUE}VSFTPD${YELLOW}..."${NC}
		echo
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; yum install -y -q vsftpd; yum update -y -q vsftpd
		echo
		clear
	#Config Firewalld to add FTP service
		echo
		echo -e "${YELLOW}[+] Add ${BLUE}FTP ${YELLOW}service from Firewalld."${NC}
		firewall-cmd --zone=public --permanent --add-service=ftp
		firewall-cmd --reload
		echo
	#Create a rule for firewall to allow FTP traffic on Port 21
		echo -e "${YELLOW}[+] Enable Port ${BLUE}21${YELLOW}."${NC}
		firewall-cmd --zone=public --permanent --add-port=21/tcp
		firewall-cmd --reload
		echo
	#Check the FTP service and port was added
		echo -e "${YELLOW}[+] Check lists current services running."${NC}
		firewall-cmd --list-services | grep "ftp"
		firewall-cmd --list-ports | grep "21"
		echo
	#Create backup vsftpd.conf file (.bk)
		echo -e "${YELLOW}[+] Create backup ${BLUE}vsftpd.conf ${YELLOW}file."${NC}
		cp -a /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bk
		echo
	#Create Uploads Folder
		echo -e "${YELLOW}[+] The FTP Server uses the directory (/var/ftp) as the default document root."${NC}
		echo -e "${YELLOW}    Create a sub-directory with the name ${BLUE}'uploads' ${YELLOW}(/var/ftp/uploads)."${NC}
		rm -rf /var/ftp/uploads; mkdir /var/ftp/uploads
		echo
	#Give permissions for Shared Folder | -rwx-wx---
		echo -e "${YELLOW}[+] Set permission (Users can write, but they can't read them). "${NC}
		chmod 0730 /var/ftp/uploads
		echo
	#Set the group owner to group FTP
		chgrp ftp /var/ftp/uploads
		echo -e "${YELLOW}[+] Set the group owner to ${BLUE}'FTP'${YELLOW}. "${NC}
		echo
	#Edit file vsftpd.conf
		echo "#Set up FTP Anonymous Drop Box
			anon_umask=077
			anon_upload_enable=YES
			anon_mkdir_write_enable=YES
			chown_uploads=YES
			chown_username=root" >> /etc/vsftpd/vsftpd.conf
	#Restart VSFTPD service
		echo -e "${YELLOW}[+] VSFTPD service status:"${NC}
		echo
		systemctl enable vsftpd; systemctl start vsftpd; systemctl restart vsftpd; systemctl status vsftpd
	#Config Semanage
		semanage fcontext -a -t public_content_rw_t "/var/ftp/uploads(/.*)?"
		restorecon -Rv /var/ftp/uploads
	#Enable ftpd_anon_write
		setsebool -P ftpd_anon_write on
		echo
		echo
		echo -e "$PAKTC"
		$READAK
		clear
	#Test the result
		echo
		echo -e "${YELLOW}   Follow the instructions below to make sure everything is set up correctly:"${NC}
		echo
		echo -e "${YELLOW}	[+] Step 1: Log-in Secondary Server and type:${BLUE} yum install -y lftp${YELLOW}."${NC}
		echo -e "${YELLOW}	[+] Step 2: Then type: ${BLUE}lftp (FTP Server IP)${YELLOW} - Example: lftp 192.168.1.10."${NC}
		echo -e "${YELLOW}	[+] Step 3: After connect to FTP Server, type: ${BLUE}ls${YELLOW}."${NC}
		echo -e "${YELLOW}	[+] Step 4: Then type: ${BLUE}cd uploads/; put /etc/hosts${YELLOW}."${NC}
		echo -e "${YELLOW}	[+] Step 5: Back to FTP Server, type: ${BLUE}ls -l /var/ftp/uploads/${YELLOW}."${NC}
		echo -e "${YELLOW}	[+] Step 6: If you see the information the same with this ${BLUE}(-rw-------. 1 root ftp 204 Oct 26 17:31 hosts)${YELLOW}."${NC}
		echo -e "${YELLOW}	            Congratulations! Everything working perfectly. (If not, un-install VSFTPD and try again)"${NC}
		echo -e "${YELLOW}	[+] Step 7: To check FTP Server log details, type: ${BLUE}cat /var/log/xferlog${YELLOW}."${NC}
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}

##############################################################################################################

#Exercise 10: Managing Advanced Apache Services
f_apache() {
		clear
		f_webserver
		clear
	#Turn off SELinux (Permissive)
		setenforce 0
	#Get IP server from User
		echo
		echo -e -n "${YELLOW}[+] Input your IP: "${NC}
		read webserverip
		echo
	#Backup and config file /etc/hosts
		echo -e "${YELLOW} [+] Backup & Config files hosts (/etc/hosts) "${NC}
		cp -a /etc/hosts /etc/hosts.bk
		echo "$webserverip server1.example.com server1
		$webserverip account.example.com account
		$webserverip sales.example.com sales" >> /etc/hosts
		echo
	#Backup and config files httpd.conf
		cp -a /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bk
		echo "<Directory /www/docs>
		Require all granted
		AllowOverride None
		</Directory>" >> /etc/httpd/conf/httpd.conf
		echo
	#Create account.example.com.conf
		echo "<VirtualHost *:80>
		ServerAdmin webmaster@account.example.com
		DocumentRoot /www/docs/account.example.com
		ServerName account.example.com
		ErrorLog logs/account.example.com-error_log
		CustomLog logs/account.example.com-access_log common
		</VirtualHost>" > /etc/httpd/conf.d/account.example.com.conf
		echo
	#Create folder account.example.com
		mkdir -pv /www/docs/account.example.com/logs
		echo
		echo "Welcome to Account Server" >> /www/docs/account.example.com/index.html
	#Copy and config account.example.com.conf to sales.example.com.conf
		cp /etc/httpd/conf.d/account.example.com.conf /etc/httpd/conf.d/sales.example.com.conf
	#Create folder account.example.com
		mkdir -pv /www/docs/sales.example.com/logs
	#Copy and replace word "account to sales" in sales.example.com.conf
		sed -i s/account/sales/g /etc/httpd/conf.d/sales.example.com.conf
		echo "Welcome to Sales Server" >> /www/docs/sales.example.com/index.html
	#Restart httpd service
		clear
		echo
		echo -e "${YELLOW} [+] Here is HTTPD service status: "${NC}
		echo
		systemctl restart httpd; systemctl enable httpd; systemctl status httpd
		echo
		echo
		echo -e "$PAKTC"
		$READAK
		clear
	#Check getenforce status
		echo
		echo -e "${YELLOW} [+] Getenforce status: "${NC}
		echo
		setenforce Enforcing; getenforce #Switch on SELinux
	#Config semanage
		semanage fcontext -a -t httpd_sys_content_t "/www/docs(/.*)?"
		restorecon -Rv /www/docs
		clear
	#Create Group Webdev
		echo
		echo -e "${YELLOW} [+] Create group Web Development (webdev). "${NC}
		echo
		groupadd webdev
	#Set ACLs to make sure members of the group webdev have access to the document root
		setfacl -R -m g:webdev:rwx /www/docs; setfacl -R -m d:g:webdev:rwx /www/docs
	#Add new user and add to group webdev
		echo -e -n "${YELLOW} [+] Input new user to create and add to group ${BLUE}'webdev'${YELLOW}: "${NC}
		read webdev_newuser
		echo -e -n "${YELLOW} [+] Input new password for ${BLUE}'$webdev_newuser'${YELLOW}: "${NC}
		read webdev_password
		useradd -m $webdev_newuser
		echo "$webdev_newuser:$webdev_password" | chpasswd
		usermod -aG webdev $webdev_newuser
	#Verify that newuser can access to /www/docs
		echo
		clear
		echo
		echo -e "${YELLOW}   Follow the instructions below to check the result:"${NC}
		echo
		echo -e "${YELLOW} [*] Open new tab and type: ${BLUE}"su - $webdev_newuser"${YELLOW}."${NC}
		echo -e "${YELLOW}     Then type: ${BLUE}touch /www/docs/$webdev_newuser.html${YELLOW} to verify write access. "${NC}
		echo
		echo
		echo -e "$PAKTC"
		$READAK
		clear
	#Restart service httpd
		echo -e "${YELLOW}${BLINK} [+] Restarting HTTPD service... "${NC}
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; yum install -y -q httpd-manual; yum update -y -q httpd-manual
		systemctl restart httpd; systemctl enable httpd
		clear
	#Open HTTPD Manual
		echo
		echo -e "${YELLOW} [+] Open new tab and type: ${BLUE}elinks http://localhost/manual${YELLOW} to check the result."${NC}
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}

##############################################################################################################
	
#Exercise 11: Installing and Configuring the Unbound Caching Name Server
#Follow source: https://github.com/angristan/local-dns-resolver/blob/master/unbound-install.sh
f_dns_unbound() {
		clear
	#Check listening port 53
		echo
		echo -e "${YELLOW}${BLINK} [+] Check listening on port ${CYAN}53${YELLOW}..." ${NC}
		lsof -i :53 > /dev/null 2>&1
		if [ $? -eq 0 ]; then
		clear
			echo
			echo -e "${YELLOW}It looks like another software is listening on port ${CYAN}53${YELLOW}:"${NC}
			echo
			lsof -i :53
			netstat -lnup | grep 53
			echo
			echo -e "${YELLOW}Please disable or uninstall it before installing Unbound ${BLUE}(kill -9 PID)${YELLOW}."${NC}
			while [[ $CONTINUE != "Y" && $CONTINUE != "N" ]]; do
			echo
			read -rp "Do you still want to run the script? Unbound might not work... [Y/N]: " -e CONTINUE
			done
			if [[ "$CONTINUE" = "N" ]]; then
				echo
				exit 2
			fi
		fi
	#Install Unbound Firewalld
		clear
		echo
		echo -e "${YELLOW}${BLINK}[+] Installing ${BLUE}Unbound${YELLOW}... "${NC}
		echo
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1`
		yum remove unbound -y -q; yum remove bind -y -q; yum install -y -q unbound; yum update -y -q unbound
		systemctl enable unbound; systemctl start unbound
		clear
	#Backup and edit unbound.conf
		echo
		echo -e -n "${YELLOW} [+] Input your IP subnet (Example: ${BLUE}192.168.1.0${YELLOW}): "${NC}
		read unbound_ipsubnet
		echo
		echo -e -n "${YELLOW} [+] Input your Prefix (Example: ${BLUE}24${YELLOW}): "${NC}
		read unbound_prefix
		
		clear
		echo
		echo -e "${YELLOW} [+] Backup and config file unbound.conf ${BLUE}(/etc/unbound/unbound.conf)${YELLOW}. "${NC}
		cp -a /etc/unbound/unbound.conf /etc/unbound/unbound.conf.bk
		sed -i 's|# interface: 0.0.0.0$|interface: 0.0.0.0|' /etc/unbound/unbound.conf
		sed -i 's|# access-control: 127|access-control: 127|' /etc/unbound/unbound.conf
		sed  -i "s/127.0.0.0\/8 allow/${unbound_ipsubnet}\/${unbound_prefix} allow/" /etc/unbound/unbound.conf
		echo "
		#Exercise 11: Install Unbound service
		forward-zone:
			name: \".\"
			forward-addr: 1.1.1.1" >> /etc/unbound/unbound.conf
		echo
		unbound-checkconf
		echo
		echo
		echo -e "$PAKTC"
		$READAK
	#Restart service Unbound
		clear
		echo
		echo -e "${YELLOW} [+] Unbound service status: "${NC}
		echo
		systemctl enable unbound; systemctl restart unbound; systemctl status unbound
		netstat -nlpt | grep 53
		echo
	#Open DNS on firewalld
		echo -e "${YELLOW} [+] Enable DNS (firewalld): "${NC}
		echo
		firewall-cmd --permanent --add-service=dns; firewall-cmd --reload; firewall-cmd --list-services
	#Check the result
		clear
		echo
		echo -e "${YELLOW}   Follow the instructions below to make sure everything is set up correctly:"${NC}
		echo
		echo -e "${YELLOW}	[+] Step 1: Log-in Secondary Server (Server2) and start ${BLUE}'nmtui'${YELLOW}."${NC}
		echo -e "${YELLOW}	[+] Step 2: Configure the DNS server listening on Unbound Server (Primary Server)."${NC}
		echo -e "${YELLOW}	[+] Step 3: After that, type: ${BLUE}dig example.com${YELLOW}."${NC}
		echo -e "${YELLOW}	[+] Step 4: If you see the answer is provided by the Unbound Server."${NC}
		echo -e "${YELLOW}	            Congratulations! Everything working perfectly. (If not, re-install and try again)"${NC}
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}
	
##############################################################################################################

#Exercise 12: Install BIND and DNS packages
f_dns_bind() {
		clear
		#Check listening port 53
		echo
		echo -e "${YELLOW}${BLINK} [+] Check listening on port ${CYAN}53${YELLOW}..." ${NC}
		lsof -i :53 > /dev/null 2>&1
		if [ $? -eq 0 ]; then
		clear
			echo
			echo -e "${YELLOW}It looks like another software is listening on port ${CYAN}53${YELLOW}:"${NC}
			echo
			lsof -i :53
			netstat -lnup | grep 53
			echo
			echo -e "${YELLOW}Please disable or uninstall it before installing Bind ${BLUE}(kill -9 PID)${YELLOW}."${NC}
			while [[ $CONTINUE != "Y" && $CONTINUE != "N" ]]; do
			echo
			read -rp "Do you still want to run the script? Bind might not work... [Y/N]: " -e CONTINUE
			done
			if [[ "$CONTINUE" = "N" ]]; then
				echo
				exit 2
			fi
		fi
		clear
		#Choose between 2 server (Primary and Secondary)
		echo
		echo -e "${YELLOW} [*] Choose your current running server:"${NC}
		echo
		select bind_server in "Primary Server" "Secondary Server"
		do
		case $bind_server in
			"Primary Server")
				clear
				echo
				echo -e "${YELLOW}${BLINK} [-] Removing ${BLUE}Unbound${YELLOW} & ${BLUE}Old Bind${YELLOW} service..." ${NC}
				echo
				kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; 
				yum remove unbound -y -q; yum remove bind -y -q
				clear
			#Install BIND packages
				echo
				echo -e "${YELLOW}${BLINK} [+] Installing ${BLUE}Bind${YELLOW} service..." ${NC}
				echo
				yum install -y -q bind bind-utils; yum update -y -q bind bind-utils
				clear
				echo
				echo -e "${YELLOW} [+] Backup and config file named.conf ${BLUE}(/etc/named.conf)${YELLOW}. "${NC}
				echo
				cp -a /etc/named.conf /etc.named.conf.bk
			#Get IP from user
				clear
				echo
				echo -e -n "${YELLOW} [+] Input Primary Server IP  : "${NC}
				read bind_server1_ip
				echo -e -n "${YELLOW} [+] Input Secondary Server IP: "${NC}
				read bind_server2_ip
				echo -e -n "${YELLOW} [+] Input Domain Name Primary Server (Example: ${BLUE}fptjetking1${YELLOW}): "${NC}
				read bind_domain_1
				echo -e -n "${YELLOW} [+] Input Domain Name Secondary Server (Example: ${BLUE}fptjetking2${YELLOW}): "${NC}
				read bind_domain_2
				reverse_ip=$(echo "$bind_server1_ip" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa"}')
				clear
			#Changing named.conf
				sed -i 's|127.0.0.1|any|' /etc/named.conf
				sed -i 's|listen-on-v6|#listen-on-v6|' /etc/named.conf
				sed -i "s|localhost; };|any; }; allow-transfer { ${bind_server2_ip}; };|" /etc/named.conf
	#Add Zone to /etc/named.conf
echo "#A (Forward) Zone Statement for your domain
zone \"example.com\" IN {
type master;
file \"example.com.zone\";
};

#A (Forward) Zone Statement for your domain
zone \"${reverse_ip}\" IN {
type master;
file \"example.com.rr.zone\";
allow-update { none; };
};" >> /etc/named.conf
	#Add data to Forward Zone
echo "\$ORIGIN example.com.
\$TTL 86400
@ IN SOA ${bind_domain_1}.example.com. hostmaster.example.com. (
2001062501 ; serial
21600 ; refresh after 6 hours
3600 ; retry after 1 hour
604800 ; expire after 1 week
86400 ) ; minimum TTL of 1 day
;
;
@ IN NS ${bind_domain_1}.example.com.
@ IN NS ${bind_domain_2}.example.com.

${bind_domain_1} IN A ${bind_server1_ip}
${bind_domain_2} IN A ${bind_server2_ip}
;
;
@ IN MX 10 mail.example.com.
IN MX 20 mail2.example.com.
mail IN A 192.168.15.251
mail2 IN A 192.168.15.252
;
;
; This sample zone file illustrates sharing the same IP addresses
; for multiple services:
;
services IN A 192.168.15.100
IN A 192.168.15.201
ftp IN CNAME services.example.com.
www IN CNAME services.example.com.
;
;" > /var/named/example.com.zone
	#Add data to Reverse Name
echo "\$ORIGIN ${reverse_ip}.
\$TTL 86400
@ IN SOA ${bind_domain_1}.example.com. hostmaster.example.com. (
2001062501 ; serial
21600 ; refresh after 6 hours
3600 ; retry after 1 hour
04800 ; expire after 1 week
86400 ) ; minimum TTL of 1 day
;
@ IN NS ${bind_domain_1}.example.com.
@ IN NS ${bind_domain_2}.example.com.
;
100 IN PTR ${bind_domain_1}.example.com.
200 IN PTR ${bind_domain_2}.example.com.
;
251 IN PTR mail.${bind_domain_1}.example.com.
252 IN PTR mail2.${bind_domain_1}.example.com.
;
201 IN PTR ftp.${bind_domain_1}.example.com.
202 IN PTR www.${bind_domain_1}.example.com." > /var/named/example.com.rr.zone 
			#Checks the syntax of named.conf:
				named-checkconf /etc/named.conf
				echo
			#Checks the syntax and integrity of a zone file:
				named-checkzone example.com /var/named/example.com.zone;
				named-checkzone ${reverse_ip} /var/named/example.com.rr.zone
			#Config SELinux, Permissions, Ownership:	
				echo
				chgrp named -R /var/named
				chown -v root:named /etc/named.conf
				restorecon -Rv /var/named
				restorecon /etc/named.conf
				echo
				clear
			#Enable Named service:
				echo -e "${YELLOW} [+] Named service status:"${NC}
				echo
				systemctl enable named; systemctl restart named; systemctl status named
				echo
			#Add DNS service:
				echo -e "${YELLOW}Lists your current services running:"${NC}
				echo
				firewall-cmd --add-service=dns --permanent; firewall-cmd --reload; firewall-cmd --list-services
				echo
				echo
				echo -e "$PAKTC"
				$READAK
			#Ask user to block website
				clear
			f_blockweb(){	
				echo
				echo -e -n "${YELLOW} [+] Do you want to block access to a website? [YES/NO]: "${NC}
				read ask_block_website
				echo
				clear
				echo
				case $ask_block_website in
					yes|Yes|YES|y|Y)
						echo -e -n "${YELLOW} [+] Input a website name: "${NC}
						read website_block
						echo "
						zone \"$website_block\" IN {
							type master;
							file \"deny_list\";
						};" >> /etc/named.conf
					#Create Backup deny_list
						cp -a /var/named/named.localhost /var/named/deny_list
						systemctl restart named
						clear
						echo
						echo -e "${YELLOW} [+] Blocked Website: $website_block successfully!"
						echo -e "${YELLOW} [*] On Secondary Server, type:${BLUE} nslookup $website_block to verify."${NC}
						echo
						echo
						echo -e "$PAKTC"
						$READAK
						;;
					no|No|NO|n|N)
						echo
						;;
					*)
						echo -e "${RED}${BLINK} *** Invalid Entry *** "${NC}
							echo
							echo -e "${YELLOW}Please input: 'YES' or 'NO'"${NC}
							sleep 2
							clear
						f_blockweb
						;;
					esac
					}
				f_blockweb	
				#Check the result
				clear
				echo
				echo -e "${YELLOW}   Follow the instructions below to make sure everything is set up correctly (Primary Nameserver):"${NC}
				echo
				echo -e "${YELLOW}	[+] Step 1: Log-in Secondary Server (Server2) and start ${BLUE}'nmtui'${YELLOW}."${NC}
				echo -e "${YELLOW}	[+] Step 2: Configure the DNS server listening on ${CYAN}${bind_server1_ip}${YELLOW}."${NC}
				echo -e "${YELLOW}	[+] Step 3: After that, type: ${BLUE}dig ${bind_domain_1}.example.com${YELLOW}."${NC}
				echo -e "${YELLOW}	[+] Step 4: If you see the answer is provided by the Bind Primary Server."${NC}
				echo -e "${YELLOW}	            Congratulations! Everything working perfectly. (If not, re-install and try again)"${NC}
				break
		;;
	#Set up Secondary Nameserver
		"Secondary Server")
				clear
				echo
				echo -e "${YELLOW}${BLINK} [-] Removing ${BLUE}Unbound${YELLOW} & ${BLUE}Old Bind${YELLOW} service..." ${NC}
				echo
				kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; 
				yum remove unbound -y -q; yum remove bind -y -q
				clear
			#Install BIND packages
				echo
				echo -e "${YELLOW}${BLINK} [+] Installing ${BLUE}Bind${YELLOW} service..." ${NC}
				echo
				yum install -y -q bind bind-utils; yum update -y -q bind bind-utils
				clear
				echo
				echo -e "${YELLOW} [+] Backup and config file named.conf ${BLUE}(/etc/named.conf)${YELLOW}. "${NC}
				cp -a /etc/named.conf /etc.named.conf.bk
				echo
			#Get IP from user
				clear
				echo
				echo -e -n "${YELLOW} [+] Input Primary Server IP: "${NC}
				read bind_server1_ip
				echo -e -n "${YELLOW} [+] Input Secondary Server IP: "${NC}
				read bind_server2_ip
				echo -e -n "${YELLOW} [+] Input Domain Name Primary Server (Example: ${BLUE}fptjetking1${YELLOW}): "${NC}
				read bind_domain_1
				echo -e -n "${YELLOW} [+] Input Domain Name Secondary Server (Example: ${BLUE}fptjetking2${YELLOW}): "${NC}
				read bind_domain_2
				reverse_ip=$(echo "$bind_server1_ip" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa"}')
				clear
			#Changing named.conf
				sed -i 's|127.0.0.1|any|' /etc/named.conf
				sed -i 's|listen-on-v6|#listen-on-v6|' /etc/named.conf
				sed -i 's|localhost;|any;|' /etc/named.conf
	#Add Zone to /etc/named.conf
echo "#A (Forward) Zone Statement for your secondary nameserver
zone \"example.com\" IN {
type slave;
file \"slaves/example.com.zone\";
masters {${bind_server1_ip};};
};

#A (Forward) Zone Statement for your secondary nameserver
zone \"${reverse_ip}\" IN {
type slave;
file \"slaves/example.com.rr.zone\";
masters {${bind_server1_ip};};
};" >> /etc/named.conf
			#Checks the syntax of named.conf:
				named-checkconf /etc/named.conf
			#Config SELinux, Permissions, Ownership:	
				echo
				chgrp named -R /var/named
				chown -v root:named /etc/named.conf
				restorecon -Rv /var/named
				restorecon /etc/named.conf
				echo	
				echo
				clear
			#Enable Named service:
				echo -e "${YELLOW} [+] Named service status:"${NC}
				echo
				systemctl enable --now named; systemctl restart named; systemctl status named
				echo
			#Add DNS service:
				echo -e "${YELLOW}Lists your current services running:"${NC}
				echo
				firewall-cmd --add-service=dns --permanent; firewall-cmd --reload; firewall-cmd --list-services
			#Check Zone-transfer
				echo
				echo -e "${YELLOW} [+] Check Zone-Transfer status:"${NC}
				echo
				ls -l /var/named/slaves/
				echo
				echo
				echo -e "$PAKTC"
				$READAK
			#Check the result
				clear
				echo
				echo -e "${YELLOW}   Follow the instructions below to make sure everything is set up correctly (Secondary Nameserver):"${NC}
				echo
				echo -e "${YELLOW}	[+] Step 1: Log-in Primary Server (Server1) and start ${BLUE}'nmtui'${YELLOW}."${NC}
				echo -e "${YELLOW}	[+] Step 2: Configure the DNS server listening on ${bind_server2_ip}."${NC}
				echo -e "${YELLOW}	[+] Step 3: After that, type: ${BLUE}dig ${bind_domain_2}.example.com${YELLOW}."${NC}
				echo -e "${YELLOW}	[+] Step 4: If you see the answer is provided by the Bind Secondary Server."${NC}
				echo -e "${YELLOW}	            Congratulations! Everything working perfectly. (If not, re-install and try again)"${NC}
		break
		;;
	#Wrong answer	
		*)
			echo
			echo -e "${RED} *** Invalid Choice *** "${NC}
			break
		;;
			esac
			done
			echo
			echo
			echo -e "$PAKTGB"
			$READAK
	}	
	
##############################################################################################################	

#Exercise 13: Create Basic Shell Script
f_basicshell() {
		clear
		echo
		echo -e -n "${YELLOW} [+] Input your output (Example: ${BLUE}Hello World${YELLOW}): "${NC}
		read output_shell
		echo -e -n "${YELLOW} [+] Input new file name (Example: ${BLUE}hello.sh${YELLOW}): "${NC}
		read filename_shell
		echo
	#Writing simple script
		echo "#!/bin/bash
		#
		clear
		echo "$output_shell"
		exit" > $filename_shell
	#Give Permission to excute file
		chmod +x $filename_shell
		echo -e "${YELLOW} Type: ${BLUE}./$filename_shell ${YELLOW}to see the result."${NC}
			echo
			echo
			echo -e "$PAKTGB"
			$READAK		
	}
	
##############################################################################################################

#Exercise 14: Set up a Base NFSv4 Server
f_nfs() {
		clear
		echo
		echo -e "${YELLOW} [*] Choose your current running server:"${NC}
		echo
		#Choose between Primary (NFS Server) and Secondary Server
		select nfs_server in "Primary Server" "Secondary Server"
		do
		case $nfs_server in
			"Primary Server")
				#Install NFS
					clear
					echo
					echo -e "${YELLOW}${BLINK} [+] Installing ${BLUE}NFS${YELLOW}..."${NC}
					echo
					kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; yum install -y -q nfs-utils policycoreutils-python
					yum update -y -q nfs-utils policycoreutils-python
					clear
				#Backup files
					cp -a /etc/exports /etc/exports.bk
					echo "/srv/nfsexport * (rw)" >> /etc/exports
					rm -rf /srv/nfsexport; mkdir /srv/nfsexport
					semanage fcontext -a -t nfs_t "/srv/nfsexport(/.*)?"
					restorecon -Rv /srv/nfsexport; echo
				#Add NFS, Mountd, RPC-Bind service on Firewalld
					echo
					echo -e "${YELLOW} [+] Add service NFS, Mountd, RPC-Bind (firewalld):"${NC}
					systemctl enable firewalld; systemctl start firewalld; systemctl restart firewalld
					firewall-cmd --permanent --add-service=nfs --add-service=mountd --add-service=rpc-bind; firewall-cmd --reload
					firewall-cmd --list-services;firewall-cmd --list-ports
				#Restart NFS server
					echo
					echo -e "${YELLOW} [+] NFS-server status:"${NC}
					echo
					systemctl start nfs-server; systemctl enable nfs-server; systemctl status nfs-server
					echo
					echo -e "${YELLOW} [*] Configure NFS on Primary Server successfully!"${NC}
					break
				;;		
			"Secondary Server")
				#Verify showmount
					clear
					echo
					echo -e -n "${YELLOW} [+] Input NFS-Server ${BLUE}(Primary Server)${YELLOW} IP: "${NC}
					read nfs_server1_ip
					showmount -e $nfs_server1_ip
					umount /mnt/nfs; rm -rf /mnt/nfs; mkdir /mnt/nfs
					mount ${nfs_server1_ip}:/srv/nfsexport /mnt/nfs
					mount | grep nfs
					echo
				#Backup and config /etc/fstab files
					echo -e "${YELLOW} [+] Backup fstab file (/etc/fstab)"${NC}
					cp -a /etc/fstab /etc/fstab.bk
					echo "${nfs_server1_ip}:/srv/nfsexport /mnt/nfs nfs _netdev 0 0" >> /etc/fstab
					echo
					echo -e "${YELLOW} [+] Remote File System status:"${NC}
					echo
					systemctl status remote-fs.target
					echo
					clear
					echo
					echo -e "${YELLOW}    Follow these instruction to verify everything setup correctly: "${NC}
					echo
					echo -e "${YELLOW} [+] Step 1: Reboot the Secondary Server, type: ${BLUE}reboot or init 6${YELLOW}."${NC}
					echo -e "${YELLOW} [+] Step 2: After reboot, type: ${BLUE}tail -l /etc/fstab; mount | grep nfsexport${YELLOW} to verify."${NC}
					break
				;;
				*)
					echo
					echo -e "${RED} *** Invalid Choice *** "${NC}
					break
				;;
				esac
				done
					echo
					echo
					echo -e "$PAKTGB"
					$READAK		
	}
	
	export -f f_nfs

##############################################################################################################

#Exercise 15: Configuring a SAMBA Server
f_sambaserver() {
		#Install Samba silent
			clear
			kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1`
			yum install -y -q samba samba-client cifs-utils
			yum update -y -q samba samba-client cifs-utils
			echo
		#Ask to create users or config SMB
			clear
			echo
			echo -e "${YELLOW} [*] Choose your option:"${NC}
			echo
			select samba_data in "Create New Samba User" "Configure Samba Shared"
			do
			case $samba_data in
				"Create New Samba User")
					clear
					echo
				#Get user info
					echo -e -n "${YELLOW} [+] Input new username (Example: ${BLUE}tara${YELLOW}): "${NC}
					read samba_user
					echo -e -n "${YELLOW} [+] Input New Password: "${NC}
					read samba_user_passwd
					echo -e -n "${YELLOW} [+] Input Samba group name: "${NC}
					read samba_group
				#Create SAMBA Users
					echo
				useradd -s /sbin/nologin $samba_user
				#Create Samba Password
					(echo "$samba_user_passwd";sleep 2; echo "$samba_user_passwd") | smbpasswd -s -a $samba_user
				#Create SAMBA Group	
					groupadd $samba_group				
				#Add to SMB group
					usermod -aG $samba_group $samba_user
					echo
					echo
					echo -e "$PAKTC"
					$READAK
					clear
					echo
					echo -e "${YELLOW} [*] Created new SAMBA User ${BLUE}'$samba_user'${YELLOW} with the password is ${BLUE}'$samba_user_passwd'${YELLOW} sucessfully!"${NC}
					echo
					#List who in group
					echo -e "${YELLOW} [*] Listing all users in group ${BLUE}'$samba_group'${YELLOW}:"${NC}
					echo
					lid -g $samba_group
				break
				;;
				"Configure Samba Shared")
				#Install SAMBA
					clear
					echo
					echo -e "${YELLOW} [*] Choose your current running server:"${NC}
					echo
					######
				#Choose between 2 server (Primary and Secondary)
					select smb_server in "Primary Server" "Secondary Server"
					do
					case $smb_server in
						"Primary Server")
							clear
							echo
							echo -e "${YELLOW}${BLINK} [+] Installing ${BLUE}SAMBA${YELLOW}..."${NC}
							echo
							kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1`
							yum remove -y -q samba samba-client cifs-utils
							yum install -y -q samba samba-client cifs-utils
							yum update -y -q samba samba-client cifs-utils
							clear
							echo
							echo -e -n "${YELLOW} [+] Input new PATH to create Samba Shared folder (Example: ${BLUE}/data/sambashare${YELLOW}): "${NC}
							read samba_newfolder
							echo
							echo -e -n "${YELLOW} [+] Input Samba group name: "${NC}
							read samba_group
							echo
							echo -e -n "${YELLOW} [+] Input SAMBA user just created: "${NC}
							read samba_user_data
							clear
							echo
							echo -e "${YELLOW} [+] Create new folder (${BLUE}$samba_newfolder${YELLOW}). "${NC}
							rm -rf $samba_newfolder; mkdir -pv $samba_newfolder
						#Set permission on the shared
							echo
							echo -e "${YELLOW} [*] Set permission 775 on folder. "${NC}
							chgrp $samba_group $samba_newfolder; chmod 775 $samba_newfolder
							ls -l -d $samba_newfolder
						#Backup and config files smb.conf
							echo
							echo -e "${YELLOW} [*] Backup and configure file (${BLUE}/etc/samba/smb.conf${YELLOW})."${NC}
							cp -a /etc/samba/smb.conf /etc/samba/smb.conf.bk
							sed -i 's|workgroup = SAMBA$|workgroup = mysamba|' /etc/samba/smb.conf
								echo "
							[sambashare]
									comment = My Samba Share
									path = $samba_newfolder
									write list = @$samba_group" >> /etc/samba/smb.conf
							echo
						#Check verify error
							echo -e "${YELLOW} [*] Check syntax error on ${BLUE}smb.conf${YELLOW} file."${NC}
							testparm
							clear
						#Restart SMB service
							echo
							echo -e "${YELLOW} [*] SAMBA status:"${NC}
							echo
							systemctl enable smb; systemctl restart smb; systemctl status smb
							netstat -nlpt | grep smb
							echo
							echo
							echo -e "$PAKTC"
							$READAK
						#Test login anonymous to SMB
							clear
							echo
							echo -e "${YELLOW} [*] Open new tab and type: ${BLUE}'smbclient -L localhost'${YELLOW} to verify that the share is available. "${NC}
							echo -e "${YELLOW}     (Don't input the password, just press ${BLUE}'Enter'${YELLOW})."${NC}
							echo
							echo
							echo -e "$PAKTC"
							$READAK
							clear
						#Turn off SELInux and Firewalld
							echo
							echo -e "${YELLOW} [-] Switch off SELinux and Firewalld." ${NC}
							setenforce 0; getenforce; systemctl stop firewalld; systemctl status firewalld
						#Config Firewalld and SELinux
							echo
							echo -e "${YELLOW} [*] Configure Samba Server firewall and SELinux."${NC}
							semanage fcontext -a -t samba_share_t "${samba_newfolder}(/.*)?"
							restorecon -Rv $samba_newfolder
							echo
						#Add SAMBA service (Firewalld)
							echo -e "${YELLOW} [+] Add SAMBA service from Firewalld."${NC}
							systemctl start firewalld; firewall-cmd --add-service=samba --permanent
							firewall-cmd --reload; firewall-cmd --list-services
							echo
							#Verify access the share
							echo -e "${YELLOW} [*] Verify user ${BLUE}'$samba_user_data'${YELLOW} able to access the share folder."${NC}
							mount -o username=$samba_user_data //localhost/sambashare /mnt;mount | grep $samba_user_data
							echo
							echo -e "${YELLOW} [*] Configure ${CYAN}SAMBA Server${YELLOW} successfully! "${NC}
					break
					;;
					"Secondary Server")
						#Install SAMBA CLIENT
							clear
							echo
							echo -e "${YELLOW}${BLINK} [+] Installing ${BLUE}SAMBA Client${YELLOW}..."${NC}
							echo
							kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1`
							yum remove -y -q samba-client cifs-utils
							yum install -y -q samba-client cifs-utils
							yum update -y -q samba-client cifs-utils
							clear
							echo
							echo -e -n "${YELLOW} [+] Input PATH to Samba Shared folder (Example: ${BLUE}/data/sambashare${YELLOW}): "${NC}
							read samba_folder
							echo
							echo -e -n "${YELLOW} [+] Input SAMBA Server IP (Primary): "${NC}
							read samba_server_ip
							echo
							echo -e -n "${YELLOW} [+] Input SAMBA user just created: "${NC}
							read samba_user_data
							echo
							echo -e -n "${YELLOW} [+] Input SAMBA user password: "${NC}
							read samba_user_passwd_data
							clear
						#Create new SAMBA user folder
							echo
							echo -e "${YELLOW} [+] Create a mount point (${BLUE}/mnt/$samba_user_data${YELLOW})."${NC}
							mkdir /mnt/$samba_user_data
							echo
						#Check if SAMBA shared folder is available
							echo -e "${YELLOW} [*] Check if SAMBA shared folder is available."${NC}
							echo -e "${YELLOW}     (If you do not see it, try to fix it before continuing)."${NC}
							smbclient -L //$samba_server_ip
							mount -o username=$samba_user_data //$samba_server_ip/sambashare /mnt/$samba_user_data
							mount | grep $samba_user_data
							echo
						#Verify that SAMBA User can write files in the SAMBA shared folder
							echo -e "${YELLOW} [+] Create test file (${BLUE}/mnt/$samba_user_data/testfile${YELLOW}) to test that SAMBA user can write files in the SAMBA Shared Folder."${NC}
							touch /mnt/$samba_user_data/testfile; umount /mnt/$samba_user_data
							echo
						#Log-in to Primary Server to verify it.
							echo -e "${YELLOW} [*] Log-in to SAMBA Server (Primary) and type: ${BLUE}'ll PATH_SAMBA_FOLDER'${YELLOW} (Example: /data/sambashare) to verify it."${NC}
							echo
						#Verify that it can be accessed using a credentials file as well.
							echo -e "${YELLOW} [+] Create the file (${BLUE}root/smbusers${YELLOW}) to access using a credentials file."${NC}
							echo "
							username=$samba_user_data
							password=$samba_user_passwd_data" > /root/smbusers
						#Backup and add data to /etc/fstab
							cp -a /etc/fstab /etc/fstab.bk
							echo "//$samba_server_ip/sambashare /mnt/$samba_user_data cifs credentials=/root/smbusers,_netdev 0 0" >> /etc/fstab
						#The SAMBA share should now be mounted automatically
							mount -a
						#After verifying that it mounts using 'mount -a' , you can reboot server2 to verify the mount comes up after a reboot as well.
							echo
							echo -e "${CYAN} [*] ${YELLOW}Try to reboot this Server and verify that the mount comes up after a reboot as well (${BLUE}/mnt/$samba_user_data${YELLOW})."${NC}
					break		
					;;
					*)
					echo
					echo -e "${RED} *** Invalid Choice *** "${NC}
					break
					;;    
					esac 
					done
				######
				break
				;;
				*)
				echo
				echo -e "${RED} *** Invalid Choice *** "${NC}
				break
				;; 
			esac
			done
		echo
		echo
		echo -e "$PAKTGB"
		$READAK  
	}	

##############################################################################################################

#Exercise 16: Setting up SMTP Server, configuring a Postfix Null Client Setup
f_smtpserver() {
		clear
		echo
		#Need to confirm DNS server installed before running SMTP
		echo -e -n "${CYAN} [*] ${YELLOW}Did you installed DNS Server (Bind/Unbound)? [YES/NO]: "${NC}
		read ask_install_dns
		case $ask_install_dns in
		yes|Yes|YES|y|Y)
		;;
		no|No|NO|n|N)
			f_dns_bind
		;;
		*)
		echo
		echo -e "${RED} *** Invalid Choice *** ${NC}"
		break
		;;    
		esac
		#####
		clear
		echo
		echo -e "${YELLOW} [*] Choose your current running server to setting up SMTP:"${NC}
		select smtp_choose_server in "Primary Server" "Secondary Server"
		do
		case $smtp_choose_server in
		"Primary Server")
			clear
			echo
			echo -e -n "${YELLOW} [+] Your Primary Name Server (Example: ${BLUE}fptjetking1.example.com${YELLOW}): "${NC}
			read smtp_server1
			echo -e -n "${YELLOW} [+] Your Secondary Name Server (Example: ${BLUE}fptjetking2.example.com${YELLOW}): "${NC}
			read smtp_server2
			clear
			echo
			echo -e "${YELLOW} [*] Create backup and config file (${BLUE}/etc/postfix/main.cf${YELLOW})"${NC}
			cp -a /etc/postfix/main.cf /etc/postfix/main.cf.bk
			postconf -e 'myorigin = $mydomain'; postfix check; systemctl reload postfix
			#Config a postfix null client setup
			host $smtp_server2; postconf -e "relayhost = [${smtp_server2}]"
			postconf -e 'inet_interfaces=loopback-only'
			postconf mynetworks
			postconf -e 'mydestination='
			postconf -e 'inet_protocols=ipv4'
			postconf -e 'mydomain=example.com'
			systemctl restart postfix
			postconf -n
			echo
			echo -e "${YELLOW} [*] ${RED}Stop here!${YELLOW} Run this tool on Secondary Server to install ${CYAN}SMTP${YELLOW} first."${NC}
			echo
			echo
			echo -e "$PAKTC"
			$READAK
			clear
			echo
			mail -s testfile1 root@$smtp_server2 < .; tail /var/log/maillog
			break
		;;
		"Secondary Server")
			clear
			echo
			echo -e -n "${YELLOW} [+] Your Primary Name Server (Example: ${BLUE}fptjetking1.example.com${YELLOW}): "${NC}
			read smtp_server1
			echo -e -n "${YELLOW} [+] Your Secondary Name Server (Example: ${BLUE}fptjetking2.example.com${YELLOW}): "${NC}
			read smtp_server2
			clear
			echo
			echo -e "${YELLOW} [*] Create backup and config file (${BLUE}/etc/postfix/main.cf${YELLOW})"${NC}
			cp -a /etc/postfix/main.cf /etc/postfix/main.cf.bk
			host $smtp_server1
			postconf -e 'inet_interfaces=all'
			postconf -e "mydestination = example.com,${smtp_server2}"
			postconf -e 'inet_protocols = ipv4'
			postconf mynetworks
			systemctl restart postfix
			echo
			echo -e "${YELLOW} [+] Add ${BLUE}SMTP${YELLOW} service (Firewalld)..."${NC}
			firewall-cmd --add-service=smtp --permanent; firewall-cmd --reload;firewall-cmd --list-services
			yum install -y -q mailx; yum update -y -q mailx
			postconf -n
			echo
			echo -e "${YELLOW} [*] ${RED}Stop here!${YELLOW} Come back to ${CYAN}Primary Server${YELLOW} and finish it."${NC}
			echo -e "${YELLOW}     After that, back to this Server and check the result."${NC}
			echo
			echo
			echo -e "$PAKTC"
			$READAK
			clear
			echo
			echo -e "${YELLOW} [*] Verify that you see the test message from the Primary Server."${NC}
			mail
			break
		;;
		*)
		echo
		echo -e "${RED} *** Invalid Choice *** ${NC}"
		break
		;;    
		esac 
		done
		#####
		echo
		echo
		echo -e "$PAKTGB"
		$READAK  
}

##############################################################################################################

#Exercise 17: Configuring SSH Security Options (Config on SV1 and test on SV2)
f_ssh() {
		clear
		echo
		echo -e -n "${YELLOW} [+] Input new SSH Port (Example: ${BLUE}2022${YELLOW}): "${NC}
		read ssh_secureport
		echo -e -n "${YELLOW} [+] Input Username allow to connect via SSH: "${NC}
		read ssh_allowuser
		echo -e -n "${YELLOW} [+] Input this Server IP: "${NC}
		read ssh_serverip
		clear
		echo
		echo -e "${YELLOW} [+] Create backup and config file (${BLUE}/etc/ssh/sshd_config${YELLOW})."${NC} 
		cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.bk
echo "Port 22
Port $ssh_secureport
AllowUsers $ssh_allowuser" >> /etc/ssh/sshd_config
		echo
		systemctl restart sshd
	#Config SELinux
		echo -e "${YELLOW} [*] Configure SELinux:"${NC}
		semanage port -a -t ssh_port_t -p tcp $ssh_secureport; getenforce
		echo
	#Add port (Firewalld)
		echo -e "${YELLOW} [+] Enable port ${BLUE}$ssh_secureport${YELLOW} (Firewalld):"${NC}
		firewall-cmd --add-port=${ssh_secureport}/tcp --permanent; firewall-cmd --reload
		systemctl restart sshd; systemctl restart firewalld
		echo
	#Status SSHD
		echo -e "${YELLOW} [*] SSHD status:"${NC}
		systemctl status -l sshd
		echo
		echo
		echo -e "$PAKTC"
		read $READAK
		clear
		echo
		echo -e "${YELLOW} [*] Try to log-in to SSH Server from another Server (using: ${BLUE}ssh -p $ssh_secureport $ssh_allowuser@$ssh_serverip${YELLOW})."${NC} 
		echo -e "${YELLOW}     On SSH Server, to check SSH log, type: ${BLUE}'tail /var/log/secure'${YELLOW}."${NC}
		echo
		echo
		echo -e "$PAKTGB"
		read $READAK
}

##############################################################################################################

#Exercise 18: Setting up Remote Logging on Server
f_rsyslog() {
		clear
		echo
		echo -e -n "${YELLOW} [+] Input this Server IP (Example: ${BLUE}192.168.15.100${YELLOW}): "${NC}
		read rsyslog_serverip
		echo -e -n "${YELLOW} [+] Input new port for Remote Logging (Example: ${BLUE}514${YELLOW}): "${NC}
		read rsyslog_port
		echo -e "${YELLOW} [+] Create backup and config file (${BLUE}/etc/rsyslog.conf${YELLOW})."${NC} 
		cp -a /etc/rsyslog.conf /etc/rsyslog.conf.bk
		sed -i 's|#$ModLoad imtcp|$ModLoad imtcp|' /etc/rsyslog.conf
		sed -i 's|#$InputTCPServerRun 514|$InputTCPServerRun 514|' /etc/rsyslog.conf
		systemctl restart rsyslog
		echo
		echo -e "${YELLOW} [+] Enable port $rsyslog_port (Firewalld):"${NC}
		firewall-cmd --add-port=${rsyslog_port}/tcp --permanent; firewall-cmd --reload; firewall-cmd --list-ports
		echo
		echo -e "${YELLOW} [*] Rsyslog status:"${NC}
		systemctl restart rsyslog; systemctl status rsyslog
		echo
		echo
		echo -e "$PAKTC"
		read $READAK
		clear
		echo
		echo -e "${YELLOW} Log-in to another Server and add this line to file (/etc/rsyslog.conf): ${BLUE}*.* @@${rsyslog_serverip}:${rsyslog_port}."${NC}
		echo -e "${YELLOW} Then type: ${BLUE}systemctl restart rsyslog${YELLOW} to restart service."${NC}
		echo
		echo
		echo -e "$PAKTGB"
		read $READAK
}

##############################################################################################################

#Update This Tools (Source from Github)
f_updatetools() {
		clear
		echo
	#Install GIT package
		echo -e "${YELLOW}${BLINK} [+] Installing ${BLUE}GIT Package${YELLOW}..."${NC}
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1`
		yum install -y -q git; yum update -y -q git
	#Check if folder existing
		clear
		echo
		echo -e "${YELLOW} [*] Check for updates this tool."${NC}
		echo
		if [[ -d /opt/fedora-automatic-tools ]]; then
			echo -e "${YELLOW}${BLINK} [+] ${CYAN}Updating tool${YELLOW}..."${NC}
			cd /opt/fedora-automatic-tools
		#This command is up-to-date tools if it has new version.
			git reset --hard HEAD
			git pull; chmod +x automatic-script.sh
			echo
			clear
			echo
			echo -e "${YELLOW} [*] Updated tool successfully!"${NC}
		else
			echo -e "${YELLOW}${BLINK} [+] ${CYAN}Downloading tool${YELLOW}..."${NC}
		#Download sources from Github
			cd /opt/
			git clone https://github.com/Despereaux222/fedora-automatic-tools.git
			cd /opt/fedora-automatic-tools; chmod +x automatic-script.sh
			clear
			echo
			echo -e "${YELLOW} [*] This tool has been downloaded success in directory (${BLUE}/opt/fedora-automatic-tools${YELLOW})."${NC}
			echo -e "${YELLOW}     Let's type: ${CYAN}./automatic-script.sh${YELLOW} to enjoy the new version!!!"${NC}
		fi
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
}

##############################################################################################################

#Update CentOS (Software)
f_updatecentos() {
		clear
		echo
		echo -e "${YELLOW} [*] Check the version of your current release:"${NC} 
		echo
		cat /etc/centos-release
		echo
		echo -e "${YELLOW} [*] Check for available updates:"${NC} 
		echo
		yum check-update
		echo
		echo -e "${CYAN} [*] ${YELLOW}Here is a list of available updates ${BLUE}(Including the core Operating System updates)${YELLOW}."${NC}
		echo -e "${YELLOW}     Backing up important server data should be done before running a Operating System upgrade."${NC} 
		echo -e "${BLUE}     (Take a moment to verify your system backups)."${NC}
		echo
		echo
		echo -e -n "${YELLOW} Do you want to continue? ${CYAN}[YES/NO]${YELLOW}: "${NC}
			read confirm_update
		case $confirm_update in
			yes|Yes|YES|y|Y)
			clear
			echo
			echo -e "${YELLOW} [-] Clear the caches and lists in the local yum repositories."${NC} 
			echo
			yum clean all; yum update; clear
			echo
			echo -e "${YELLOW} [*] Verify the current version on CentOS after updated."${NC} 
			echo
			cat /etc/centos-release
			;;
			no|No|NO|n|N)
			;;
			*)
			echo
			echo -e "${RED} *** Invalid Choice *** "${NC}
			break
			;;    
			esac 

		echo
		echo
		echo -e "$PAKTGB"
		$READAK	
}
##############################################################################################################

#Searching Software/Application
f_search() {
		clear
		echo
	#Identified Application	
		echo -e -n "${YELLOW}Input your Application: "${NC}
		read application
		
	#Check Application installed or not yet
		echo
		kill -9 `ps -aux | grep yum |tr -s " " : | cut -f2 -d : | head -1` ; yum install -y -q dnf; yum update -y -q dnf && clear
		echo
		dnf search $application
		echo
	#Check for no answer
		if [[ -z $application ]]; then
			echo
			clear
			echo
			echo -e "${YELLOW}Please input exactly what you need to find."${NC}	
		fi	
			echo
			echo
			echo -e "$PAKTGB"
			$READAK		
	}

##############################################################################################################
	
#Check the Internect connecting
f_checkinternet() {
		clear
		echo
		echo -e "${YELLOW}${BLINK} [*] Checking the network connection, please wait... "${NC}
		if ping -q -c 1 -W 1 google.com >/dev/null; then
		echo
	#Check Local IP
		clear
		local_ip=$(ifconfig | grep -w inet | awk '{print $2}')	
		echo
		echo -e "${CYAN}[*] ${YELLOW}Here is your IP information details: "${NC}
		echo
		echo -e "${YELLOW}[+] Local IP:"${NC}
		echo -e "${BLUE}$local_ip"${NC}
		echo
	#Check DNS-1
		dns=$(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')
		echo -e "${YELLOW}[+] DNS:"${NC}
		echo -e "${BLUE}$dns"${NC}
		echo
	#Check Gateway
		gateway=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
		echo -e "${YELLOW}[+] Gateway: ${BLUE}$gateway${NC}"
		echo
	#Check Public IP
		public_ip=$(wget -qO - https://api.ipify.org)
		echo -e "${YELLOW}[+] Public IP: ${BLUE}$public_ip"${NC}
		else
			clear
			echo
			echo -e "${RED}FAILED!!! "${NC}
			echo
			echo -e "${YELLOW}Please check your network connection and try again..."${NC}
		fi
		echo
		echo
		echo -e "$PAKTGB"
		$READAK
	}

##############################################################################################################

#Building Menu:
f_main(){
	clear
	f_banner
	#Main Menu:
                echo -e "${CYAN}        BASIC${NC}                                 ${CYAN}ADVANCED${NC}                           ${CYAN}OTHERS"${NC}
                echo
                echo -e "${YELLOW}1.  Config Network                  10.  Manage Apache Services          90.  Check for Updates"
                echo -e          "2.  Connect Putty                   11.  Config DNS (Unbound)            91.  Update CentOS"
                echo -e          "3.  Change Hostname                 12.  Config DNS (Bind)               92.  Search Software"
                echo -e          "4.  Create New User                 13.  Create Basic Shell              93.  Check IP"
                echo -e          "5.  Config Timedate                 14.  Config NFS                      00.  Exit"
                echo -e          "6.  Create New LVM                  15.  Config SMB"
                echo -e          "7.  Enable Services (Firewalld)     16.  Config SMTP"
                echo -e          "8.  Create Web Server               17.  Create SSH Security"
                echo -e          "9.  Create FTP Anonymous Drop Box   18.  Setup Remote Logging"${NC}
                echo
				
	echo -e -n "${BLUE}Your Choice: "${NC}
		read choice

		case $choice in
		1) f_setip;;
		2) f_putty;;
		3) f_hostname;;
		4) f_newuser;;
		5) f_timedate;;
		6) f_newlvm;;
		7) f_openservice;;
		8) f_webserver;;
		9) f_anon_dropbox;;
		10) f_apache;;
		11) f_dns_unbound;;
		12) f_dns_bind;;
		13) f_basicshell;;
		14) f_nfs;;
		15) f_sambaserver;;
		16) f_smtpserver;;
		17) f_ssh;;
		18) f_rsyslog;;
		90) f_updatetools;;
		91) f_updatecentos;;
		92) f_search;;
		93) f_checkinternet;;
		00) clear && exit;;
		*) f_error;;
		esac
	}

	export -f f_main

##############################################################################################################

while true; do f_main; done