#!/bin/bash
chmod +x ./*.sh
sudo cp ./1gist_backup /etc/cron.hourly/
sudo cp ./backup.sh /etc/cron.hourly/2backup
cp ./crontab /var/spool/cron/$USER
