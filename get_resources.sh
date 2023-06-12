FILE="yc_pg.json"

echo '[' > $FILE

for cloud in $(yc resource-manager cloud list --format json | jq -r '.[].id')
do
    for folder in $(yc resource-manager folder list --format json --cloud-id $cloud | jq -r '.[].id')
    do
        #for instance in $(yc compute instance list --format json --cloud-id $cloud --folder-id $folder | jq -r '.[].id')
        for instance in $(yc managed-postgresql cluster list --format json --cloud-id $cloud --folder-id $folder | jq -r '.[].id')
        # for instance in $(yc managed-redis cluster list --format json --cloud-id $cloud --folder-id $folder | jq -r '.[].id')
        # for instance in $(yc managed-mysql cluster list --format json --cloud-id $cloud --folder-id $folder | jq -r '.[].id')
        do
            echo "cloud-id $cloud folder-id $folder instance $instance"
            # yc managed-redis cluster get $instance --cloud-id $cloud --folder-id $folder  --format json | jq -r '.config.resources' >> yc_redis.list
            yc managed-postgresql cluster get $instance --cloud-id $cloud --folder-id $folder  --format json >> $FILE
            # yc compute instance get $instance --cloud-id $cloud --folder-id $folder  --format json | jq -r '.resources' >> yc_pg.list
            # yc managed-mysql cluster get $instance --cloud-id $cloud --folder-id $folder  --format json >> $FILE
            echo "," >> $FILE
        done
    done
done

