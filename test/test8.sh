#!/bin/bash
grep "^$" txt.txt &> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ];then
  number=`grep "^$" txt.txt | wc -l`
  echo "$number exit!"
else
  echo "nothing"
fi
