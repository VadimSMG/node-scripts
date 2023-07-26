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

echo "4. CEL-KEY MAKING"
make cel-key
echo "Input node name:"
read NODENAME
./cel-key add $NODENAME --keyring-backend test --node.type full --p2p.network mocha-3 --recover

echo "5. NODE INITIALISE"
celestia full init

echo "6. SERVICE CREATING"
echo "Input RPC IP"
read RPCIP
sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-fulld.service
[Unit]
Description=celestia-fulld Full Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/celestia full start --core.ip $RPCIP --keyring.accname $NODENAME --p2p.network mocha-3
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

echo "7. SERVICE START"
sudo systemctl enable celestia-fulld
sudo systemctl start celestia-fulld

#sudo journalctl -u celestia-fulld.service -f
