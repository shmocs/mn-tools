#!/bin/bash

CLI_PATH="/home/your_user/snowgem-wallet"

#entire address (s1dcz8GTPra4uTHu9a7ezzRL4RNTzYLmZE2) or only some terminal part of it, case INSENSITIVE (ex: ze2)
XSG_ADDR_HINT="mze2"

echo -e "\n======== Status ============"
${CLI_PATH}/src/snowgem-cli masternodedebug
{ echo "versions:"; ${CLI_PATH}/src/snowgem-cli getinfo |grep version |grep -Eo '[0-9]+'; } | paste -d" " -s

echo -e "\n======== Wallet synced ? Block info ============"
{ echo "cli block:"; ${CLI_PATH}/src/snowgem-cli getinfo |grep block |grep -Eo '[0-9]+'; } | paste -d" " -s
{ echo "api block:"; curl -s https://explorer.snowgem.org/api/getblockcount; } | paste -d" " -s


echo -e "\n======== Masternodes info ============"
${CLI_PATH}/src/snowgem-cli masternode list > /tmp/masternodes.json

PAYMENT_FREQ=$(cat /tmp/masternodes.json |grep 17000[68] |wc -l)

{ echo "ENABLED:"; cat /tmp/masternodes.json |grep -i enabled |wc -l; } | paste -d" " -s
{ echo "170004:"; cat /tmp/masternodes.json |grep 170004 |wc -l; } | paste -d" " -s
{ echo "170005:"; cat /tmp/masternodes.json |grep 170005 |wc -l; } | paste -d" " -s
{ echo "170006:"; cat /tmp/masternodes.json |grep 170006 |wc -l; } | paste -d" " -s
{ echo "170008:"; cat /tmp/masternodes.json |grep 170008 |wc -l; } | paste -d" " -s
{ echo "Expired:"; cat /tmp/masternodes.json |grep -i expired |wc -l; } | paste -d" " -s
echo "So ~every $PAYMENT_FREQ blocks/minutes you should be the one. "

echo -e "\n======= Am I lucky now ? =========="
output=$(${CLI_PATH}/src/snowgem-cli getmasternodewinners | awk 'BEGIN {IGNORECASE = 1} /nHeight/ {block=$0} /'${XSG_ADDR_HINT}'/ {print block}' |grep -Eo '[0-9]+')
PAYMENT_ON_BLOCK=$?

if [ $PAYMENT_ON_BLOCK -eq 0 ]; then
        echo "YES. Payment set for your masternode on block: ${output}"
else
        echo "Not yet..."
fi

echo ""
