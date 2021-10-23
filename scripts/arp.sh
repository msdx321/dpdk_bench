#!/bin/bash

# Add IP
for i in {1..128}; do
    sudo ip addr replace 10.10.$i.2/24 dev enp59s0f0
done

# Add ARP
for i in {1..1024}; do
    j=$(($i / 128))
    k=$(($i % 128))
    MAC=$(echo $(($j + 1)) $(($k + 1))| awk '{printf("00:00:00:00:%02x:%02x", $1, $2)}')
    IP=$(echo $(($j + 1)) $(($k + 5)) | awk '{printf("10.10.%d.%d", $1, $2)}')
    sudo ip neigh replace $IP lladdr $MAC dev enp59s0f0
done
