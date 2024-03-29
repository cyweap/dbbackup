#!/bin/bash
#################################################################
#################CYWEAP##########################################
#################################################################
dbuser='<db user name>'
dbpasswd='<db password>'
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
if [ -d /dbbackup ]; # By default backup location is "/dbbackup"
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
# IF FACING FOLLOWING ERROR PLEASE UNCOMMENT 34 NO LINE
#(mysqldump: Couldn't execute 'SELECT /*!40001 SQL_NO_CACHE */ * FROM `GLOBAL_STATUS`': The 'INFORMATION_SCHEMA.GLOBAL_STATUS' feature is disabled; see the documentation for 'show_compatibility_56' (3167)#

#mysql --defaults-extra-file=$configfile -N -e 'set @@global.show_compatibility_56=ON'

mysql --defaults-extra-file=$configfile -N -e 'show databases' | grep -v 'information_schema\|mysql\|performance_schema\|phpmyadmin\|sys'| while read dbname; do mysqldump --defaults-extra-file=$configfile --complete-insert --routines --triggers --single-transaction "$dbname" | gzip > /dbbackup/"$(date +%d%m%Y)"/"$dbname""$(date +%d%m%Y)".sql.gz; done

#Backup Details
echo "BackUp Location /dbbackup/$(date +%d%m%Y)" > $PWD/backupreport"$(date +%d%m%Y)".txt
echo "BackUp DatabaseFiles" >> $PWD/backupreport"$(date +%d%m%Y)".txt
ls -al /dbbackup/$(date +%d%m%Y) >> $PWD/backupreport"$(date +%d%m%Y)".txt

echo "30 days deleted files list" >> $PWD/backupreport"$(date +%d%m%Y)".txt
find /dbbackup/ -type d -mtime +29 -print >> $PWD/backupreport"$(date +%d%m%Y)".txt
find /dbbackup/ -type d -mtime +29 -exec rm -rf {} \;

cat $PWD/backupreport"$(date +%d%m%Y)".txt
echo "Backup successfully completed"

#for email report
#mail -s "Backup successfully completed" -t user@example.com < $PWD/backupreport"$(date +%d%m%Y)".txt
exit
