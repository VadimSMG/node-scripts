#Stopping Nolus node service
systemctl stop nolusd

#Input actual Nolus version
echo "Input actual Nolus version (example v0.1.43):"
read NOLUSVER

#Installing actual Nolus
cd $HOME
rm -rf nolus-core
git clone https://github.com/Nolus-Protocol/nolus-core.git
cd nolus-core
git checkout $NOLUSVER
make build
sudo mv ./target/release/nolusd /usr/local/bin/ || exit
rm -rf build
cd ..
sed -i -e "s/^pruning =./pruning = "nothing"/" $HOME/.nolus/config/app.toml

#Starting Nolus node service
echo "Nolus node service will start now!"
systemctl start nolusd