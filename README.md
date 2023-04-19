# docker-znuny
Create Docker image with Znuny (OTRS)

## Database
CREATE DATABASE otrs CHARACTER SET = 'utf8' COLLATE = 'utf8_general_ci';
create user otrs identified by 'otrs';
grant all privileges on otrs.* to otrs@'%';

6.0
max_allowed_packet   = 64M
query_cache_size     = 32M
innodb_log_file_size = 256M

6.1
/etc/mysql/mariadb.conf.d/50-znuny_config.cnf

[mysql]
max_allowed_packet=256M
[mysqldump]
max_allowed_packet=256M

[mysqld]
innodb_file_per_table
innodb_log_file_size = 256M
max_allowed_packet=256M
character-set-server  = utf8
collation-server      = utf8_general_ci

## Install
apt update && apt install -y apache2 mariadb-client

# Install Perl modules
apt -y install cpanminus libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdatetime-perl libmoo-perl bash-completion libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl libauthen-sasl-perl libauthen-ntlm-perl libhash-merge-perl libical-parser-perl libspreadsheet-xlsx-perl libcrypt-jwt-perl libcrypt-openssl-x509-perl jq

cpanm install Jq

# Download Znuny
cd /opt
wget https://download.znuny.org/releases/znuny-latest-6.1.tar.gz

# Extract
tar xfz znuny-latest-6.1.tar.gz

# Create a symlink
sudo ln -s /opt/znuny-6.1.1 /opt/otrs

# Add user for Debian/Ubuntu
useradd -d /opt/otrs -c 'Znuny user' -g www-data -s /bin/bash -M -N otrs

# Copy Default Config
cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm

# Set permissions
/opt/otrs/bin/otrs.SetPermissions.pl

# As otrs User - Rename default cronjobs
su - otrs
cd /opt/otrs/var/cron
for foo in *.dist; do cp $foo `basename $foo .dist`; done

# Check modules
~otrs/bin/otrs.CheckModules.pl --all

# Install Perl modules
apt -y install apache2 mariadb-client cpanminus libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdatetime-perl libmoo-perl bash-completion libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl libauthen-sasl-perl libauthen-ntlm-perl libhash-merge-perl libical-parser-perl libspreadsheet-xlsx-perl libcrypt-jwt-perl libcrypt-openssl-x509-perl jq

cpanm install Jq

