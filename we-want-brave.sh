#!/usr/bin/env bash

#check for sudo privileges
if [ "$EUID" != '0' ]; then
	echo 'Please run this script with sudo privileges:
"sudo bash [location to script directory]/we-want-brave.sh"'
	exit
fi
echo

#main menu
echo "Welcome to We Want Brave, the unofficial Brave browser installer for Debian-based Linux systems!" ; echo
echo "This is a small script, but for the aesthetically inclined it comes with a huge logo that requires the window to be maximized."; echo
while true; do
	echo "What would you like to do?
1) I have maximized my window, so show me the logo and start installing.
2) Just install Brave! I don't care about fancy logos.
3) Please get me out of here."
	read choice

#option1: print We Want Brave logo
    if [[ "$choice" -eq 1 ]]; then
		clear
		echo "
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
"
		sleep 1

#option 2: skip to install
	elif [[ "$choice" -eq 2 ]]; then
		:

#option 3: quit
	elif [[ "$choice" -eq 3 ]]; then
		echo "Goodbye!"
		exit

#verify input
	else
		echo "Invalid input, please try again."
		continue
	fi
	break
done

#perpare installation process
echo
echo "Checking if curl is installed."
curl > /dev/null 2>&1
if [[ $? -eq 127 ]] ; then
        while true ; do
	        echo "The curl package is not installed on your system, but is required to complete the installation. Would you like this script to install curl now? [y/n] (choosing n will exit the script)."
                read curl_input
                if [[ $curl_input = 'y' ]] ; then
                        apt install curl
                elif [[ $curl_input = 'n' ]] ; then
                        echo "Installation aborted. Goodbye!"
                        exit
                else
                        echo "Invalid input, please try again."
                        continue
                fi
                break
        done
fi
echo "Installing Brave repository key"
url='https://brave-browser-apt-release.s3.brave.com/brave-core.asc'
curl -s $url | apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
#check if both commands ran successfully, otherwise quit
if [[ ${PIPESTATUS[0]} -ne 0 || ${PIPESTATUS[1]} -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

#continue
echo "Adding Brave apt repository"
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ bionic main" | tee /etc/apt/sources.list.d/brave-browser-release-bionic.list > /dev/null

#verify if both commands ran successfully, otherwise exit
if [[ ${PIPESTATUS[0]} -ne 0 || ${PIPESTATUS[1]} -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

#continue
echo "Updating package lists"
apt update

#verify if command ran successfully, otherwise exit
if [[ $? -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

#continue
echo "Installing Brave browser"
apt install brave-browser

#verify if command ran successfully, otherwise exit
if [[ $? -ne 0 ]] ; then
	echo "An error occurred. Quitting"
	exit
fi

echo
echo "Installation complete"
echo

#check if OS is Kali, which has root as the default user
name_check=$(grep "^NAME" /etc/os-release | cut -d '"' -f 2)
if [[ $name_check = "Kali GNU/Linux" ]] ; then
	echo "You seem to be running $name_check. Please note that in order to run Brave, you need to set up a non-root user with the right pemissions."
	while true ; do
		echo "Do you want the script to create a non-root user for you? [y/n]"
		read create_user
		if [[ $create_user = 'y' ]] ; then
			echo 'Please enter the desired username or enter "root" to cancel.'
			while true ; do
				read new_user
				if [[ "$new_user" = 'root' ]]; then
					echo "Cancelling."
					break
				fi
				id $new_user > /dev/null 2>&1
				if [[ $? -eq 0 ]] ; then
					echo 'The user you entered already exists. Please enter a different username or enter "root" to cancel.'
					continue
				else
					#first command creates $new_user, second adds $new_user to the audio group, third gives $new_user permissions to access the display (~./xinitrc is loaded everytime an xhost server starts), fourth makes sure the user immediately has access to the display, fifth makes sure ~./xinitrc is actually loaded everytime user opens terminal
					adduser --system --group --shell /bin/bash $new_user > /dev/null 2>&1 && adduser $new_user audio > /dev/null && echo "xhost +SI:localuser:$new_user" >> ~/.xinitrc && source ~/.xinitrc && echo "source ~/.xinitrc > /dev/null 2>&1" >> ~/.bashrc
					if [[ $? -ne 0 ]] ; then
						echo 'Invalid username. Please enter a different username or enter "root" to cancel.'
						continue
					else	
						echo "User \"$new_user\" created successfully."
							new_user_check=1 #this variable is used later if the user wants the script to launch Brave, it shows that the $new_user variable can be used to run Brave
					       	passwd $new_user
						if [[ $? -ne 0 ]] ; then
							echo "An error occurred. You may have to set a password for the new user at a later time."
						fi
						echo
						echo "There are two ways to run Brave:
-While logged on as root, run the following command: \"sudo -u $new_user brave-browser\". It is recommended to create an alias for this command.
-While logged on as root, switch to the new user by running: \"su $new_user\" then enter your password and finally run: \"brave-browser\"."
					fi
				fi
				break
			done
		elif [[ $create_user = 'n' ]] ; then
			break
		else
			echo "Invalid input, please try again."
			continue
		fi
		break
	done

else
	echo 'To start Brave from the command line, run: "brave-browser". Please note that you cannot run Brave as root.'
fi
echo
while true; do
	echo "Would you like this script to launch Brave now? [y/n]"
	read choice
	if [[ $choice = 'y' ]]; then
		#check if the $new_user variable is available to run Brave
		if [[ $new_user_check -eq 1 ]] ; then
			username=$new_user
		else
			echo 'Please enter your username or enter "root" to quit:'
			while true; do
				read username
				#The below command checks the user id. If a user exists, it returns 0, otherwise it returns 1.
				id $username >/dev/null
				if [[ $? -ne 0 ]] ; then
					echo "The user you entered does not exist. Please enter a different username:"
					continue
				elif [[ "$username" = 'root' ]]; then
					echo "Goodbye!"
					exit
				fi
				break
			done
		fi
		sudo -u $username brave-browser
	elif [[ "$choice" = 'n' ]]; then
		echo 'Goodbye!'
		exit
	else
		echo "Invalid input, please try again."
		continue
	fi
	break
done
