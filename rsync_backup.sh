#!/bin/bash

MACHINE=        # name of server with storage capacity
FROM=           # local directory to backup (e.g. /home/USER, ~/Work, ...)
DAILY=          # remote directory (on $MACHINE) for everyday rsync backup (e.g. .../daily)
MONTHLY=        # remote directory (on $MACHINE) for a tar dump of whole backup (e.g. .../montly)

LOG=~/.cronlog            # name of file to log the result of rsync backuping (e.g. ~/.cronlog)

# Usage:
# 1. copy this script into your PATH (e.g. ~/bin)
# 2. make it executable - 'chmod u+x rsync_ceitec.sh'
# 3. fill out all variables above.
# 4. create cron jobs
# 5. DONE! - enjoy safety
 
# Cron operation:
# 1. run 'crontab -e'
# 2. create jobs similarly to this:
#   10 0 * * * ~/bin/rsync_ceitec.sh -d  # daily sync at 00:10am
#   10 2 1 * * ~/bin/rsync_ceitec.sh -m  # permanent backup dump at 02:10am every 1st day in month
# 3. save by 'ESC :wq' - like ordinary vi

# Cron structure:
#    *     *     *   *    *        command to be executed
#    -     -     -   -    -
#    |     |     |   |    |
#    |     |     |   |    +----- day of week (0 - 6) (Sunday=0)
#    |     |     |   +------- month (1 - 12)
#    |     |     +--------- day of month (1 - 31)
#    |     +----------- hour (0 - 23)
#    +------------- min (0 - 59)

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
