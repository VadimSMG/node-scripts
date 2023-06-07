sudo systemctl stop ziesha
rm -rf ~/.bazuka
bazuka wallet reset
cd ~/bazuka
git pull
git reset --hard origin/master
cargo update
cargo install --path .
source "$HOME/.cargo/env"
sudo systemctl restart ziesha && sudo journalctl -f -u ziesha -o cat