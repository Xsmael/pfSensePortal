#!/bin/bash

BASEDIR=/home/pfSensePortal
source $BASEDIR/config.txt

IP=$1

MAC=$($BASEDIR/daloradius-integration/resolve_mac_address.sh $IP)

echo "<a href=`echo $DR_SERVER`/statistics/user_with_volume.php?username=`echo $MAC`>User statistics</a>"
