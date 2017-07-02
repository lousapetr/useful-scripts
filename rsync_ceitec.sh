#!/bin/bash

MACHINE=        # name of server with storage capacity
FROM=           # local directory to backup (e.g. /home/USER, ...)
DAILY=          # remote directory (on $MACHINE) for everyday rsync backup (e.g. .../daily)
MONTHLY=        # remote directory (on $MACHINE) for a tar dump of whole backup (e.g. .../montly)

LOG=            # name of file to log the result of rsync backuping (e.g. ~/.cronlog)


# rsync local directory structure to remote storage server
function synchronize ()
{
    from=$1
    to=$2

    echo `date`
    
    /usr/local/bin/rsync \
        --acls           \
        --times          \
        --verbose        \
        --human-readable \
        --progress       \
        --delete         \
        --recursive      \
        --prune-empty-dirs \
        $from $to        \
    | tail -2

    echo
}

# archive complete directory at remote storage to gzipped tar - let it move to tapes
function full_dump ()
{
    machine=$1
    from=$2
    to=$3

    curr_date=$(date +"%Y_%m_%d")
    backup_name=$to/backup_$curr_date.tgz

    # -C $dir jumps to given directory and then adds everything (.) to the archive
    # hack needed to remove STDERR "Removing leading `/' from member names"
    ssh $machine "tar czf $backup_name -C $from ."

    echo `date`
    dump_size=$(ssh $machine "ls -lh  $backup_name" | awk '{print $5}')
    echo "Backup saved to $backup_name"
    echo "Total size of dump is: $dump_size"
    echo
}


case $1 in
    '-d')
        # daily synchronize complete home to storage server using rsync
        synchronize $FROM $MACHINE:$DAILY >>$LOG;;
    '-m')
        # once a time dump whole backup to gzipped tar file for permanent storage
        full_dump $MACHINE $DAILY $MONTHLY >>$LOG;;
esac
