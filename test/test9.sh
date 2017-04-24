#!/bin/bash
NAME=user1
uuid=`id -u $NAME`
ugid=`id -u $NAME`
if [ $uuid -eq $ugid ];then
  echo "good guy"
else
  echo "bad guy"
fi
