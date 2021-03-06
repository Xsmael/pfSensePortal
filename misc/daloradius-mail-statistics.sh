#!/usr/local/bin/bash

BASEDIR=/home/pfSensePortal
source $BASEDIR/config.txt

FILE=/tmp/statistics-`date +%Y%m%d`.html
/usr/local/bin/curl --retry 2 -s -o $FILE `echo $DR_SERVER`/statistics/statistics.php
echo $? > $FILE.exitcode

SUBJECT="`echo "172.16.1.2 - pfSense: Users statistics: "` `date +%Y%m%d-%H%M`"
BODY=`echo "(mail generated by script pfSense:///home/pfSensePortal/misc/daloradius-mail-statistics.sh)"`

/usr/bin/perl -I /usr/local/lib/perl5/site_perl/5.10.1/ -I /usr/local/lib/perl5/site_perl/5.10.1/mach $BASEDIR/send_gmail_with_attachment.perl "$SUBJECT" $FILE $FILE application/html "$BODY"
