#VARIABLES
#BOOTSTRAP - list of bootstrap nodes
#EXTERNAL_IP - public IP of node in format YOUR_PUBLIC_IP:8765
#MNEMONIC - mnemonic phrase for your wallet
#DISCORD - your Discord name


#Preparing system
sudo apt update && sudo apt upgrade -y
sudo apt install wget jq git curl build-essential libssl-dev gcc cmake mc -y

#Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

#Erase old node files
sudo systemctl stop ziesha
sudo systemctl disable ziesha
rm -rf $HOME/bazuka
rm -rf ~/.bazuka ~/.bazuka-wallet ~/.bazuka.yaml
sudo rm /etc/systemd/system/ziesha.service
sudo systemctl daemon-reload

#Node install from GitHub
git clone https://github.com/ziesha-network/bazuka
cd $HOME/bazuka
git pull origin master
cargo install --path .

#Declare variables
BOOTSTRAP=()
echo "Input list boostrap nodes (separate with spaces):"
read BOOTSTRAP
echo $BOOTSTRAP

echo "Input your server IP:"
read EXTERNAL_IP

echo "Input your mnemonic (if have):"
read MNEMONIC

echo "Input your Discord nickname:"
read DISCORD

#Node init
bazuka init --bootstrap $BOOTSTRAP --external $EXTERNAL_IP --mnemonic $MNEMONIC

#SystemD service create
sudo tee <<EOF >/dev/null /etc/systemd/system/ziesha.service
[Unit]
Description=Zeeka node
After=network.target

[Service]
User=$USER
ExecStart=`RUST_LOG=info which bazuka` node start --discord-handle "$DISCORD"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

#Adding service to autoload
sudo systemctl daemon-reload
sudo systemctl enable ziesha
sudo systemctl restart ziesha

#Output logs of service working
sudo journalctl -f -u ziesha
