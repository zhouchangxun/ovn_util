#!/bin/bash

for i in `seq 2`;do
  ip netns del vm$i
  ip link del ovs-vm$i
done

port_list=`ovs-vsctl show|grep Port |grep -v br-int|cut -f2 |awk '{print $2}'`
port_list=`echo $port_list |sed 's/\"//g'`
for i in $port_list ;do
  ovs-vsctl del-port br-int $i
done

ovn-nbctl ls-del ls1
ovn-nbctl ls-del ls2
ovn-nbctl lr-del lr1
