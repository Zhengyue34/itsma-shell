#/bin/bash
#check Readiness and Liveness in every pod
for container_id in $(kubectl get pods -n itsma --show-all | grep -v NAME | awk '{print $1}')
	do
	echo "===================================$container_id======================================="
	echo "Liveness && Readiness:"
	kubectl describe pod $container_id -n itsma | grep -E "Readiness|Liveness"
	echo "Check finished"
	echo
done