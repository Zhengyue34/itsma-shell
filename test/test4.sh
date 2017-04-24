#!/bin/bash
NAME=user41
if id $NAME &> /dev/null; then
  echo "user exit!"
else
  useradd $NAME
  echo "$NAME" | passwd --stdin $NAME &> /dev/null
fi
