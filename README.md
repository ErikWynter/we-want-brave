# We Want Brave
## unofficial Brave browser installer for Linux (Debian-based)

**Background**

Brave browser is awesome, but setting it up on the various Debian-based Linux systems I regularly use, was an utterly exasperating experience. It made me question my computer literacy, my decision to pursue a career in IT, my life choices in general, and even my sanity. But not for a single second did I doubt the superiority of Brave over alternative browsers. Hence, when I finally managed to slay the beast that was this excruciating installation process, I decided to share the wisdom I had acquired so as to spare others the anguish I suffered during this lonesome journey. From this solemn pledge was born *We Want Brave,* a script forged in the flames of frustration, despair and desire. Use it responsibly.

TL;DR
To make Brave browser more accessible to the (Debian-based) Linux community, this script automates the otherwise aggravating installation process. Enjoy.

**How to use**

Just clone or download the repository to your system. Then navigate to the directory from the command line and run the script with sudo privileges by typing **"sudo bash we-want-brave.sh."**

**Dependencies**

- APT (see compatibility)
- Curl - If curl is not present on the host system, the user can choose to let We Want Brave install it before the script proceeds with the Brave installation.  

**Compatibility**

We Want Brave relies on the APT package manager that is used by Debian and Debian-based distros. Since Brave has so far not released specific packages for certain distros, it installs the release for Ubuntu. More specifically, it installs the release for Ubuntu 18.04 (aka Bionic Beaver).

We want Brave has been successfully tested on the following distros:
- Debian
- Kali Linux
- Parrot Home
- Parrot Security
- Ubuntu

We Want Brave should also be compatible with other Debian-based distro's, although this may require slight modifications depending on the distro. If you are running this script on a Debian-based system that isn't mentioned above, please let me know how it goes so I can update the list.

**Note for Kali GNU/Linux users**

Brave cannot run as root. Therefore, Kali users need to create a non-root user on their system in order to run Brave. Fortunately, We Want Brave can do this for you. If you choose to take advantage of this, Brave will create a user account with Bash as its standard shell. This user will not have sudo permissions, but you can add these later if you wish. We Want Brave will add the new user to the audio group and in order to make sure that the new user has permanent access to the display (via X server), it will create/modify the ~/.xinitrc file. For more information about X server and ~/.xinitrc, see the top answer to [this ](https://askubuntu.com/questions/7881/what-is-the-x-server) Ask Ubuntu question.
