#!/bin/bash

for i in 1; do
    MAC=$(echo $i | awk '{printf("00:00:00:00:00:%02x",$1)}')
    ip=$(echo $(($i + 4)) | awk '{printf("10.10.1.%d", $1)}')

    sudo ../dpdk-pingpong/build/pingpong --file-prefix=server \
        --no-huge \
        --no-pci \
        --lcores '0@(0-5)' \
        --vdev 'net_virtio_user1,mac=$(MAC),path=/var/run/openvswitch/vhost-user-1' \
        -- \
        -p 0 -s --server_mac=$MAC --server_ip=$ip &
done
