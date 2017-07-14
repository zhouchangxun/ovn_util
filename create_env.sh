#!/bin/bash


source lib-vm-port.sh
source lib-ovn-net.sh
source lib-ovn-lb.sh
source util.sh
#########################################
echo \
"====== ovn test env ready! =======
available cmd:
  1. vm_add vm_del
  2. switch_add switch_del switch_port_add switch_port_del
  3. router_add router_del router_interface_add router_interface_del
"
#lb_create lb1 192.168.0.66:80 "192.168.0.22:80,192.168.0.33:80" tcp
switch_add ls1
vm_add vm1 192.168.1.1/24 192.168.1.254
switch_port_add ls1 vm1

switch_add ls2
vm_add vm2 10.1.1.1/24 10.1.1.254
switch_port_add ls2 vm2

router_add lr1
router_interface_add lr1 ls1 192.168.1.254/24
router_interface_add lr1 ls2 10.1.1.254/24

# lb create
vip=192.168.1.66
chassis=86710d17-4051-4000-9afc-b20c058a7fca
router_add lb-router1
ovn-nbctl set logical_router lb-router1 options:chassis=$chassis
ovn-nbctl set logical_router lb-router1 options:lb_force_snat_ip=$vip

# lb vip create
router_interface_add lb-router1 ls1 192.168.1.66/24

lb_create lb1 192.168.1.66 192.168.1.22,192.168.1.33
ovn-nbctl lr-lb-add lb-router1 lb1

ovn-nbctl lr-route-add lb-router1 0.0.0.0/0 192.168.1.254
# lb member create
vm_add member1 192.168.1.22/24 192.168.1.254
switch_port_add ls1 member1

topo_show

