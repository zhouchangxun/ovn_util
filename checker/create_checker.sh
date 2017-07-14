#!/bin/bash

declare run_dir=`pwd`
declare namespace=

function print_help()
{
  echo "
  functoin -- create checker instance.
  usage:
  	-d define run dir(defult:run_rent dir)
  	-n define run namespace()
  	-h print this help
  "
}

while getopts "d:n:h" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
         d)
            run_dir=$OPTARG
            ;;
         n)
            namespace=$OPTARG
            ;;
         h)
            print_help;exit 0
            ;;
         ?) 
            print_help;exit 0
            ;;
    esac
done

if [ "v$namespace" = "v" ] ; then
 print_help 
 exit 1 
fi

echo running checkers under namespace: $namespace
echo running checkers under dir: $run_dir

ip netns exec $namespace keepalived -f $run_dir/lb-keepalived-checker.conf -p $run_dir/keepalived.pid -C -c $run_dir/checkers.pid

