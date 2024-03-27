#!/bin/bash

CHECK_DATE=${1:-1}
CURRENT_DATE=$(date +%s)
DELETE_OLDER_THAN_DAYS=${2:-90}
CRON_FIELDS_STRING="* * * 1-12/3 *"

touch /mnt
mount /dev/vg0/root /mnt
mount /dev/vg0/var /mnt/var

touch /mnt/var/spool/cron/root
cp $(realpath "$0") /mnt/root/clear-atop-log.sh
if [ $(crontab -u root -l | grep -o clear-atop-log.sh | wc -l ) -gt 0 ]; then
	sed "/clear-atop-log.sh$/d" /mnt/var/spool/cron/root
fi
echo "$CRON_FIELDS_STRING /bin/bash /root/clear-atop-log.sh" >> /mnt/var/spool/cron/root

if [ $CHECK_DATE -eq 1 ]; then
	for filename in /var/log/atop/atop_*; do
		
		ATOP_LOG_DATE=$(date +%s -d $(echo $filename | awk -F'_' '{print $2}'))
		LOG_AGE_DAYS=$(( ($CURRENT_DATE - $ATOP_LOG_DATE)/86400 ))

		if [ $LOG_AGE_DAYS -gt $DELETE_OLDER_THAN_DAYS ]; then
			rm -f $filename
		fi
	done
else
	rm -f /var/log/atop/atop_*
fi
