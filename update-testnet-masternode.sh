#!/bin/bash

testnet_binaries_path=~/testnet
testnet_wallet_path=~/testnet/.snowgem
confFile=$testnet_wallet_path/snowgem.conf
cli="$testnet_binaries_path/snowgem-cli --datadir=$testnet_wallet_path"

echo "Cli: $cli"

mkdir -p $testnet_wallet_path

# Asgard common script
mncommon="/root/oneclick/mn-common.sh"

# Include Asgard common script
source $mncommon

# stop & remove old service
service snowgem_testnet stop
systemctl disable --now snowgem_testnet.service


# clean old conf
rm $confFile

# generate conf
rpcuser=$(gpw 1 30)
echo "rpcuser="$rpcuser >> $confFile
rpcpassword=$(gpw 1 30)
echo "rpcpassword="$rpcpassword >> $confFile

mn_ip=$(curl https://icanhazip.com)
mn_key=$(curl https://asgard.snowgem.org/php/public-api?action=getTestnetMnKey)

report_asgard_testnet_mnkey $mn_key

echo "addnode=68.183.162.58" >> $confFile
echo "addnode=206.189.160.115" >> $confFile
echo "addnode=testnet.explorer.snowgem.org" >> $confFile
echo "addnode=test.pool.snowgem.org" >> $confFile

echo "testnet=1" >> $confFile
echo "rpcport=26112" >> $confFile
echo "port=26113" >> $confFile
echo "listen=1" >> $confFile
echo "server=1" >> $confFile
echo "txindex=1" >> $confFile
echo "masternodeaddr="$mn_ip:26113"" >> $confFile
echo "externalip="$mn_ip:26113"" >> $confFile
echo "masternodeprivkey="$mn_key"" >> $confFile
echo "masternode=1" >> $confFile

cd $testnet_binaries_path

wget -N https://github.com/shmocs/mn-tools/releases/download/3000456-20190708/snowgem-ubuntu18.04-3000456-20190708.zip -O ~/binary.zip
unzip -o ~/binary.zip -d $testnet_binaries_path


chmod +x $testnet_binaries_path/snowgemd $testnet_binaries_path/snowgem-cli

service="echo '[Unit]
Description=Snowgem Testnet daemon
After=network-online.target
[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=$testnet_binaries_path/snowgemd --datadir=$testnet_wallet_path
WorkingDirectory=$testnet_wallet_path
User=root
KillMode=mixed
Restart=always
RestartSec=10
TimeoutStopSec=10
Nice=-20
ProtectSystem=full
[Install]
WantedBy=multi-user.target' > /lib/systemd/system/snowgem_testnet.service"

sh -c "$service"

systemctl enable --now snowgem_testnet.service
service snowgem_testnet start

x=1
echo "Wait for starting"
sleep 10
while true ; do
    echo "Wallet is opening, please wait. This step will take few minutes ($x)"
    sleep 1
    x=$(( $x + 1 ))
    $cli getinfo &> text.txt
    line=$(tail -n 1 text.txt)
    if [[ $line == *"..."* ]]; then
        echo $line
    fi
    if [[ $(tail -n 1 text.txt) == *"sure server is running"* ]]; then
        echo "Cannot start wallet, please contact us on Discord(https://discord.gg/7a7XRZr) for help"
        break
    elif [[ $(head -n 20 text.txt) == *"version"*  ]]; then
        echo "Checking masternode status"
        while true ; do
            echo "Please wait ($x)"
            sleep 1
            x=$(( $x + 1 ))
            $cli masternodedebug &> text.txt
            line=$(head -n 1 text.txt)
            echo $line
            if [[ $line == *"not yet activated"* ]]; then
                $cli masternodedebug
                break
            fi
        done
        $cli getinfo
        $cli masternodedebug
        break

    fi
done
