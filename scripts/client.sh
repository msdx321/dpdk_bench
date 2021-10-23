#!/bin/bash

# Ulimit
ulimit -n 1048576

sudo echo start > client.log

../linux_client/out/client -n 5 -rl 500 -rh 20 -d 3 -h 1 -m 0 -s 3 &>> client.log