#!/bin/bash

CHECK_DATE=${1:-1}
DELETE_OLDER_THAN_DAYS=${2:-90}
CRON_FIELDS_STRING=${3:-"* * * 1-12/3 *"}

touch /mnt
mount /dev/vg0/root /mnt
mount /dev/vg0/var /mnt/var

touch /mnt/var/spool/cron/root
cp $(dirname "$0")/clear-atop-log.sh /mnt/root/clear-atop-log.sh

if [ $(crontab -u root -l | grep -o clear-atop-log.sh | wc -l ) -gt 0 ]; then
	sed "/clear-atop-log.sh$/d" /mnt/var/spool/cron/root
fi

echo "$CRON_FIELDS_STRING /bin/bash /root/clear-atop-log.sh $CHECK_DATE $DELETE_OLDER_THAN_DAYS" >> /mnt/var/spool/cron/root
