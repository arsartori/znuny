#!/bin/bash

if [ ! -f "/opt/otrs/installed" ]  ; then

    # Change data connection
    sed -i 's/\(.*{DatabaseHost}.*\)127.0.0.1/\1'"${MYSQL_HOSTNAME}"'/' /opt/otrs/Kernel/Config.pm
    sed -i 's/\(.*{Database}.*\)otrs/\1'"otrs_${CUSTOMER_ID}"'/' /opt/otrs/Kernel/Config.pm
    sed -i 's/\(.*{DatabaseUser}.*\)otrs/\1'"${MYSQL_USERNAME}"'/' /opt/otrs/Kernel/Config.pm
    sed -i 's/\(.*{DatabasePw}.*\)some-pass/\1'"${MYSQL_PASSWORD}"'/' /opt/otrs/Kernel/Config.pm

    # Test if mysql running
    while ! mysqladmin ping -h "${MYSQL_HOSTNAME}" -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -u"${MYSQL_USERNAME}" --silent; do sleep 1; echo "Wainting Mysql...\n"; done

    # Create database
    mysql -h "${MYSQL_HOSTNAME}" -u "${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -e "CREATE DATABASE otrs_${CUSTOMER_ID} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" && \

fi

touch "/opt/otrs/installed"

# Start Apache
service apache2 start

# Start cron
service cron start

# Start OTRS Daemon
su -c "/opt/otrs/bin/Cron.sh start" -s /bin/bash otrs
