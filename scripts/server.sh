#!/bin/bash

sudo echo start

for i in {1..3}; do
    MAC=$(echo $i | awk '{printf("00:00:00:00:00:%02x",$1)}')
    ip=$(echo $(($i + 4)) | awk '{printf("10.10.1.%d", $1)}')
    vdev=$(echo $MAC $i | awk '{printf("net_virtio_user1,mac=%s,path=/var/run/openvswitch/vhost-user-%d", $1, $2)}')

    sudo ../dpdk-pingpong/build/pingpong --file-prefix=server-$i \
        --no-huge \
        --no-pci \
        --lcores '0@(0-5)' \
        --vdev $vdev \
        -- \
        -p 0 -s --server_mac=$MAC --server_ip=$ip &
done
