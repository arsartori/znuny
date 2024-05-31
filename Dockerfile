FROM ubuntu:20.04
LABEL maintainer="Andre Sartori <andre@aph.dev.br>"
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Update and install
RUN apt update && apt install -y apache2 libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl \
    libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl \
    libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl \
    libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdatetime-perl \
    libmoo-perl bash-completion libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl \
    libauthen-sasl-perl libauthen-ntlm-perl wget cron && apt clean
# Download and install znuny
RUN cd /opt && wget https://download.znuny.org/releases/znuny-6.0.36.tar.gz && \
    tar xfz znuny-${ZNUNY_VERSION}.tar.gz && ln -s /opt/znuny-6.0.36 /opt/otrs && \
    cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm && \
    useradd -d /opt/otrs -c 'Znuny user' -g www-data -s /bin/bash -M -N otrs && /opt/otrs/bin/otrs.SetPermissions.pl
# Config crontab
RUN su - otrs && cd /opt/otrs/var/cron && for foo in *.dist; do cp $foo `basename $foo .dist`; done
# Config Apache
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/znuny.conf && \
    a2enmod perl headers deflate filter cgi && a2dismod mpm_event && a2enmod mpm_prefork && a2enconf znuny
RUN sed -i 's/\$HOME/\/opt\/otrs/g' /opt/otrs/var/cron/otrs_daemon && ln -sf /dev/stdout /var/log/cron && ln -sf /dev/stdout /var/log/apache2/access.log && ln -sf /dev/stderr /var/log/apache2/error.log
ADD start-znuny.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start-znuny.sh && update-rc.d cron defaults
EXPOSE 80 443
CMD ["start-znuny.sh"]
