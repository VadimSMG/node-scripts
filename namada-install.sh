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

