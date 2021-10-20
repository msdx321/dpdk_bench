#!/bin/bash

# Delete exsiting
sudo ip addr delete 10.10.1.1/24 dev ens256

# Add IP
sudo ip addr add 10.10.1.1/24 dev ens256

# Add ARP
for i in {1..5}; do
    MAC=$(echo $i | awk '{printf("00:00:00:00:00:%02x",$1)}')
    ip=$(echo $(($i + 4)) | awk '{printf("10.10.1.%d", $1)}')
    sudo ip neigh add $ip lladdr $MAC dev ens256
done
