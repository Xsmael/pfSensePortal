#!/usr/local/bin/bash

# remotely download latest backup file

PATH=$PATH:/usr/local/bin

TMP_LOGFILE=`mktemp /tmp/output.XXXXXX`
echo -e  "\n\n-- stdout and stderr of script --" > $TMP_LOGFILE
{

BASEDIR=/home/pfSensePortal
CONFIG_FILE=/tmp/config-router-`date +%Y%m%d%H%M%S`.xml

# get pfSense login details
source $BASEDIR/config.txt

# login
wget -qO/dev/null --keep-session-cookies --save-cookies cookies.txt \
 --post-data "login=Login&usernamefld=`echo $USER`&passwordfld=`echo $PASSWD`" \
 --no-check-certificate https://$PF_IP/diag_backup.php

# get the stuff
wget --keep-session-cookies --load-cookies cookies.txt \
 --post-data 'Submit=download&donotbackuprrd=yes' https://$PF_IP/diag_backup.php \
 --no-check-certificate -O $CONFIG_FILE

rm cookies.txt

scp $CONFIG_FILE backup@dev.pih-emr.org:malawi/pfsense-21
mv $CONFIG_FILE /home/local_backup_sequences

# take care of daloradius stuff as well

# keep only one copy of the full database including the accounting
ssh root@172.16.1.3 'mysqldump -u radius -pradius radius > /tmp/radius-complete.sql'
scp root@172.16.1.3:/tmp/radius-complete.sql .
tar czf radius-complete.tgz radius-complete.sql
rm radius-complete.sql
mv radius-complete.tgz /home/local_backup_sequences/

# get a smaller dump without radacct and radpostauth
DATE=`date +%Y%m%d%H%M%S`
ssh root@172.16.1.3 'mysqldump -u radius -pradius radius --ignore-table radius.radacct --ignore-table radius.radpostauth > /tmp/radius-no-authacct.sql'
scp root@172.16.1.3:/tmp/radius-no-authacct.sql .
tar czf radius-no-authacct-$DATE.tgz radius-no-authacct.sql
rm radius-no-authacct.sql
mv radius-no-authacct-$DATE.tgz /home/local_backup_sequences/
scp /home/local_backup_sequences/radius-no-authacct-$DATE.tgz backup@dev.pih-emr.org:malawi/pfsense-21

SUBJECT="pfSense: Backup sync'ed to local drive and Boston"
BODY="(mail generated by script pfSense:///home/pfSensePortal/misc/do-backup.sh)"

} >> $TMP_LOGFILE 2>> $TMP_LOGFILE

perl -I /usr/local/lib/perl5/site_perl/5.10.1/ -I /usr/local/lib/perl5/site_perl/5.10.1/mach $BASEDIR/send_gmail.perl "$SUBJECT" "$BODY `cat $TMP_LOGFILE`"
rm $TMP_LOGFILE
