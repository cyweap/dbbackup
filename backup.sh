#!/bin/bash
dbuser='<User name>'
dbpasswd='<Password>'
dbhost='localhost'
configfile=$PWD/config.cnf
if [ -f $PWD/config.cnf ];
	then
		echo "config.cnf File Found"
	else
		touch $configfile
		echo "[client]" > $configfile
		echo "user=$dbuser" >> $configfile
		echo "password=$dbpasswd" >> $configfile
		echo "host=$dbhost" >> $configfile
		echo "config.cnf File Created"
fi
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

mysql --defaults-extra-file=$configfile -N -e 'set @@global.show_compatibility_56=ON'

mysql --defaults-extra-file=$configfile -N -e 'show databases' | while read dbname; do mysqldump --defaults-extra-file=$configfile --complete-insert --routines --triggers --single-transaction "$dbname" | gzip > /dbbackup/"$(date +%d%m%Y)"/"$dbname""$(date +%d%m%Y)".sql.gz; done

find /dbbackup/ -type d -mtime +29 -print
find /dbbackup/ -type d -mtime +29 -exec rm -rf {} \;
echo "Your Backup Successful Done"
exit
