#!/bin/bash

declare random_mac
function topo_create()
{
  # Create the first logical switch with 3 port
  ovn-nbctl ls-add sw0
  
  # Create the second logical switch with 1 port
  ovn-nbctl ls-add sw1

  # Create a logical router and attach both logical switches
  ovn-nbctl lr-add lr0

  # Create 3 port on sw0
  ovn-nbctl lsp-add sw0 sw0-port1
  ovn-nbctl lsp-set-addresses sw0-port1 "50:54:00:00:00:01 192.168.0.2"
  
  ovn-nbctl lsp-add sw0 sw0-port2
  ovn-nbctl lsp-set-addresses sw0-port2 "50:54:00:00:00:02 192.168.0.22"
  
  ovn-nbctl lsp-add sw0 sw0-port3
  ovn-nbctl lsp-set-addresses sw0-port3 "50:54:00:00:00:03 192.168.0.33"
  

  # Create 1 port on sw1
  ovn-nbctl lsp-add sw1 sw1-port1
  ovn-nbctl lsp-set-addresses sw1-port1 "50:54:00:00:01:01 11.0.0.2"
  
   
  # Create gateway for sw0 on lr0
  ovn-nbctl lrp-add lr0 lrp0 00:00:00:00:ff:01 192.168.0.1/24
  ovn-nbctl lsp-add sw0 lrp0-attachment
  ovn-nbctl lsp-set-type lrp0-attachment router
  ovn-nbctl lsp-set-addresses lrp0-attachment 00:00:00:00:ff:01
  ovn-nbctl lsp-set-options lrp0-attachment router-port=lrp0
  
  # Create gateway for sw1 on lr0
  ovn-nbctl lrp-add lr0 lrp1 00:00:00:00:ff:02 11.0.0.1/24
  ovn-nbctl lsp-add sw1 lrp1-attachment
  ovn-nbctl lsp-set-type lrp1-attachment router
  ovn-nbctl lsp-set-addresses lrp1-attachment 00:00:00:00:ff:02
  ovn-nbctl lsp-set-options lrp1-attachment router-port=lrp1

}

# View a summary of the configuration
function topo_show(){
  ovn-nbctl show
}

function switch_add()
{
ovn-nbctl ls-add $1
}
function switch_del()
{
ovn-nbctl ls-del $1
}
function switch_port_add()
{
  sw=$1
  vm=$2
  lsp="lsp_$sw-$vm"
  mac=
  ip=
  ovn-nbctl lsp-add $sw $lsp
  ovn-nbctl lsp-set-addresses $lsp "$mac $ip"
  ovs-vsctl set interface ovs-$vm external-ids:iface-id="$lsp"

  echo bind $vm with logical switch port $lsp
}
function switch_port_del()
{
  sw=$1
  vm=$2
  lsp="lsp_$sw-$vm"
  echo ovs-nbctl lsp-del $lsp
  ovn-nbctl lsp-del $lsp
}
function router_add()
{
  ovn-nbctl lr-add $1
}
function router_del()
{
  ovn-nbctl lr-del $1
}
function alloc_mac(){
  MACADDR="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')";
  random_mac=$MACADDR
}
function router_interface_add()
{
  # Create gateway for sw0 on lr0
  router=$1
  switch=$2
  ip=$3 # x.x.x.x/length
  lrp="lrp-$router-to-$switch"
  lsp="$lrp-attach"
  alloc_mac;
  ovn-nbctl lrp-add $router $lrp $random_mac $ip
  ovn-nbctl lsp-add $sw $lsp
  ovn-nbctl lsp-set-type $lsp router
  ovn-nbctl lsp-set-addresses $lsp0 $mac
  ovn-nbctl lsp-set-options $lsp router-port=$lrp
}


echo 'import lib-ovn-net...'
############main ############
#topo_create
#topo_show
############main ############
# Create ports on the local OVS bridge, br-int.  When ovn-controller
# sees these ports show up with an "iface-id" that matches the OVN
# logical port names, it associates these local ports with the OVN
# logical ports.  ovn-controller will then set up the flows necessary
# for these ports to be able to communicate each other as defined by
# the OVN logical topology.
#ovs-vsctl add-port br-int sw0-port1 -- set Interface sw0-port1 external_ids:iface-id=sw0-port1
#ovs-vsctl add-port br-int sw1-port1 -- set Interface sw1-port1 external_ids:iface-id=sw1-port1
