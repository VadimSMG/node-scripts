#!/bin/bash
echo -e "██████  ▄▄▄      ███▄    █ ▓█████▄  ██▀███  ▄▄▄     ▄▄▄█████▓    ███▄    █ ▒█████  ▓█████▄ ▓█████   ██████ "
echo -e "▒██    ▒ ▒████▄    ██ ▀█   █ ▒██▀ ██▌▓██ ▒ ██▒████▄   ▓  ██▒ ▓▒    ██ ▀█   █▒██▒  ██▒▒██▀ ██▌▓█   ▀ ▒██    ▒ "
echo -e "░ ▓██▄   ▒██  ▀█▄ ▓██  ▀█ ██▒░██   █▌▓██ ░▄█ ▒██  ▀█▄ ▒ ▓██░ ▒░   ▓██  ▀█ ██▒██░  ██▒░██   █▌▒███   ░ ▓██▄  " 
echo -e "▒   ██▒░██▄▄▄▄██▓██▒  ▐▌██▒░▓█▄   ▌▒██▀▀█▄ ░██▄▄▄▄██░ ▓██▓ ░    ▓██▒  ▐▌██▒██   ██░░▓█▄   ▌▒▓█  ▄   ▒   ██▒"
echo -e "▒██████▒▒ ▓█   ▓██▒██░   ▓██░░▒████▓ ░██▓ ▒██▒▓█   ▓██▒ ▒██▒ ░    ▒██░   ▓██░ ████▓▒░░▒████▓ ░▒████▒▒██████▒▒"
echo -e "▒ ▒▓▒ ▒ ░ ▒▒   ▓▒█░ ▒░   ▒ ▒  ▒▒▓  ▒ ░ ▒▓ ░▒▓░▒▒   ▓▒█░ ▒ ░░      ░ ▒░   ▒ ▒░ ▒░▒░▒░  ▒▒▓  ▒ ░░ ▒░ ░▒ ▒▓▒ ▒ ░"
echo -e "░ ░▒  ░ ░  ▒   ▒▒ ░ ░░   ░ ▒░ ░ ▒  ▒   ░▒ ░ ▒░ ▒   ▒▒ ░   ░       ░ ░░   ░ ▒░ ░ ▒ ▒░  ░ ▒  ▒  ░ ░  ░░ ░▒  ░ ░"
echo -e "░  ░  ░    ░   ▒     ░   ░ ░  ░ ░  ░   ░░   ░  ░   ▒    ░            ░   ░ ░░ ░ ░ ▒   ░ ░  ░    ░   ░  ░  ░  "
echo -e "░        ░  ░        ░    ░       ░          ░  ░                    ░    ░ ░     ░       ░  ░      ░  "
echo -e "                          ░                                                       ░                      "

echo "1. SYSTEM PREPARATION"
echo "1.1 Installing curl"
sudo apt-get install curl

echo "1.2 Updating packages"
sudo apt update -y
sudo apt upgrade -y

echo "1.3 Installing Docker"
sudo apt install docker.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "2. INSTALLING VALIDATOR"
curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh && chmod +x installer.sh && ./installer.sh
