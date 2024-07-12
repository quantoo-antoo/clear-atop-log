#!/bin/bash
#must be run as superuser

set -e

#pacman -Sy archiso

rm -rf /tmp/archlive/
mkdir /tmp/archlive/
cp -r /usr/share/archiso/configs/releng/ /tmp/archlive/

echo vim >> /tmp/archlive/releng/packages.x86_64
echo nano >> /tmp/archlive/releng/packages.x86_64

#disable pacman download timeout in case of slow internet
sed '/\[options\]/a DisableDownloadTimeout' /tmp/archlive/releng/pacman.conf

cp -f $(dirname "$0")/clear-atop-log.sh /tmp/archlive/releng/airootfs/root/
cp -f $(dirname "$0")/clear-atop-log-on-mnt.sh /tmp/archlive/releng/airootfs/root/
cp -f $(dirname "$0")/clear-var-tmp-on-mnt.sh /tmp/archlive/releng/airootfs/root/
cp -f $(dirname "$0")/install.sh /tmp/archlive/releng/airootfs/root/

sed -i '/^file_permissions/a ["/root/clear-atop-log.sh"]="0:0:744"' /tmp/archlive/releng/profiledef.sh 
sed -i '/^file_permissions/a ["/root/clear-atop-log-on-mnt.sh"]="0:0:744"' /tmp/archlive/releng/profiledef.sh 
sed -i '/^file_permissions/a ["/root/clear-var-tmp-on-mnt.sh"]="0:0:744"' /tmp/archlive/releng/profiledef.sh 
sed -i '/^file_permissions/a ["/root/install.sh"]="0:0:744"' /tmp/archlive/releng/profiledef.sh 

sed -i '/^options/ s/$/ script\=\/root\/install.sh/' /tmp/archlive/releng/efiboot/loader/entries/01-archiso-x86_64-linux.conf
sed -i '/^APPEND/ s/$/ script\=\/root\/install.sh/' /tmp/archlive/releng/syslinux/archiso_sys-linux.cfg

mkarchiso -v -w /tmp/archlive -o /tmp/archlive /tmp/archlive/releng
