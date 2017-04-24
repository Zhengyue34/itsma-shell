#!/bin/bash
if [ $# -ne 2 ];then
 echo "we need two parameters"
 echo "Usage: ./test14.sh ARG1 ARG2"
 exit 8
fi

NUM1=$1
NUM2=$2

SUM=$[$NUM1+$NUM2]
PRO=$[$NUM1*$NUM2]

echo $SUM $PRO
