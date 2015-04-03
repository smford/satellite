#!/bin/bash
#
# A simple script for satellite v5.6 to backup and rotate backups
#
# 0 5 * * 0 /root/scripts/satellite-backup-script-postgres.sh >/dev/null 2>&1
# The cronjob should be set to run daily, the NUMBACKUPS variable defines how many daily backups to maintain.  Only a small number is needed as ideally 
# they should be archived within the systems normal regular backup strategy.
#
# https://access.redhat.com/documentation/en-US/Red_Hat_Satellite/5.6/html/User_Guide/sect-Red_Hat_Satellite-User_Guide-Backing_up_an_Embedded_Database.html

# uncomment the below line and run the script from the console to see what is happening
#set -x

BACKUPLOCATION=/var/satellite/backupdb
BACKUPDATE=$(date "+%F")
NUMBACKUPS=2

echo "================================="
if [ ! -d $BACKUPLOCATION ]
then
    echo "Backup location does not exist, creating ${BACKUPLOCATION}"
    mkdir -p ${BACKUPLOCATION}
    echo "Changing ownership to allow postgres to write out the database"
    chown postgres:postgres ${BACKUPLOCATION}
fi

{
mkdir -p ${BACKUPLOCATION}/${BACKUPDATE}
chown postgres:postgres ${BACKUPLOCATION}/${BACKUPDATE}

echo "Starting backup: $(date)"
echo "Creating backup: ${BACKUPLOCATION}/${BACKUPDATE}/db-backup-${BACKUPDATE}"

db-control online-backup ${BACKUPLOCATION}/${BACKUPDATE}/db-backup-${BACKUPDATE}

CLEANOLD=$(date --date="${NUMBACKUPS} days ago" +%F)


if [ -d ${BACKUPLOCATION}/${CLEANOLD} ]
then
    echo "Old Database Backup Detected"
    echo "Purging backup - ${BACKUPLOCATION}/${CLEANOLD}"
    rm -rvf ${BACKUPLOCATION}/${CLEANOLD}
else
    echo "No old backup detected"
fi

echo "Finished backup: $(date)"
} >> ${BACKUPLOCATION}/backup.log
