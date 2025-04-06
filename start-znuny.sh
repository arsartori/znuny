#!/bin/bash

# Set Permission on all files
/opt/znuny/bin/znuny.SetPermissions.pl
# Update Database
if [ $ZNUNY_UPDATE == 'yes' ]; then
        echo "Opção Update selecionada. Atualizando..."
	su -c "/opt/znuny/scripts/DBUpdate-to-6.pl" -s /bin/bash znuny
elif [ $ZNUNY_UPGRADE == 'yes' ]; then
        echo "Opção Upgrade selecionada. Atualizando..."
	su -c "/opt/znuny/scripts/MigrateToZnuny6_5.pl" -s /bin/bash znuny
else
	echo "Nenhuma opção selecionada"
fi
# Start cron
su -c "/opt/znuny/bin/Cron.sh start" -s /bin/bash znuny
service cron start
# Start Apache
apachectl -D FOREGROUND
