#! /bin/bash

HOST = hostname

if [ "$EUID" -ne 0 ]; then	
	echo "Please run this script as root"
	exit
fi
if [[ -d "/home/user/" ]]; then
	cd /home/user/Downloads
else
	echo "You have set the wrong username for the ubuntu installation, please reinstall with a user named user"
	exit
fi
git clone https://github.com/scriptsandsuch/sg-script.git
wget https://s3.eu-central-1.amazonaws.com/airgap.anyvision.co/better_environment/betterenvironment-181202-142-linux-x64-installer.run https://s3.eu-central-1.amazonaws.com/facesearch.co/installbuilder/1.20.0/FaceRec-1.20.0-66-local-gpu-linux-x64-installer.run https://download.teamviewer.com/download/linux/teamviewer_amd64.deb

chmod 777 better*
chmod 777 Face*
apt install vlc curl vim htop net-tools git -y
apt install ./team* -y
add-apt-repository --yes --update ppa:graphics-drivers/ppa
apt install nvidia-driver-410
mkdir /home/user/moxa-config/you
mv /home/user/Downloads/sg-script/moxa_e1214.sh /home/user/moxa-config/
mv /home/user/Downloads/sg-script/cameraList.json /home/user/moxa-config/
touch /tmp/sgflag

echo -e "\e[1m Please Rebbot your machine, then isntall the enviroment and FaceRec, after that run this script again"

##To be continued


