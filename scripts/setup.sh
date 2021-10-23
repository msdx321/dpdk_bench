#!/bin/bash

# Ulimit
ulimit -n 1048576

# DPDK
sudo modprobe vfio_pci
echo 1 | sudo tee /sys/module/vfio/parameters/enable_unsafe_noiommu_mode
sudo ip link set enp59s0f0 down
sudo dpdk-devbind.py -b vfio-pci 3b:00.0

# Kill exisiting server
sudo pkill -9 pingpong
sudo rm -rf /tmp/vhost-*

# OVS
echo 2048 | sudo tee /proc/sys/vm/nr_hugepages
sudo ovs-ctl restart
sudo ovs-vsctl del-br ovs-br0
sudo ovs-vsctl set Open_vSwitch . "other_config:dpdk-init=true"
sudo ovs-vsctl set Open_vSwitch . "other_config:dpdk-lcore-mask=0xF"
sudo ovs-vsctl set Open_vSwitch . "other_config:pmd-cpu-mask=0xF"
sudo ovs-vsctl set Open_vSwitch . "other_config:dpdk-alloc-mem=4096"
sudo ovs-vsctl set Open_vSwitch . "other_config:dpdk-extra=\"--file-prefix=ovs\""
sudo service openvswitch-switch restart
sudo ovs-ctl restart

sudo ovs-vsctl add-br ovs-br0 -- set bridge ovs-br0 datapath_type=netdev
sudo ovs-vsctl add-port ovs-br0 dpdk-p0 -- set Interface dpdk-p0 type=dpdk options:dpdk-devargs=0000:3b:00.0 ofport_request=10000 options:n_rxq=8

for i in {1..1024}; do
    sudo ovs-vsctl --no-wait add-port ovs-br0 vhost-user-$i -- set Interface vhost-user-$i type=dpdkvhostuserclient ofport_request=$i options:vhost-server-path=/tmp/vhost-user-client-$i
done

sudo ovs-ofctl del-flows ovs-br0

for i in {1..1024}; do
    j=$(($i / 128))
    k=$(($i % 128))
    MAC=$(echo $(($j + 1)) $(($k + 1)) | awk '{printf("00:00:00:00:%02x:%02x", $1, $2)}')
    sudo ovs-ofctl add-flow ovs-br0 in_port=10000,dl_dst=$MAC,actions=$i
    sudo ovs-ofctl add-flow ovs-br0 in_port=$i,actions=10000
done
