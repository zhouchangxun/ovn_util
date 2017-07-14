#!/usr/bin/env bash

# DEL_NAMESPACES(ns [, ns ... ])
#
# Delete namespaces from the running OS

function del_ns ()
{
  local name=$1;
  ip netns del $name
}

# ADD_NAMESPACES(ns [, ns ... ])
#
# Add new namespaces, if ns exists, the old one
# will be remove before new ones are installed.
function add_ns ()
{
  local name=$1;
  ip netns add $name || return 77
  #ip netns exec $name sysctl -w net.netfilter.nf_conntrack_helper=0
}

# NS_EXEC([namespace], [command])
#
# Execute 'command' in 'namespace'
function ns_exec ()
{
ip netns exec $1 sh << NS_EXEC_HEREDOC
$2
NS_EXEC_HEREDOC
}

# ADD_VETH([port], [namespace], [ovs-br], [ip_addr] [mac_addr [gateway]])
#
# Add a pair of veth ports. 'port' will be added to name space 'namespace',
# and "ovs-'port'" will be added to ovs bridge 'ovs-br'.
#
# The 'port' in 'namespace' will be brought up with static IP address
# with 'ip_addr' in CIDR notation.
#
# Optionally, one can specify the 'mac_addr' for 'port' and the default
# 'gateway'.
#
# The existing 'port' or 'ovs-port' will be removed before new ones are added.
#
function add_veth ()
{
namespace=$1
vm=$1
ip_addr=$2
mac_addr=$3
gateway=$4
      ip link add veth-$vm type veth peer name ovs-$vm || return 77
      #CONFIGURE_VETH_OFFLOADS([$1])
      ip link set veth-$vm netns $vm
      ip link set dev ovs-$vm up
      ovs-vsctl add-port br-int ovs-$vm 
      ns_exec $vm "ip addr add $ip_addr dev veth-$vm"
      ns_exec $vm "ip link set dev veth-$vm up"

      if test -n "$mac_addr"; then
        ns_exec $vm "ip link set dev veth-$vm address $mac_addr"
      fi

      if test -n "$gateway"; then
        ns_exec $vm "ip route add default via $gateway"
      fi
}

function vm_add()
{
  if [ "v" == "v$1" ]; then
    echo "help: vm_add [vm_name] [ip/mask] [gateway] "
    exit 1
  fi
  vm_name=$1
  ip=$2  #format as x.x.x.x/length
  mac=$3
  gw=$4
  switch=$5 #logical_switch_port

  add_ns $vm_name 
  echo add_veth $vm_name $ip $mac $gw
  add_veth $vm_name $ip $mac $gw 
  
  #add_ns vm2 
  #add_veth tap2 vm2 br-int 192.168.0.22/24 50:54:00:00:00:02 192.168.0.1 sw0-port2

  #add_ns vm3 
  #add_veth tap3 vm3 br-int 192.168.0.33/24 50:54:00:00:00:03 192.168.0.1 sw0-port3

  #add_ns vm4
  #add_veth tap4 vm4 br-int 11.0.0.2/24 50:54:00:00:11:02 11.0.0.1 sw1-port1
}

function vm_del()
{
  vm_name=$1
  echo ip link del ovs-$vm_name
  ip link del ovs-$vm_name
  echo ovs-vsctl del-port br-int ovs-$vm_name 
  ovs-vsctl del-port br-int ovs-$vm_name 
  echo del_ns $vm_name
  del_ns $vm_name
}
echo 'import lib-vm-port...'
echo "help: vm_add [vm_name] [ip/mask] [gateway] "
#test
