#!/bin/bash

# remotely download latest backup file

BASEDIR=/home/pfSensePortal

# get pfSense login details
source $BASEDIR/config.txt

# login
wget -qO/dev/null --keep-session-cookies --save-cookies cookies.txt \
 --post-data "login=Login&usernamefld=`echo $USER`&passwordfld=`echo $PASSWD`" \
 --no-check-certificate $PF_SERVER/diag_backup.php

# get all active users
wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --output-document=all.html \
  "$PF_SERVER/status_captiveportal.php?zone=$ZONE"

# loop over users and terminate all sessions
cat all.html | grep '&order=&showact=&act=del&id' | cut -d "\"" -f2 | while read -r url
do
  wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate  --output-document=all2.html \
    "$PF_SERVER/status_captiveportal.php$url"
done

rm all.html
rm all2.html
rm cookies.txt

