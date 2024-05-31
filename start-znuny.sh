#!/bin/bash
# Start cron
su -c "/opt/otrs/bin/Cron.sh start" -s /bin/bash otrs
service cron start
# Set Permission on all files
/opt/otrs/bin/otrs.SetPermissions.pl
# Start Apache
apachectl -D FOREGROUND
