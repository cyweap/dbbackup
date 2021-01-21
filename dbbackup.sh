#!/bin/bash

if [ -d /dbbackup ];
	then
		echo "DBBACKUP Directory Found"
	else
		mkdir /dbbackup
		echo "DBBACKUP Directory Created"
fi
if [ -d /dbbackup/"$(date +%d%m%Y)" ];
	then
		echo "$(date +%d%m%Y) Directory Found"
	else
		mkdir /dbbackup/"$(date +%d%m%Y)"
		echo "$(date +%d%m%Y) Directory Created"
fi
if [ -d /usr/local/psa ];
	then
		echo "This is Plesk"
		plesk db -e 'show databases' | while read dbname; do plesk db dump --complete-insert --routines --triggers --single-transaction "$dbname" | gzip > /dbbackup/"$(date +%d%m%Y)"/"$dbname""$(date +%d%m%Y)".sql.gz; done
	else
		echo "This is Cpanel/Linux"
		mysql -N -e 'show databases' | while read dbname; do mysqldump --complete-insert --routines --triggers --single-transaction "$dbname" | gzip > /dbbackup/"$(date +%d%m%Y)"/"$dbname""$(date +%d%m%Y)".sql.gz; done
fi

find /dbbackup/ -type d -mtime +7 -print
find /dbbackup/ -type d -mtime +7 -delete
exit
