echo "1. SYSTEM UPDATE"
sudo apt update && sudo apt upgrade -y

echo "2. SOFTWARE INSTALL"
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential 
git make ncdu -y

echo "3. GOLANG INSTALL"
ver="1.19.1" 
cd $HOME 
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 
rm "go$ver.linux-amd64.tar.gz"

echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "4. NODE INSTALL"
cd $HOME 
rm -rf celestia-node 
git clone https://github.com/celestiaorg/celestia-node.git 
cd celestia-node/ 
git checkout tags/v0.6.4 
make build 
make install

echo "5. CEL-KEY MAKING"
make cel-key
echo "Input node name:"
read NODENAME
./cel-key add $NODENAME --keyring-backend test --node.type light --p2p.network mocha-3

echo "6. LIGHT NODE INIT"
celestia light init

echo "7. MAKING NODE SERVICE"
echo "Input RPC ip-address:"
read RPCIP
sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
[Unit]
Description=celestia-lightd Light Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/go/bin/celestia light start --core.ip $RPCIP --keyring.accname $NODENAME --p2p.network mocha
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