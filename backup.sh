#!/bin/sh

export REPO='/home/asadik/.borg_backup'

# die if borg is already running
if pidof -x borg >/dev/null; then
    echo "Backup already running"
    exit
fi

borg create --stats -v                      \
    $REPO::'{hostname}-{now:%Y-%m-%d}-1'      \
    /home/asadik                            \
    --exclude '/home/asadik/.borg_backup'   \
    --exclude '/home/asadik/.local'         \
    --exclude '/home/asadik/.cache'

# prune to remove old backups
borg prune -v --stats --list $REPO --prefix '{hostname}-' \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6
