#!/bin/sh

export REPO='/home/asadik/.borg_backup'
export BORG_PASSPHRASE=''


# die if borg is already running
if pidof -x borg >/dev/null; then
    echo "Backup already running"
    exit
fi

# get last backup name to see if it was done today
last_backup_date=$(borg list --last 1 $REPO | cut -f1 -d' ' | grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" -o)
today=$(date +%Y-%m-%d)

if [ "$last_backup_date" != "$today" ]; then
    notify-send "Backups" "Starting Backup" -t 60000 --urgency=normal --icon=dialog-warning
    borg create --stats -v                      \
        $REPO::'{hostname}-{now:%Y-%m-%d}'      \
        /home/asadik                            \
        --exclude '/home/asadik/.borg_backup'   \
        --exclude '/home/asadik/.local'         \
        --exclude '/home/asadik/backup_exclusions'         \
        --exclude '/home/asadik/.cache'

    # prune to remove old backups
    borg prune -v --stats --list $REPO --prefix '{hostname}-' \
        --keep-daily=7 --keep-weekly=4 --keep-monthly=6
    notify-send "Backup Status" "Backup finished" -t 60000 --urgency=normal --icon=dialog-information
else
    echo "Backup already done today."
fi


# check if we're on my wifi network
networkname=$(iwgetid -r)
if [ "$networkname" == '715 - CR∑∑KS' ]; then
    # we're tethered to my phone
    # bail
    echo "Connected to phone, not uploading to aws"
    exit
fi
# check if our connection sucks
# or if it's too good to be true
speed=$(ping amazonaws.com -c 1 | sed -n 2p | cut -f4 -d'=' | cut -f1 -d' ' | cut -f1 -d'.')
if [[ $speed -gt 200 ]] || [[ $speed -lt 5 ]]; then
    # bad connection
    # bail
    echo "Connection speed is too slow ($speed)! Bailing"
    exit
fi
echo "Uploading..."
aws s3 sync $REPO s3://peterpanda2-backups --storage-class STANDARD_IA --delete
rc=$?
if [ $rc != 0 ]; then
    notify-send "AWS Sync Status" "FAILED" -t 60000 --urgency=normal --icon=dialog-error
else
    notify-send "AWS Sync Status" "Complete!" -t 60000 --urgency=normal --icon=dialog-information
    echo "Done!"
fi
