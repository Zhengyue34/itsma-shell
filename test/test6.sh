#!/bin/bash
grep "bash$" /etc/passwd  &> /dev/null
RETVAL=$?
if [ $RETVAL -eq 0 ];then
  grep "bash$" /etc/passwd | wc -l
else
  echo "no one use bash"
fi 
