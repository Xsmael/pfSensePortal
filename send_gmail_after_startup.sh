#!/usr/local/bin/bash

BASEDIR=/home/pfSensePortal

/usr/bin/perl -I /usr/local/lib/perl5/site_perl/5.10.1/ -I /usr/local/lib/perl5/site_perl/5.10.1/mach $BASEDIR/send_gmail_after_startup.perl `date +%Y%m%d-%H%M` 
