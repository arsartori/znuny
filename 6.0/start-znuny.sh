#!/bin/bash

# Change data connection
sed -i 's/\(.*{DatabaseHost}.*\)127.0.0.1/\1'"${MYSQL_HOSTNAME}"'/' /opt/otrs/Kernel/Config.pm
sed -i 's/\(.*{Database}.*\)otrs/\1'"otrs_${CUSTOMER_ID}"'/' /opt/otrs/Kernel/Config.pm
sed -i 's/\(.*{DatabaseUser}.*\)otrs/\1'"${MYSQL_USERNAME}"'/' /opt/otrs/Kernel/Config.pm
sed -i 's/\(.*{DatabasePw}.*\)some-pass/\1'"${MYSQL_PASSWORD}"'/' /opt/otrs/Kernel/Config.pm

# Start Apache
service apache2 start

# Start cron
service cron start

# Start OTRS Daemon
su -c "/opt/otrs/bin/Cron.sh start" -s /bin/bash otrs
