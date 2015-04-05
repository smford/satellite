#!/bin/bash
# A simple script to dump a list of redhat channels from within satellite, known to work on v5.1 - v5.6 servers
# Dumps output to the public directory so that others can easily see the list.
#
# Channel list is available from http://satelliteserver.ucl.ac.uk/pub/docs/channels.txt
# 
# Set this script to run as a cronjob to regenerte the list daily
# 10 7 * * * /root/scripts/make-chan-list.sh 2>&1
#
# Uncomment the below line to display only official red hat channels
#spacewalk-report channels|grep  '^rhn-tools\|^rhel-'|cut -f1,2 -d\, > /var/www/html/pub/docs/channels.txt
#
# Uncomment the below line to display all channels
#spacewalk-report channels|cut -f1,2 -d\, > /var/www/html/pub/docs/channels.txt
