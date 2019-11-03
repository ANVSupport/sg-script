#! usr/bin/env bash
before_reboot() {
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
wget https://s3.eu-central-1.amazonaws.com/airgap.anyvision.co/better_environment/betterenvironment-181202-142-linux-x64-installer.run https://s3.eu-central-1.amazonaws.com/facesearch.co/installbuilder/1.20.0/FaceRec-1.20.0-66-local-gpu-linux-x64-installer.run https://download.teamviewer.com/download/linux/teamviewer_amd64.deb

chmod 777 better*
chmod 777 Face*
apt install vlc curl vim htop net-tools git -y
git clone https://github.com/scriptsandsuch/sg-script.git
apt install ./team* -y
add-apt-repository --yes --update ppa:graphics-drivers/ppa
apt install nvidia-driver-410 -y
mkdir /home/user/moxa-config/
mv /home/user/Downloads/sg-script/moxa_e1214.sh /home/user/moxa-config/
mv /home/user/Downloads/sg-script/cameraList.json /home/user/moxa-config/
chmod +x /home/user/moxa-config/*
touch /tmp/sg.f

echo -e "\e[1m Please Rebbot your machine, then isntall the enviroment and FaceRec, after that run this script again"
 
}
after_reboot(){
echo -e "\n## Modbus plugin integration" >> /home/user/docker-compose/1.20.0/env/broadcaster.env
echo 'BCAST_MODBUS_IS_ENABLED=true' >> /home/user/docker-compose/1.20.0/env/broadcaster.env
echo 'CAST_MODBUS_CMD_PATH=/home/user/moxa-config/moxa_e1214.sh' >> /home/user/docker-compose/1.20.0/env/broadcaster.env
echo 'BCAST_MODBUS_CAMERA_LIST_PATH=/home/user/moxa-config/cameraList.json' >> /home/user/docker-compose/1.20.0/env/broadcaster.env

line=$(grep -nF broadcaster.tls.ai /home/user/docker-compose/1.20.0/docker-compose.yml  | awk -F: '{print $1}')
pos=$((line+2))
host=$(hostname)
sed -i "${pos}i \      - \/home\/user\/moxa-config:\/home\/user\/moxa-config" /home/user/docker-compose/1.20.0/docker-compose.yml 
sed -i "s|nginx-\${node_name:-localnode}.tls.ai|nginx-$host.tls.ai|g" /home/user/docker-compose/1.20.0/docker-compose.yml
sed -i "s|api.tls.ai|api-$host.tls.ai|g" /home/user/docker-compose/1.20.0/docker-compose.yml

#footprint=$(docker exec -it $(docker ps | grep backend | awk '{print $1}') license-ver -o)
#echo "your footprint is:"
#echo $footprint
#sed -i '0,/FaceSearch/{s/FaceSearch/Safeguard/}' /home/user/dashboard/definitions.json
#cp /home/user/Downloads/sg-script/SGLogo.jpg /home/user/dashboard/images/SGLogo.jpg
}

if [[ -f "/tmp/sg.f" ]]; then
	after_reboot
else
	before_reboot
fi
