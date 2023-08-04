echo "1. SYSTEM PREPARATION"
sudo apt update -y
sudo apt upgrade -y

echo "1.1 Installing RUST"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update

echo "1.2 Installing Golang, Git, Clang, OpenSSL, LLVM"
sudo apt install -y golang-go git clang openssl llvm

echo "1.3 Installing dependencies"
sudo apt install -y make git-core libssl-dev pkg-config libclang-12-dev build-essential protobuf-compiler

echo "2. INSTALLING NAMADA"
git clone https://github.com/anoma/namada.git
cd namada 
make install

echo "3. INSTALLING COMETBFT"
echo export GOPATH=\"\$HOME/go\" >> ~/.bash_profile
echo export PATH=\"\$PATH:\$GOPATH/bin\" >> ~/.bash_profile
git clone https://github.com/cometbft/cometbft.git
cd cometbft
make install
make build

echo "4. DOWNLOADING BINARIES"
OPERATING_SYSTEM="Linux" # or "Darwin" for MacOS
latest_release_url=$(curl -s "https://api.github.com/repos/anoma/namada/releases/latest" | grep "browser_download_url" | cut -d '"' -f 4 | grep "$OPERATING_SYSTEM")
wget "$latest_release_url"

echo "5. FULL NODE SETUP"

echo "5.1 Joining the network. Input actual chain-id:"
read CHAIN_ID
namada client utils join-network --chain-id $CHAIN_ID

echo "5.2 Start node and sync"
CMT_LOG_LEVEL=p2p:none,pex:error namada node ledger run
