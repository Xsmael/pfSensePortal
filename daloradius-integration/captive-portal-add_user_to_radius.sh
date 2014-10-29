#!/usr/local/bin/bash

IP=$1
NAME=$2
EMAIL=$(echo $3 | awk '{print tolower($0)}')
OWNER=$4

DATE=`date +%Y%m%d-%H%M`

BASEDIR=`dirname $0`

MAC=$($BASEDIR/resolve_mac_address.sh $IP)
MAC_FIRST_DIGITS=$(echo $MAC | cut -c 1-6 | awk '{print toupper($0)}')
# check in the local copy of the IEEE OUI database
# once in a while get an update from http://standards.ieee.org/develop/regauth/oui/public.html
MAC_VENDOR=$(grep "(base 16)" $BASEDIR/ieee_oui.txt | grep $MAC_FIRST_DIGITS | awk -F"\t" '{ print $3 }' | sed -e 's/ /_/g')

# netbios doesn't seem as reliable as dhcp hostname
#NETBIOS=$($BASEDIR/resolve_netbios_name.sh $IP)
DHCPHOSTNAME=$($BASEDIR/resolve_hostname.sh $IP)

GROUP=APZUnet-guest
# auto elevate all @pih.org and partners.org users
echo $EMAIL | grep "@pih.org"
if [ $? -eq 0 ]; then
	GROUP=APZUnet-user
fi
echo $EMAIL | grep "@partners.org"
if [ $? -eq 0 ]; then
	GROUP=APZUnet-user
fi
# auto elevate all APZU users
#echo $OWNER | grep "apzu"
#if [ $? -eq 0 ]; then
#	GROUP=APZUnet-user
#fi
# auto elevate all APZU- and PIH computers
echo $DHCPHOSTNAME | grep "apzu" --ignore-case
if [ $? -eq 0 ]; then
	GROUP=APZUnet-user
fi
echo $DHCPHOSTNAME | grep "pih" --ignore-case
if [ $? -eq 0 ]; then
	GROUP=APZUnet-user
fi

$BASEDIR/daloradius-new-user-with-mac-auth.sh $MAC "" "$NAME" "$EMAIL" "$OWNER" "$GROUP" "$IP" "$DHCPHOSTNAME" "$MAC_VENDOR"

echo "$MAC - $IP - x - newly registered - `date +%Y%m%d-%H%M%S`" >> /tmp/check_device_status.log

SUBJECT="pfSense: New user: $OWNER $NAME $EMAIL"
BODY="$OWNER
$MAC
$NAME
$EMAIL
$IP
$DHCPHOSTNAME
$DATE
$MAC_VENDOR
$DR_SERVER/daloradius/mng-edit.php?username=$MAC

(mail generated by script pfSense:///home/pfSensePortal/daloradius-integration/captive-portal-add_user_to_radius.sh)"

# send mail in the background
perl -I /usr/local/lib/perl5/site_perl/5.10.1/ -I /usr/local/lib/perl5/site_perl/5.10.1/mach $BASEDIR/../send_gmail.perl "$SUBJECT" "$BODY" &

