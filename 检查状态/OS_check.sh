#!/bin/bash
#enter the container, check the system:centos or opensuse.
for container_id in $(kubectl get pods -n itsma --show-all | grep -v NAME | awk '{print $1}')
   do
   echo "=======================$container_id======================="
   kubectl exec -it $container_id  cat /etc/os-release -n itsma
   echo

done