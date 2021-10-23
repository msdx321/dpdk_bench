#!/bin/bash

sudo echo start > server.log
sudo pkill -9 pingpong
sudo rm -rf /tmp/vhost-*

sleep 5

for i in {1..1024}; do
    j=$(($i / 128))
    k=$(($i % 128))
    MAC=$(echo $(($j + 1)) $(($k + 1))| awk '{printf("00:00:00:00:%02x:%02x", $1, $2)}')
    IP=$(echo $(($j + 1)) $(($k + 5)) | awk '{printf("10.10.%d.%d", $1, $2)}')
    vdev=$(echo $MAC $i | awk '{printf("net_virtio_user1,mac=%s,server=1,path=/tmp/vhost-user-client-%d", $1, $2)}')

    #echo $i $j $k $IP
    sudo ../dpdk-pingpong/build/pingpong --file-prefix=server-$i \
        --no-huge \
        --no-pci \
	--lcores '0@(8-47)' \
        --vdev $vdev \
        -- \
        -p 0 -s -i --server_mac=$MAC --server_ip=$IP &>> server.log &
done
