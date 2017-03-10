#!/bin/bash

if [ -z "$1" ]; then
    FOLDER="$PWD"
    echo ========== Check Folder: $FOLDER ==========
else
    FOLDER="$1"
    echo ========== Check Folder: $FOLDER ==========
fi

exception=0

parse_yaml() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
        }
    }'
}


if [ -d "$FOLDER" ] ; then
        for YAML in `find $FOLDER -type f \( -iname 'smsuite.yaml' \)`;
        do
                echo "==== Find YAML: " $YAML
                for k in "Namespace" "ConfigMap" "Service" "Ingress" "ReplicationController" "Pod"
                do
                         case $k in
                         "Namespace")
                                echo ["$k"]
                                for s in `sed -n "/kind: $k/,/name:/p" $YAML | sed -n 's/.*name: \(\S\)/\1/p'`
                                do
                                        kubectl get ns $s
										
										#if [kubectl get ns $s | grep Error] |wc -l
										# then exception=1
										#fi
                                done
                                echo "Namespace Check done!"
                                ;;
                        "ConfigMap")
                                echo ["$k"]
                                parse_yaml $YAML > $YAML.cm.log
                                sed -n "/kind=(\"ConfigMap\")/,/metadata_namespace/p" $YAML.cm.log > $YAML.cm.log.tmp
                                        while IFS="=" read -r key value;
                                        do
                                                case "$key" in
                                                "metadata_name") metadata_name="$value"
                                                #echo $metadata_name
                                                ;;
                                                "metadata_namespace") metadata_namespace="$value"
                                                kubectl get cm `echo $metadata_name | cut -d'"' -f 2` -n `echo $metadata_namespace | cut -d'"' -f 2`
                                                ;;
                                                esac
                                        done < $YAML.cm.log.tmp
                                echo "ConfigMap Check done!"
                                ;;
                         "Service")
                                echo ["$k"]
                                parse_yaml $YAML > $YAML.svc.log
                                sed -n "/kind=(\"Service\")/,/metadata_namespace/p" $YAML.svc.log > $YAML.svc.log.tmp
                                        while IFS="=" read -r key value;
                                        do
                                                case "$key" in
                                                "metadata_name") metadata_name="$value"
                                                #echo $metadata_name
                                                ;;
                                                "metadata_namespace") metadata_namespace="$value"
                                                #echo $metadata_namespace | cut -d'"' -f 2
                                                kubectl get svc `echo $metadata_name | cut -d'"' -f 2 | cut -d" " -f 2` -n `echo $metadata_namespace | cut -d'"' -f 2`
                                                esac
                                        done < $YAML.svc.log.tmp
                                echo "Service Check done!"
                                ;;
                        "Ingress")
                                echo ["$k"]
                                parse_yaml $YAML > $YAML.ing.log
                                sed -n "/kind=(\"Ingress\")/,/metadata_namespace/p" $YAML.ing.log > $YAML.ing.log.tmp
                                        while IFS="=" read -r key value;
                                        do
                                                case "$key" in
                                                "metadata_name") metadata_name="$value"
                                                #echo $metadata_name
                                                ;;
                                                "metadata_namespace") metadata_namespace="$value"
                                                kubectl get ing `echo $metadata_name | cut -d'"' -f 2 | cut -d" " -f 2` -n `echo $metadata_namespace | cut -d'"' -f 2`
                                                ;;
                                                esac
                                        done < $YAML.ing.log.tmp
                                echo "Ingress Check done!"
                                ;;
                        "ReplicationController")
                                echo ["$k"]
                                parse_yaml $YAML > $YAML.rc.log
                                sed -n "/kind=(\"ReplicationController\")/,/spec_template_spec_[containers_]*/p" $YAML.rc.log | sed "s/containers_//g" > $YAML.rc.log.tmp
                                        while IFS="=" read -r key value;
                                        do
                                                case "$key" in
                                                "metadata_name") metadata_name="$value"
                                                #echo $metadata_name | cut -d'"' -f 2
                                                ;;
                                                "metadata_namespace") metadata_namespace="$value"
                                                #echo $metadata_namespace | cut -d'"' -f 2
                                                ;;
                                                "spec_replicas") spec_replicas="$value"
                                                #echo $spec_replicas | cut -d'"' -f 2 | cut -d" " -f 1
                                                ;;
                                                "spec_template_spec_") spec_template_spec_="$value"
                                                kubectl get rc `echo $metadata_name | cut -d'"' -f 2` -n `echo $metadata_namespace | cut -d'"' -f 2`

                                                echo with $spec_replicas replicas pods:
                                                kubectl get po -n `echo $metadata_namespace | cut -d'"' -f 2` --show-all > $YAML.k8pods.log

                                                #echo $metadata_name
                                                podname=`echo $metadata_name | cut -d'"' -f 2`
                                                for p in `sed 1d $YAML.k8pods.log | awk '{print $1}' | grep $podname`
                                                do
                                                        kubectl get po $p -n `echo $metadata_namespace | cut -d'"' -f 2`
														readiness=`grep $p $YAML.k8pods.log | awk '{print $2}'`
														if [ `echo $readiness | cut -d'/' -f 2` == `echo $readiness | cut -d'/' -f 1` ]
														then
															echo Pod $p status $readiness is ready!
														else
															echo Error from Pod: $p status $readiness is not ready!
														fi
                                                done
                                                        ;;
                                                esac
                                        done < $YAML.rc.log.tmp
                                echo "ReplicationController Check done!"
                                ;;
                        "Pod")
                                echo ["$k"]
                                parse_yaml $YAML > $YAML.po.log
                                sed -n "/kind=(\"Pod\")/,/spec_[containers_]*/p" $YAML.po.log | sed "s/containers_//g" > $YAML.po.log.tmp
                                        while IFS="=" read -r key value;
                                        do
                                                case "$key" in
                                                "metadata_namespace") metadata_namespace="$value"
                                                #echo $metadata_namespace | cut -d'"' -f 2
                                                ;;
                                                "spec_") spec_="$value"
												pod=`echo $spec_ | cut -d'"' -f 2 | cut -d" " -f 2`
												namespace=`echo $metadata_namespace | cut -d'"' -f 2`
                                                kubectl get po $pod -n $namespace
												
												readiness=`echo kubectl get pod $pod -n $namespace | grep $pod | awk '{print $2}'`
												if [ `echo $readiness | cut -d'/' -f 2` == `echo $readiness | cut -d'/' -f 1` ]
														then
															echo Pod $p status $readiness is ready!
														else
															echo Error from Pod: $p status $readiness is not ready!
														fi
                                                esac
                                        done < $YAML.po.log.tmp
                                echo "Pod Check done!"
                                ;;
                        esac
                done

                rm *.yaml.*
                echo -e "==== Check YAML: " $YAML done! "\n"
        done
fi

#if [ $exception -eq 1 ]
#then
#  exit 0
#else
#  exit 1
#fi


