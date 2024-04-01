#!/bin/bash

#boolean, 
# if 1 delete only atop logs older than a certain number of days, 
# if 0 delete all atop logs (default 1) 
CHECK_DATE=${1:-1}

#integer, number of days for which atop logs are KEPT 
DELETE_OLDER_THAN_DAYS=${2:-90}

#string, determines how often the clear-atop-log.sh script runs (default at 22:00 every 3 months on the 1st day of the month)
CRON_FIELDS_STRING=${3:-"0 22 1 */3 *"}

#make sure /mnt exists, then mount required filesystems
touch /mnt
mount /dev/vg0/root /mnt
mount /dev/vg0/var /mnt/var

#make sure crontab file exists for root on mounted filesystem, 
#then ensure correct ownership and permissions are set
touch /mnt/var/spool/cron/root
chown root:root /mnt/var/spool/cron/root
chmod 0600 /mnt/var/spool/cron/root

#copy script to root user's home directory on mounted filesystem
cp $(dirname "$0")/clear-atop-log.sh /mnt/root/clear-atop-log.sh

#remove all instances of clear-atop-log.sh from crontab, 
#then add clear-atop-log.sh to crontab with settings defined above
if [ $(crontab -u root -l | grep -o clear-atop-log.sh | wc -l ) -gt 0 ]; then
	sed "/clear-atop-log.sh$/d" /mnt/var/spool/cron/root
fi
echo "$CRON_FIELDS_STRING /bin/bash /root/clear-atop-log.sh $CHECK_DATE $DELETE_OLDER_THAN_DAYS" >> /mnt/var/spool/cron/root
