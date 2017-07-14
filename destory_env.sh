#!/bin/bash

for i in `seq 4`;do
  ip netns del vm$i
  ip link del ovs-tap$i
done
