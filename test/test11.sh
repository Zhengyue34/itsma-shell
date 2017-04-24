#!/bin/bash
LIMIT=`grep "user2" /etc/shadow | cut -d: -f6`
TIME=`date +%s`
DAY=$[$TIME/86400]
LONGEST=`grep "user2" /etc/shadow | cut -d: -f5`
MODIFY=`grep "user2" /etc/shadow | cut -d: -f3`
REMINDTIME=$[$LONGEST-$[$TIME-$MODIFY]]

if [ $REMINDTIME -lt $LIMIT ];then
  echo "Wrong"
else
  echo "OK"
fi

