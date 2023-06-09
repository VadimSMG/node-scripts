#Update system
cd ~
apt -q update
apt -qy install curl git jq lz4 build-essential
apt -qy upgrade

#Install GO v1.20.4
rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.20.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

#Install Nolus node
echo "Actual node version:"
read NODEVERS
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
git checkout $$NODEVERS

make install
make build

#First node init
echo "Input node name:"
read NODENAME
nolusd init $NODENAME

#Preparation for Cosmovisor
cd $HOME/nolus-core
mkdir -p $HOME/.nolus/cosmovisor/genesis/bin
mv target/release/nolusd $HOME/.nolus/cosmovisor/genesis/bin/
rm -rf build

rm -rf  /usr/local/bin/nolusd
cd $HOME/nolus-core
ln -s $HOME/.nolus/cosmovisor/genesis $HOME/.nolus/cosmovisor/current
sudo ln -s $HOME/.nolus/cosmovisor/current/bin/nolusd /usr/local/bin/nolusd

#Cosmovisor install (last version)
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

#NolusD service creating
sudo tee /etc/systemd/system/nolusd.service > /dev/null << EOF
[Unit]
Description=nolus-testnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.nolus"
Environment="DAEMON_NAME=nolusd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.nolus/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

#Enable service
sudo systemctl daemon-reload
sudo systemctl enable nolusd

#Final node init
nolusd config chain-id nolus-rila
nolusd config keyring-backend test
nolusd config node tcp://localhost:43657
rm -rf /root/.nolus/config/genesis.json
nolusd init $NODENAME --chain-id nolus-rila

#Download "genesis" and "addrbook"
curl -Ls https://snapshots.kjnodes.com/nolus-testnet/genesis.json > $HOME/.nolus/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/nolus-testnet/addrbook.json > $HOME/.nolus/config/addrbook.json

#Adding seeds
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@nolus-testnet.rpc.kjnodes.com:43659\"|" $HOME/.nolus/config/config.toml

#Set min gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025unls\"|" $HOME/.nolus/config/app.toml

#Configure pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "nothing"|' \
  $HOME/.nolus/config/app.

#Adding additional ports
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:43658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:43657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:43060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:43656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":43660\"%" $HOME/.nolus/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:43317\"%; s%^address = \":8080\"%address = \":43080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:43090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:43091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:43545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:43546\"%" $HOME/.nolus/config/app.toml

#Snapshot download
curl -L https://snapshots.kjnodes.com/nolus-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nolus
[[ -f $HOME/.nolus/data/upgrade-info.json ]] && cp $HOME/.nolus/data/upgrade-info.json $HOME/.nolus/cosmovisor/genesis/upgrade-info.json

#Start the NolusD service
systemctl start nolusd
systemctl daemon-reload
systemctl enable nolusd
systemctl restart nolusd

#Wallet import
nolusd keys add wallet --recover

#NolusD logs
journalctl -u nolusd -f --no-hostname -o cat