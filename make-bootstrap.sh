#!/bin/bash
source /root/mn-tools/snowgem.cfg

block=$($cli getinfo |grep block |grep -Eo '[0-9]+')

cd $datadir
rm -f snowgem-indexed-chain*
zip -r snowgem-indexed-chain-$block.zip blocks chainstate
ssh $webhost "cd $webroot && rm -f *.zip"
scp snowgem-indexed-chain-$block.zip $webhost:$webroot
ssh $webhost "cd $webroot && ln -s snowgem-indexed-chain-$block.zip indexed-chain.zip"
