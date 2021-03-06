#!/bin/bash
usage() {
        echo "usage:"
        echo "  ./deleteOldAndCreateNewNamespace.sh oldNamespace newNamespace"
        exit
}

# arguments check
if [[ $@ < 3 ]]
then
        usage
fi

echo "Delete namespace $1..."
kubectl delete namespace $1

echo "Stop suite config..."
kubectl delete -f ....../suite_config.yaml

echo "Check status of pods in namespace $1..."
exitCode=0
while [ $exitCode == 0 ]; do
        sleep 5
        echo "All pods in namespace $1"

        status=$(kubectl get pod --namespace=$1)
        if [[ $status ]]; then
                echo $status
        else
                break
    fi
        exitCode=$?
done

echo "Delete pv $1pv"
kubectl delete pv $1pv
kubectl delete pv $1-smarta-pv

echo "Remove ....../itsma-$1"
rm -rf ....../itsma-$1

echo "Create ....../itsma-$2"
mkdir ....../itsma-$2

echo "Change owner of ....../itsma-$2"
chown -R itsma:itsma ....../itsma-$2

echo "Modify /etc/exports"
sed -i "s#itsma-$1#itsma-$2#" /etc/exports

echo "Exportfs -ra"
exportfs -ra

~
