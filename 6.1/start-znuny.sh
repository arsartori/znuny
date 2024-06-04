#!/bin/bash

# Set Permission on all files
/opt/otrs/bin/otrs.SetPermissions.pl
# Update Database
su -c "/opt/otrs/scripts/MigrateToZnuny6_1.pl" -s /bin/bash otrs
# Start cron
su -c "/opt/otrs/bin/Cron.sh start" -s /bin/bash otrs
service cron start
# Start Apache
apachectl -D FOREGROUND
