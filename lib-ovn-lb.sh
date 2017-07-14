#!/bin/bash

#args:(lb_name, vip, [member...], proto)
function lb_create()
{
  echo "ovn-nbctl lb-add $1 $2 $3 $4"
  ovn-nbctl lb-add $1 $2 $3 $4
}

#args:(router_name, lb_name)
function lb_attach()
{
  echo "ovn-nbctl lr-lb-add $1 $2"
  ovn-nbctl lr-lb-add $1 $2
}

#lb_create lb1 192.168.0.66:80 "192.168.0.22:80,192.168.0.33:80" tcp
echo 'import lib-ovn-lb ...'
