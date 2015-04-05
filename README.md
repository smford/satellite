Satellite and Spacewalk Related Scripts
======
1. ***satellite-backup-script-oracle.sh*** - Backup script for satellite 5.1 -> 5.5 (tested) oracle database based systems.  Set as a cronjob and run weekly.
2. ***satellite-backup-script-postgres.sh*** - Backup script for Satellite 5.5 -> 5.6 (tested) postgres database based systems. Set as a cronjob to run nightly.
3. ***satellite-check-systems-needing-errata.pl*** - Searches through all organisations looking for systems needing a particular errata.  Useful for identifying systems vulnerable to major security advisories (like shellshock, heartbleed, etc)
4. ***satellite-list-organisations.pl*** - Lists all organisations and all users for each organisation
5. ***satellite-make-chan-list.sh*** - Generates a list of all available channels
6. ***satellite-merge-chan.pl*** - Copies a channels packages and errata to another channel, useful for maintaining Development, Test, Pre-production and Production channels
7. ***satelite-quick-list-orgs.pl*** - If you have many organisations, and need to quickly list them.
8. ***rhel-gpg-keys*** - List in human readible format, the current GPG keys you have installed

All scripts can be run from the command line
```
$ ./script 
 Output
$ 
```

## Contact
* Homepage: https://github.com/smford/satellite 
