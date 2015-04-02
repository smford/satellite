#!/bin/bash
# A simple backup script for satellite, known to work on v5.1 - v5.5 servers that use the inbuilt oracle database.
# Set the cronjob to run weekly (as the internal oracle backups take satellite offline)
# 0 21 * * 0 /root/scripts/satellite-backup-script-oracle.sh >/dev/null 2>&1
set -x
BACKUPPATH=/var/satellite/backupdb
BACKUPNAME=db-backup-$(date "+%F")

BACKUPLOCATION=${BACKUPPATH}/${BACKUPNAME}

mkdir -p ${BACKUPLOCATION}
chown oracle:oracle ${BACKUPLOCATION}
{
/usr/sbin/rhn-satellite stop
su - oracle -c'
db-control backup  ${BACKUPLOCATION}
';
/usr/sbin/rhn-satellite start
OLDBACKUP=$(date --date='1 week ago' +%F)
if [ -d  ${BACKUPLOCATION}/db-backup-${OLDBACKUP} ]
then
    echo "** Database Backup Detected"
    echo "Purging backup -  ${BACKUPLOCATION}/db-backup-${OLDBACKUP}"
    rm -rvf  ${BACKUPLOCATION}/db-backup-${OLDBACKUP}
else
    echo "** No Backup Detected"
fi
} >>  ${BACKUPPATH}/backup.log
