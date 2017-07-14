#!/bin/bash

#args:(lb_name, vip, proto)
function lb_listener_add()
{
  name=$1
  vip=$2
  proto=$3

  chassis=86710d17-4051-4000-9afc-b20c058a7fca
  ovn-nbctl lr-add $name 
  ovn-nbctl set logical_router lb-router1 options:chassis=$chassis

  echo ovn-nbctl lb-add $name $vip $proto
  ovn-nbctl lb-add $name $vip $proto
  ovn-nbctl set logical_router $name options:lb_force_snat_ip=$vip

}
function lb_listener_del()
{
  name=$1
  vip=$2
  proto=$3
  echo ovn-nbctl lb-del $name $vip 
  ovn-nbctl lb-del $name $vip 
}
function lb_member_add()
{
  name=$1
  vip=$2
  members=$3
  old_members=`ovn-nbctl lb-list lb1 |grep -v UUID |cut -f5 |awk '{print $5}'`
  echo old_member: $old_member 
  new_members=$members,$old_members
  echo ovn-nbctl set  Load_Balancer $name vips=\'{\"$vip\"=\"$new_members\"}\'
  ovn-nbctl set Load_Balancer $name vips=\'{\"$vip\"=\"$new_members\"}\'
}
function lb_member_del()
{
  name=$1
  vip=$2
  proto=$3
  echo ovn-nbctl lb-del $name $vip 
  ovn-nbctl lb-del $name $vip 
}

#args:(router_name, lb_name)
function lb_del()
{
  name=$1
  ovn-nbctl lr-lb-del $name $name
  ovn-nbctl lb-del $name 
}

#lb_create lb1 192.168.0.66:80 "192.168.0.22:80,192.168.0.33:80" tcp
echo 'import lib-ovn-lb ...'
