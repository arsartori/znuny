FROM ubuntu:24.04
LABEL maintainer="Andre Sartori <dev@aphtec.com.br>"

# 1. Configuração de fuso horário e instalação de pacotes em uma única camada limpa
RUN apt update && apt install -y --no-install-recommends \
    apache2 cpanminus libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl \
    libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl \
    libtext-csv-xs-perl libjson-xs-perl libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl \
    libyaml-perl libarchive-zip-perl libcrypt-eksblowfish-perl libencode-hanextra-perl \
    libmail-imapclient-perl libtemplate-perl libdatetime-perl libmoo-perl bash-completion \
    libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl libauthen-sasl-perl \
    libauthen-ntlm-perl libdata-uuid-perl libical-parser-perl wget cron && apt clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Download, instalação do Znuny e remoção do tar.gz residual imediatamente
RUN wget https://download.znuny.org/releases/znuny-latest-7.0.tar.gz -P /tmp && \
    tar xf /tmp/znuny-latest-7.0.tar.gz -C /opt && \
    rm /tmp/znuny-latest-7.0.tar.gz && \
    ln -s /opt/znuny-7.0* /opt/znuny && \
    cp /opt/znuny/Kernel/Config.pm.dist /opt/znuny/Kernel/Config.pm && \
    useradd -d /opt/znuny -c 'Znuny user' -g www-data -s /bin/bash -M -N znuny && \
    /opt/znuny/bin/znuny.SetPermissions.pl    

# 3. Configuração do Crontab do Znuny (Correção do comando "su")
RUN su - znuny && cd /opt/znuny/var/cron && \
    for foo in *.dist; do cp $foo `basename $foo .dist`; done && \
    sed -i 's/opt/znuny/g' /opt/znuny/var/cron/znuny_daemon

# 4. Configuração do Apache e redirecionamento de logs
RUN ln -s /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/znuny.conf && \
    sed -i 's/ScriptAlias\ \/znuny\//ScriptAlias\ \/znuny/g' /etc/apache2/conf-available/znuny.conf && \
    a2enmod perl headers deflate filter cgi && \
    a2dismod mpm_event && \
    a2enmod mpm_prefork  && \
    a2enconf znuny && \
    echo 'ServerName znuny' >> /etc/apache2/apache2.conf && \
    ln -sf /dev/stdout /var/log/cron && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

# 5. Script de inicialização
COPY start-znuny.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start-znuny.sh

EXPOSE 80 443
CMD ["start-znuny.sh"]