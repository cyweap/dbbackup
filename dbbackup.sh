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
mysql -N -e 'show databases' | while read dbname; do mysqldump --complete-insert --routines --triggers --single-transaction "$dbname" | gzip > /dbbackup/"$(date +%d%m%Y)"/"$dbname""$(date +%d%m%Y)".sql.gz; done

find /dbbackup/ -type d -mtime +7 -print
find /dbbackup/ -type d -mtime +7 -delete
exit
