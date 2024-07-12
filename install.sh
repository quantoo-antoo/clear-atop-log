#!/bin/bash

#integer, number of days for which atop logs are KEPT 
#DELETE_OLDER_THAN_DAYS=${DELETE_OLDER_THAN_DAYS:-90}

#string, determines how often the clear-atop-log.sh script runs (default at 22:00 every 3 months on the 1st day of the month)
#CRON_FIELDS_STRING=${CRON_FIELDS_STRING:-"0 22 1 */3 *"}

#make sure /mnt exists, then mount required filesystems
echo -e "\n\nMounting host filesystems\n\n"
touch /mnt
mount /dev/vg0/root /mnt
mount /dev/vg0/var /mnt/var

#enter an endless loop to display the menu
while true;
do

 #print out information about disk space on /var volume
 echo "Printing out disk usage information"
 echo -e "\n" && df -h /mnt/var | awk '{print $3 "\t" $4 "\t" $2 "\t" $5 "\t" $6}' && echo "-------------------------------------------------" && echo -e "Size\t\t\t\tDirectory" && du -sh /mnt/var/log/atop /mnt/var/tmp | awk '{print $1 "\t\t\t\t" $2}'

 #check if scheduled execution of script is set up
 if [ $(cat /mnt/var/spool/cron/root | grep -o clear-atop-log.sh | wc -l ) -gt 0 ]; then
   echo -e "\n clear-atop-log.sh script is INSTALLED"
 else  
   echo -e "\n clear-atop-log.sh script is NOT installed"
 fi
 
 echo -e "\n"
 echo "What would you like to do?"
 echo "  1. Clear atop log"
 echo "  2. Clear temp files"
 echo "  3. Clear the screen and display disk space info"
 echo "  4. Set up automatic clearing of atop log"
 echo "  5. Stop clearing atop log automatically"
 echo -e "\n"
 echo "  9. Enter shell"
 echo "  0. Reboot server"
 read -p "Select menu entry: "

 if [[ $REPLY = 1 ]]; then
 
   
   read -p "Do you want the script to DELETE ALL ATOP LOGS? (y/N): "
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
      read -p "How many DAYS to KEEP atop logs? (default 90): " DELETE_OLDER_THAN_DAYS
   fi
   DELETE_OLDER_THAN_DAYS=${DELETE_OLDER_THAN_DAYS:-90}
 
   /bin/bash /root/clear-atop-log-on-mnt.sh $DELETE_ALL_LOGS $DELETE_OLDER_THAN_DAYS

 elif [[ $REPLY = 2 ]]; then
   read -p "Do you want to clear all temp files in /var/tmp? (y/N): "
   if [[ $REPLY =~ [yY] ]]; then
     /bin/bash /root/clear-var-tmp-on-mnt.sh 
   fi  

 elif [[ $REPLY = 3 ]]; then
   clear
 
 elif [[ $REPLY = 4 ]]; then
   
   read -p "Do you want the script to DELETE ALL ATOP LOGS? (y/N): "
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
      read -p "How many DAYS to KEEP atop logs? (default 90): " DELETE_OLDER_THAN_DAYS
   fi
   DELETE_OLDER_THAN_DAYS=${DELETE_OLDER_THAN_DAYS:-90}
 
   echo -e "\n"
   read -p "Enter crontab fields pattern (default 0 22 1 */3 *): " CRON_FIELDS_STRING
   CRON_FIELDS_STRING=${CRON_FIELDS_STRING:-"0 22 1 */3 *"}
 
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
 
 elif [[ $REPLY = 5 ]]; then
   
   read -p "Do you want to stop the clear-atop-log.sh script from running periodically? (y/N): "
   if [[ $REPLY =~ [yY] ]]; then
   
     #remove all instances of clear-atop-log.sh from crontab, 
     echo -e "Removing scheduled execution of the clear-atop-log script\n\n"
     if [ $(cat /mnt/var/spool/cron/root | grep -o clear-atop-log.sh | wc -l ) -gt 0 ]; then
	     sed -i "/clear-atop-log.sh/d" /mnt/var/spool/cron/root
     fi
   fi
   
 elif [[ $REPLY = 9 ]]; then
   
   echo -e "\n\nTo enter the menu again type ./install.sh\n\n"
   break

 elif [[ $REPLY = 0 ]]; then
 
   read -p "Do you want to reboot the server? (y/N): "
   if [[ $REPLY =~ [yY] ]]; then
	   shutdown -r now
   fi
 
 else :

 fi
done
 
