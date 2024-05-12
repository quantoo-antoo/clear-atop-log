#!/bin/bash

secs=10
while [ $secs -gt 0 ]; do
   echo -ne "The installation of the clear-atop-log script will start in $secs seconds. Press Ctrl+c to cancel\033[0K\r"
   sleep 1
   : $((secs--))
done

echo -e "\n"
read -t 10 -p "Do you want the script to DELETE ALL ATOP LOGS? (y/N): "
if [[ $REPLY =~ [yY] ]]; then
   #boolean, 
   # if 0 delete only atop logs older than a certain number of days, 
   # if 1 delete all atop logs (default 0) 
   DELETE_ALL_LOGS=1
else
   DELETE_ALL_LOGS=0
fi

if [ $DELETE_ALL_LOGS == 0 ]; then
   echo -e "\n"
   read -t 10 -p "How many DAYS to KEEP atop logs? (default 90): " DELETE_OLDER_THAN_DAYS
   echo -e "\n"
   read -t 20 -p "Enter crontab fields pattern (default 0 22 1 */3 *): " CRON_FIELDS_STRING
fi
#integer, number of days for which atop logs are KEPT 
DELETE_OLDER_THAN_DAYS=${DELETE_OLDER_THAN_DAYS:-90}

#string, determines how often the clear-atop-log.sh script runs (default at 22:00 every 3 months on the 1st day of the month)
CRON_FIELDS_STRING=${CRON_FIELDS_STRING:-"0 22 1 */3 *"}

#make sure /mnt exists, then mount required filesystems
echo -e "\n\nMounting host filesystems\n\n"
touch /mnt
mount /dev/vg0/root /mnt
mount /dev/vg0/var /mnt/var

#make sure crontab file exists for root on mounted filesystem, 
#then ensure correct ownership and permissions are set
echo -e "Creating the crontab file for root user\n\n"
touch /mnt/var/spool/cron/root
chown root:root /mnt/var/spool/cron/root
chmod 0600 /mnt/var/spool/cron/root

#copy script to root user's home directory on mounted filesystem
echo -e "Copying the clear-atop-log script\n\n"
cp -f /root/clear-atop-log.sh /mnt/root/clear-atop-log.sh

#remove all instances of clear-atop-log.sh from crontab, 
#then add clear-atop-log.sh to crontab with settings defined above
echo -e "Setting up scheduled execution of the clear-atop-log script\n\n"
if [ $(cat /mnt/var/spool/cron/root | grep -o clear-atop-log.sh | wc -l ) -gt 0 ]; then
	sed -i "/clear-atop-log.sh/d" /mnt/var/spool/cron/root
fi
echo "$CRON_FIELDS_STRING /bin/bash /root/clear-atop-log.sh $DELETE_ALL_LOGS $DELETE_OLDER_THAN_DAYS" >> /mnt/var/spool/cron/root

secs=5
while [ $secs -gt 0 ]; do
   echo -ne "Installation complete. The server will reboot in $secs seconds. Press Ctrl+c to cancel\033[0K\r"
   sleep 1
   : $((secs--))
done
shutdown -r now
