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
##Download files and install what is needed
wget https://s3.eu-central-1.amazonaws.com/facesearch.co/installbuilder/1.20.0/FaceRec-1.20.0-66-local-gpu-linux-x64-installer.run 
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
chmod +x Face*
apt install vlc curl vim htop net-tools git apt-transport-https ca-certificates software-properties-common -y
git clone https://github.com/scriptsandsuch/sg-script.git
apt install ./team* -y

##install enviroment
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" 
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
apt update
sudo apt-get install docker-ce=5:18.09.7~3-0~ubuntu-bionic -y
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
add-apt-repository --yes --update ppa:graphics-drivers/ppa
apt install nvidia-driver-410 nvidia-modprobe -y
sudo apt-get install -y nvidia-docker2
	sudo tee /etc/docker/daemon.json <<'EOF'
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
sudo pkill -SIGHUP dockerd

##moxa set up
mkdir /home/user/moxa-config/
mv /home/user/Downloads/sg-script/moxa_e1214.sh /home/user/moxa-config/
mv /home/user/Downloads/sg-script/cameraList.json /home/user/moxa-config/
chmod +x /home/user/moxa-config/*
echo "1" > /opt/sg.f

echo -e "Please reboot your machine, then isntall FaceRec, uncheck "start services" on the end of the installation after that run this script again"
 
}


##second iteration
after_reboot(){
##edit env and yml
tee /home/user/docker-compose/1.20.0/env/broadcaster.env <<'EOF'
## Modbus plugin integration
BCAST_MODBUS_IS_ENABLED=true
BCAST_MODBUS_CMD_PATH=/home/user/moxa-config/moxa_e1214.sh
BCAST_MODBUS_CAMERA_LIST_PATH=/home/user/moxa-config/cameraList.json
EOF
##echo -e "\n## Modbus plugin integration" >> /home/user/docker-compose/1.20.0/env/broadcaster.env
##echo 'BCAST_MODBUS_IS_ENABLED=true' >> /home/user/docker-compose/1.20.0/env/broadcaster.env
##echo 'BCAST_MODBUS_CMD_PATH=/home/user/moxa-config/moxa_e1214.sh' >> /home/user/docker-compose/1.20.0/env/broadcaster.env
##echo 'BCAST_MODBUS_CAMERA_LIST_PATH=/home/user/moxa-config/cameraList.json' >> /home/user/docker-compose/1.20.0/env/broadcaster.env
line=$(grep -nF broadcaster.tls.ai /home/user/docker-compose/1.20.0/docker-compose.yml  | awk -F: '{print $1}')
pos=$((line+2))
host=$(hostname)
sed -i "${pos}i \      - \/home\/user\/moxa-config:\/home\/user\/moxa-config" /home/user/docker-compose/1.20.0/docker-compose.yml 
sed -i "s|nginx-\${node_name:-localnode}.tls.ai|nginx-$host.tls.ai|g" /home/user/docker-compose/1.20.0/docker-compose.yml
sed -i "s|api.tls.ai|api-$host.tls.ai|g" /home/user/docker-compose/1.20.0/docker-compose.yml

##finalize setup
cd /home/user/docker-compose/1.20.0/
docker-compose up -d
footprint=$(docker exec -it $(docker ps | grep backend | awk '{print $1}') license-ver -o)
echo "your footprint is:"
echo $footprint
echo "2" > /opt/sg.f

echo "DONE!"
}

if [[ -f "/opt/sg.f" ]]; then
	after_reboot
else
	before_reboot
fi
