#!/bin/bash

echo "--Setup dependencies--"
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

echo "--Installing Golang--"
ver="1.20.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"

echo "--Export PATH variable--"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "--Install celestia-app--"
rm -rf /root/.celestia-app/config/genesis.json
cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app/
APP_VERSION=v1.0.0-rc9
git checkout tags/$APP_VERSION -b $APP_VERSION
make install

echo "--Setup P2P networks--"
cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git

echo "--Input node name:--"
read NODENAME

echo "--Node initing--"
celestia-appd init "$NODENAME" --chain-id mocha-3
cp $HOME/networks/mocha/genesis.json $HOME/.celestia-app/config
PERSISTENT_PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mocha/peers.txt | tr -d '\n')
echo $PERSISTENT_PEERS
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PERSISTENT_PEERS\"/" $HOME/.celestia-app/config/config.toml

echo "--Configurating pruning--"
PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="10"

sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$PRUNING_KEEP_RECENT\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$PRUNING_INTERVAL\"/" $HOME/.celestia-app/config/app.toml

echo "--Network reset--"
celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app

echo "--Quick node syncing--"
cd $HOME
rm -rf ~/.celestia-app/data
mkdir -p ~/.celestia-app/data
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | \
    egrep -o ">mocha-3.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - \
    -C ~/.celestia-app/data/

echo "--RPC endpoint configuration--"
EXTERNAL_ADDRESS=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address = \"\"/external_address = \"$EXTERNAL_ADDRESS:26656\"/" $HOME/.celestia-app/config/config.toml
sed -i 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:26657"#g' ~/.celestia-app/config/config.toml

#echo "--Starting celestia app--"
#celestia-appd start

echo "--Creating celestia app service--"
sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-appd-full.service
[Unit]
Description=celestia-full Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/celestia-appd start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

echo "--Starting celestia app service--"
sudo systemctl enable celestia-appd-full
sudo systemctl start celestia-appd-full && sudo journalctl -u \
celestia-appd-full.service -f
