#!/bin/bash


source lib-vm-port.sh
source lib-ovn-net.sh
source lib-ovn-lb.sh

#########################################
echo \
"====== ovn test env ready! =======
available cmd:
  1. vm_add vm_del
  2. switch_add switch_del switch_port_add
  3. router_add router_del router_interface_add
"
#lb_create lb1 192.168.0.66:80 "192.168.0.22:80,192.168.0.33:80" tcp


