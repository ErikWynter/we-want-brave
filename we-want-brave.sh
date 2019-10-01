#!/usr/bin/env bash

#check for sudo privileges
if [ "$EUID" != '0' ]; then
	echo 'Please run this script with sudo privileges:
"sudo bash [location to script directory]/we-want-brave.sh"'
	exit
fi
echo

#main menu
echo 'Welcome to We Want Brave, the unofficial Brave browser installer for Debian-based Linux systems!'; echo
echo 'This is a small script, but for the aesthetically inclined it comes with a huge logo that requires the window to be maximized.'; echo
while true; do
	echo "What would you like to do?
1) I have maximized my window, so show me the logo and start installing.
2) Just install Brave! I don't care about fancy logos.
3) Please get me out of here."
	read choice

#option1: print We Want Brave logo
    if [[ "$choice" = '1' ]]; then
		clear
		echo '
  ###                        ###         ####               ###                        ###        ####             ######         ###          ###  
   ###                      ###     #############            ###                      ###     #############       ###  ###        ###  ###################
    ###                    ###     ###          ###           ###                    ###    ###          ###      ###   ###       ###          ###
     ###       ####       ###     ###            ###           ###       ####       ###    ###           ###      ###    ###      ###          ###
      ###     ######     ###     ###################            ###     ######     ###         #############      ###     ###     ###          ###
       ###   ###  ###   ###      ###                             ###   ###  ###   ###       #######      ###      ###      ###    ###          ###
        ### ###    ### ###        ###            ###              ### ###    ### ###       ###           ###      ###       ###   ###          ###
         #####      #####          ###          ###                #####      #####        ###          ####      ###        ###  ###           ###
          ###        ###             ############                   ###        ###          ############  #####   ###         ######             #########
 

                     ###############
                 #######################
            ################################
           #####  #######      #######  #####
         #######                        #######
          #####                          #####           ###
         ####     <######      ######>     ####          ###
        ####           ##      ##           ####         ###     ###                 ####        ####       ###              ###       ####
         ####           #      #           ####          ###  #########       ###  ######    #############   ###            ###   #############
          #####        ##      ##        #####           #####         ####   #####        ###          ###   ###          ###   ###          ###
          ######      ###      ###      ######           ###            ###   ####        ###           ###    ###        ###   ###            ###
           #######      ########      #######            ###             ###  ###             #############     ###      ###   ###################
            ######         ##         ######             ###             ###  ###          #######      ###      ###    ###    ###
            #####         ####         #####              ##             ##   ###         ###           ###       ###  ###      ###            ###
             #####     ####  ####     #####                ###         ###    ###         ###          ####        ######        ###          ###
             ##########          ##########                  ###########      ###          ############  #####      ####           ############
              ########            ########
               ########          ########
                ##########    ##########
                  ####################
                    ################
                       ##########
                          ####
'
		sleep 1

#option 2: skip to install
	elif [[ "$choice" = '2' ]]; then
		:

#option 3: quit
	elif [[ "$choice" = '3' ]]; then
		echo 'Goodbye!'
		exit 0

#verify input
	else
		echo "Invalid input, please try again."
		continue
	fi
	break
done

#perpare installation process
echo
echo 'Installing Brave repository key'
url='https://brave-browser-apt-release.s3.brave.com/brave-core.asc'
curl -s $url | apt-key add -

#verify if both commands ran successfully, otherwise exit
if [[ ${PIPESTATUS[0]} -ne 0 || ${PIPESTATUS[1]} -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

#continue
echo 'Adding Brave apt repository'
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ bionic main" | tee /etc/apt/sources.list.d/brave-browser-release-bionic.list > /dev/null

#verify if both commands ran successfully, otherwise exit
if [[ ${PIPESTATUS[0]} -ne 0 || ${PIPESTATUS[1]} -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

#continue
echo 'Updating package lists'
apt update

#verify if command ran successfully, otherwise exit
if [[ $? -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

#continue
echo 'Installing Brave browser'
apt install brave-browser brave-keyring

#verify if command ran successfully, otherwise exit
if [[ $? -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

#check if namespaces have been enabled in the kernel, which is required for Brave to run
echo 'Checking namespaces'
if [[ -e "/etc/sysctl.d/00-local-userns.conf" ]] && grep -q 'kernel.unprivileged\_userns\_clone=1' /etc/sysctl.d/00-local-userns.conf; then
	#verify if command ran successfully, otherwise exit
	if [[ $? -ne 0 ]] ; then
		echo "An error occurred. Quitting"
		exit
	fi
else
	echo 'Enabling namespaces'
	echo 'kernel.unprivileged\_userns\_clone=1' > /etc/sysctl.d/00-local-userns.conf
	#verify if command ran successfully, otherwise exit
	if [[ $? -ne 0 ]] ; then
		echo "An error occurred. Quitting"
		exit
	fi
	
	#continue
	echo 'Restarting procps'
	service procps restart > /dev/null
	#verify if command ran successfully, otherwise exit
	if [[ $? -ne 0 ]] ; then
		echo "An error occurred. Quitting"
		exit
	fi
fi

echo
echo 'Installation complete'

#option to launch Brave
echo 'To start Brave from the command line, run "brave-browser". Please not that you cannot run Brave as root.'; echo
while true; do
	echo 'Would you like this script to launch Brave now? [y/n]'
	read choice
	if [[ "$choice" = 'y' ]]; then
		echo 'Please enter your username:'
		while true; do
			read username
			#The below command checks the user id. If a user exists, it returns 0, otherwise it returns 1.
			id $username >/dev/null
			if [[ $? -ne 0 ]] ; then
				echo "The user you entered does not exist. Please enter a different username:"
				continue
			elif [[ "$username" = 'root' ]]; then
				echo "You cannot run Brave as root. Please enter a different username:"
				continue
			else
				sudo -u $username brave-browser
				exit
			fi
			break
		done
	elif [[ "$choice" = 'n' ]]; then
		echo 'Goodbye!'
		exit
	else
		echo "Invalid input, please try again."
		continue
	fi
	break
done
