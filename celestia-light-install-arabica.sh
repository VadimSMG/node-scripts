echo "1. SYSTEM UPDATE"
sudo apt update && sudo apt upgrade -y

echo "2. SOFTWARE INSTALL"
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential 
git make ncdu -y

echo "3. GOLANG INSTALL"
ver="1.21.0"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"

echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "4. NODE INSTALL"
echo "Input actual Node Version (v0.11.0-rc??):"
read NODEVER
cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/$NODEVER
make build
make install

echo "5. CEL-KEY MAKING"
make cel-key
echo "Input node name:"
read NODENAME
echo "Input chain-id (arabica-??):"
read CHAINID
./cel-key add $NODENAME --keyring-backend test --node.type light --p2p.network $CHAINID --recover

echo "6. LIGHT NODE INIT"
celestia light init --p2p.network arabica

echo "7. MAKING NODE SERVICE"
#echo "Input RPC ip-address:"
#read RPCIP
sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
[Unit]
Description=celestia-lightd Light Node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/local/bin/celestia light start --core.ip consensus-full-$CHAINID.celestia-arabica.com --keyring.accname $NODENAME --p2p.network $CHAINID
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

echo "8. START NODE SERVICE"
sudo systemctl enable celestia-lightd
sudo systemctl start celestia-lightd
sudo systemctl status celestia-lightd
#journalctl -u celestia-lightd.service -f
