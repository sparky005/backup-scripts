#!/bin/bash
sudo cp ./1gist_backup /etc/cron.hourly/
cp ./crontab /var/spool/cron/$USER
