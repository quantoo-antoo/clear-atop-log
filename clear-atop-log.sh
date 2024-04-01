#!/bin/bash

CHECK_DATE=${1:-1}
DELETE_OLDER_THAN_DAYS=${2:-90}
CURRENT_DATE=$(date +%s)

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
