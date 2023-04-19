#VARIABLES
#BOOTSTRAP - list of bootstrap nodes
#EXTERNAL_IP - public IP of node in format YOUR_PUBLIC_IP:8765
#MNEMONIC - mnemonic phrase for your wallet
#DISCORD - your Discord name


#Preapare system
sudo apt install -y build-essential libssl-dev cmake

#Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

#Clone repo
git clone https://github.com/ziesha-network/bazuka

#Rust binares check
source "$HOME/.cargo/env"

#Compile and install node
cd bazuka
cargo install --path .

#Remove old config
rm -rf ~/.bazuka ~/.bazuka-wallet ~/.bazuka.yaml

#Node init
echo "Input list boostrap nodes:"
read BOOTSTRAP

echo "Input your server IP:"
read EXTERNAL-IP

echo "Input your mnemonic (if have):"
read MNEMONIC

bazuka init --bootstrap $BOOTSTRAP --external $EXTERNAL_IP --mnemonic $MNEMONIC

#Node run

echo "Input your Discord nickname:"
read DISCORD

bazuka node start --discord-handle $DISCOR