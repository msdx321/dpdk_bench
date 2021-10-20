#!/bin/bash

# DPDK
echo 1 | sudo tee /sys/module/vfio/parameters/enable_unsafe_noiommu_mode
sudo dpdk-devbind.py -b vfio-pci 0b:00.0

# OVS
sudo ovs-vsctl del-br ovs-br0
sudo ovs-vsctl set Open_vSwitch . "other_config:dpdk-init=true"
sudo ovs-vsctl set Open_vSwitch . "other_config:dpdk-socket-mem=128"
sudo ovs-vsctl set Open_vSwitch . "other_config:dpdk-extra=\"--file-prefix=ovs\""
sudo service openvswitch-switch restart

sudo ovs-vsctl add-br ovs-br0 -- set bridge ovs-br0 datapath_type=netdev
sudo ovs-vsctl add-port ovs-br0 dpdk-p0 -- set Interface dpdk-p0 type=dpdk "options:dpdk-devargs=0b:00.0"

for i in {1..5}; do
    sudo ovs-vsctl add-port ovs-br0 vhost-user-$i -- set Interface vhost-user-$i type=dpdkvhostuser
done
