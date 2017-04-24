#!/bin/bash
NAME=user1
uuid=`grep "user1" /etc/passwd | cut -d: -f3`
ugid=`grep "user1" /etc/passwd | cut -d: -f4`
if [ $uuid -eq $ugid ];then
  echo "good gay"
else
  echo "bad gay"
fi
