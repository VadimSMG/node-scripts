#!/bin/bash

echo "1. UPDATING SYSTEM"
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

echo "2. INSTALLING GOLANG"
ver="1.20.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"

echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "3. NODE INSTALL"
cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/v0.11.0-rc8
make build
make install



#Node init
celestia light init

#Wallet import
echo "Wallet name: $WALLET_NAME"

./cel-key add $WALLET_NAME --keyring-backend test --node.type light --recover

#SystemD service creating and starting
sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
[Unit]
Description=celestia-lightd Light Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia) light start --core.ip $IP --keyring.accname $WALLET_NAME
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-lightd
sudo systemctl start celestia-lightd

#Service logs
sudo journalctl -u celestia-lightd.service -f
