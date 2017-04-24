#!/bin/bash
NAME=user1
USERID=`id -u $NAME`
if [ $USERID -eq 0 ];then
  echo "Admin"
else
  echo "Common user"
fi
