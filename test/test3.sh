#!/bin/bash
NAME=user1
USERID=`id -u $NAME`
[ $USERID -eq 0 ] && echo "Admin" || echo "Common user"
