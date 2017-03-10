#!/bin/bash
if [ -z "$1" ]; then
    FOLDER="$PWD"
    echo ========== Check Folder: $FOLDER ==========
else
    FOLDER="$1"
    echo ========== Check Folder: $FOLDER ==========
fi

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

echoerr() { echo "$@" 1>&2; }

echoerr "This is a stderr output test"

if [ -d "$FOLDER" ] ; then
        for YAML in `find $FOLDER -type f \( -iname 'pv.yaml' \)`;
        do
                echo "==== Find YAML: " $YAML
                for k in "PersistentVolumeClaim" "PersistentVolume"
                do
                         case $k in
                         "PersistentVolumeClaim")
                                echo ["$k"]
								parse_yaml $YAML > $YAML.pvc.log
								sed -n "/kind=(\"PersistentVolumeClaim\")/,/spec_volumeName/p" $YAML.pvc.log > $YAML.pvc.log.tmp
										while IFS="=" read -r key value;
                                        do
                                                case "$key" in
                                                "metadata_name") metadata_name="$value"
                                                echo $metadata_name
                                                ;;
                                                "metadata_namespace") metadata_namespace="$value"
                                                kubectl get pvc `echo $metadata_name | cut -d'"' -f 2` -n `echo $metadata_namespace | cut -d'"' -f 2`
                                                ;;
												"spec_volumeName") spec_volumeName="$value"
                                                echo $spec_volumeName | cut -d'"' -f 2
												;;
                                                esac
                                        done < $YAML.pvc.log.tmp
                                echo "PersistentVolumeClaim Check done!"
                                ;;
                        "PersistentVolume")
                                parse_yaml $YAML > $YAML.pv.log
								sed -n "/kind=(\"PersistentVolume\")/,/spec_nfs_path/p" $YAML.pv.log > $YAML.pv.log.tmp
										while IFS="=" read -r key value;
                                        do
                                                case "$key" in
                                                "metadata_name") metadata_name="$value"
                                                echo $metadata_name
												kubectl get pv `echo $metadata_name | cut -d'"' -f 2`
                                                ;;
                                                "spec_nfs_server") spec_nfs_server="$value"
                                                echo $spec_nfs_server | cut -d'"' -f 2
                                                ;;
												"spec_nfs_path") spec_nfs_path="$value"
												echo $spec_nfs_path | cut -d'"' -f 2
                                                nfs=`echo $spec_nfs_path | cut -d'"' -f 2`
												if [ -d "$nfs" ] ; then
													echo -e "Start to check logs \n" > chkPVlog.results.log
													for LOG in `find $nfs -type f \( -iname '*.log' \)`;
													do
														echo "==== Find log: " $LOG >> chkPVlog.results.log
														grep 'Error' $LOG >> chkPVlog.results.log
													done
												fi
                                                ;;
                                                esac
                                        done < $YAML.pv.log.tmp
                                echo "PersistentVolumeClaim Check done!"
                                ;;
                         
                        
                        esac
                done

                #rm *.yaml.*
				#rm YAML*log*
                echo -e "==== Check YAML: " $YAML done! "\n"
        done
fi





