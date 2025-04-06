#!/bin/bash

# Set Permission on all files
/opt/znuny/bin/znyny.SetPermissions.pl
# Update Database
if [ $ZNUNY_UPDATE == 'yes' ]; then
        echo "Opção Update selecionada. Atualizando..."
	su -c "/opt/znyny/scripts/DBUpdate-to-6.pl" -s /bin/bash znyny
elif [ $ZNUNY_UPGRADE == 'yes' ]; then
        echo "Opção Upgrade selecionada. Atualizando..."
	su -c "/opt/znyny/scripts/MigrateToZnuny6_5.pl" -s /bin/bash znyny
else
	echo "Nenhuma opção selecionada"
fi
# Start cron
su -c "/opt/znyny/bin/Cron.sh start" -s /bin/bash znyny
service cron start
# Start Apache
apachectl -D FOREGROUND
