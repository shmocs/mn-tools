#!/bin/bash

what_to_sync="snowgemd snowgem-cli snowgem-tx"
mns="mn1"
#mns="mn1 mn2"


for mn in $mns; do
        mn_root="r$mn"
        mn_youmine="y$mn"

        ssh $mn_root "service snowgem stop"

        for _file in $what_to_sync; do
                scp ~/snowgem/src/$_file $mn_youmine:/home/youmine/snowgem-wallet/src/
        done

        ssh $mn_root "service snowgem start"
done
