#!/usr/bin/env bash
# set -x
set -e

CLOUDS_LIST=""
FOLDERS_LIST=""
INSTANCES_LIST=""
INSTANCE_INFO=""
FILE_RESULT="results/yc_vm_instances.json"
GREEN="\e[32m"
BLUE="\e[3;94m"
ENDCOLOR="\e[0m"

declare -A yc_commands=( 
    ["clickhouse"]="managed-clickhouse cluster"
    ["greenplum"]="managed-greenplum cluster"
    ["ip"]="vpc address"
    ["k8s"]="managed-kubernetes cluster"
    ["kafka"]="managed-kafka cluster"
    ["mongo"]="managed-mongodb cluster"
    ["mysql"]="managed-mysql cluster"
    ["pg"]="managed-postgresql cluster"
    ["redis"]="managed-redis cluster"
    ["vm"]="compute instance" 
    ["s3"]="storage bucket" 
)

get_clouds() {
    echo -e "${GREEN}Clouds found${ENDCOLOR}"
    yc resource-manager cloud list
    CLOUDS_LIST=$(yc resource-manager cloud list --format json | jq -r '.[].id')
}

get_folders() {
    echo "Folders in $1 found"
    yc resource-manager folder list --cloud-id $1
    FOLDERS_LIST=$(yc resource-manager folder list --format json --cloud-id $1 | jq -r '.[].id')
}

get_instances() {
    local cloud_id=$1
    local folder_id=$2
    local type=$3
    echo "Instances in folder $2 found"
    yc ${yc_commands[$type]} list --cloud-id $cloud_id --folder-id $folder_id
    if [[ $type == "s3" ]]
        then
            INSTANCES_LIST=$(yc ${yc_commands[$type]} list --format json --cloud-id $cloud_id --folder-id $folder_id | jq -r '.[].name')
        else
            INSTANCES_LIST=$(yc ${yc_commands[$type]} list --format json --cloud-id $cloud_id --folder-id $folder_id | jq -r '.[].id')
    fi
}

get_instance_info() {
    local cloud_id=$1
    local folder_id=$2
    local instance_id=$3
    local type=$4
    echo "Collecting cloud-id $cloud_id folder-id $folder_id instance $instance_id"
    INSTANCE_INFO=$(yc ${yc_commands[$type]} get $instance_id --cloud-id $cloud_id --folder-id $folder_id --format json)
}

poll_job() {
    echo "Searching for $type"
    FILE_RESULT="results/yc_${type}_instances.json"
    echo '[' > $FILE_RESULT
    for cloud_id in $CLOUDS_LIST
    do
        get_folders $cloud_id
        for folder_id in $FOLDERS_LIST
        do  
            get_instances $cloud_id $folder_id $type
            for instance_id in $INSTANCES_LIST
            do
                get_instance_info $cloud_id $folder_id $instance_id $type
                echo $INSTANCE_INFO >> $FILE_RESULT
                echo "," >> $FILE_RESULT
            done
        done
    done

    # delete last coma
    sed -i '' -e '$ d' $FILE_RESULT # mac
    # sed -i '$ d' $FILE_RESULT # linux

    echo ']' >> $FILE_RESULT
}

get_clouds

echo "Searching for ${!yc_commands[@]}"

for type in ${!yc_commands[@]}
do  
    # N=5 # limit number of jobs
    # ((i=i%N)); ((i++==0)) && wait
    poll_job &
done

# trap exit signal of parallel jobs and wait for them to exit
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM
wait

# for file in $(ls results)
# do
#     cat results/$file |jq '[.[] |
#     [leaf_paths as $path | {"key": $path | join("/"), "value": getpath($path)}]
#     | from_entries]' > results_flatten/$file
# done 