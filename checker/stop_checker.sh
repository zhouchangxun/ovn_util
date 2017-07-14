#!/usr/bin/env bash

pid=`cat keepalived.pid`
echo $pid
kill -15 $pid
