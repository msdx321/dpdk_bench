#!/bin/bash

sudo pkill -9 pingpong
sudo ovs-ctl stop
sudo dpdk-devbind.py -b i40e 3b:00.0
sudo bash /home/wenyuan/arp.sh