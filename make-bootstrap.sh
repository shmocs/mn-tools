#!/bin/bash
source /root/mn-tools/snowgem.cfg

block=$($cli getblockcount)
echo "Block: $block"
zipfile="snowgem-indexed-chain-$block.zip"
echo "Zip file: $zipfile"

cd $datadir
rm -f snowgem-indexed-chain*
zip -r $zipfile blocks chainstate
#zip -r $zipfile sporks database
ssh $webhost "cd $webroot && rm -f *.zip && rm -f snowgem-indexed*"
scp $zipfile $webhost:$webroot
ssh $webhost "cd $webroot && ln -s $zipfile blockchain_index.zip"
rm -f $zipfile
