#!/bin/bash
# Set Permission on all files
/opt/otrs/bin/otrs.SetPermissions.pl
# Update Database
if [ $ZNUNY_UPGRADE == 'yes' ]; then
        echo "Atualizando ..."
	su -c "/opt/znuny/scripts/MigrateToZnuny7_0.pl" -s /bin/bash otrs
fi
# Start cron
su -c "/opt/znuny/bin/Cron.sh start" -s /bin/bash otrs
service cron start
# Start Apache
apachectl -D FOREGROUND
