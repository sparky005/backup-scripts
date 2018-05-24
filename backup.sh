#!/bin/sh

export REPO='/home/asadik/.borg_backup'
export BORG_PASSPHRASE=''


# die if borg is already running
if pidof -x borg >/dev/null; then
    echo "Backup already running"
    exit
fi

borg create --stats -v                      \
    $REPO::'{hostname}-{now:%Y-%m-%d}'      \
    /home/asadik                            \
    --exclude '/home/asadik/.borg_backup'   \
    --exclude '/home/asadik/.local'         \
    --exclude '/home/asadik/.cache'

# prune to remove old backups
borg prune -v --stats --list $REPO --prefix '{hostname}-' \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6


# check if we're on my wifi network
#networkname=$(nmcli -t -f active,ssid dev wifi | cut -f2 -d':' | head -1)
networkname=$(iwgetid -r)
if [ "$networkname" == '715 - CR∑∑KS' ]; then
    # we're tethered to my phone
    # bail
    echo "Connected to phone, not uploading to aws"
    exit
fi
aws s3 sync $REPO s3://peterpanda2-backups --storage-class STANDARD_IA
