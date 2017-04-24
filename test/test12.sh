#!/bin/bash
FILE=/etc/rc.d

if [ ! -e $FILE ];then
  echo "No such file!"
  exit 1
fi

if [ -f $FILE ]; then
 echo "Common file"
elif [ -d $FILE ]; then
 echo "Directory!"
else
  echo "Unknown"
fi
