#!/bin/bash

#boolean, 
# if 1 delete only atop logs older than a certain number of days, 
# if 0 delete all atop logs (default 1) 
DELETE_ALL_LOGS=${1:-0}

#integer, number of days for which atop logs are KEPT 
DELETE_OLDER_THAN_DAYS=${2:-90}

CURRENT_DATE=$(date +%s)

if [ $DELETE_ALL_LOGS -eq 1 ]; then
	rm -fv /mnt/var/log/atop/atop_* | echo "Deleted $(wc -l) file(s)"
else
	NUMBER_OF_DELETED_FILES=0
	for filename in /mnt/var/log/atop/atop_*; do
		
		ATOP_LOG_DATE=$(date +%s -d $(echo $filename | awk -F'_' '{print $2}'))
		LOG_AGE_DAYS=$(( ($CURRENT_DATE - $ATOP_LOG_DATE)/86400 ))

		if [ $LOG_AGE_DAYS -gt $DELETE_OLDER_THAN_DAYS ]; then
			rm -f $filename
			((NUMBER_OF_DELETED_FILES++))
		fi
	done
	echo "Deleted $NUMBER_OF_DELETED_FILES file(s)"
fi
