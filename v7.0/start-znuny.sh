#!/bin/bash
# Set Permission on all files
/opt/znuny/bin/otrs.SetPermissions.pl
# Update Database
if [ $ZNUNY_UPGRADE == 'yes' ]; then
        echo "Atualizando ..."
	su -c "/opt/znuny/scripts/MigrateToZnuny7_0.pl" -s /bin/bash znuny
fi
# Start cron
su -c "/opt/znuny/bin/Cron.sh start" -s /bin/bash znuny
service cron start
# Start Apache
apachectl -D FOREGROUND
