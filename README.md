# Znuny 6.2.2

### Criar imagem com a ultima versão
	docker build -t znuny:6.2.2 --build-arg VERSION=6.2.2 .

### Para rodar o container, digite:
	docker run -d --name znuny -p 80:80 -p 443:443 znuny:6.2.2

### Para atualizar a versão, copie o arquivo 'Config.pm' de dentro do container para um lugar no host.

	mkdir -p /opt/docker/znuny
	docker cp znuny:/opt/otrs/Kernel/Config.pm /opt/container/znuny/Config.pm

Se for apenas atualizar das versões 6.2.0 ou 6.2.2, adicione a variavel "-e ZNUNY_UPDATE=yes"

Para atualizar da versão 6.1, adicione a variavel "-e ZNUNY_UPGRADE=yes"

	docker run -d --name znuny -p 80:80 -p 443:443 -e ZNUNY_UPGRADE=yes \
	-v /opt/container/znuny/Config.pm:/opt/otrs/Kernel/Config.pm znuny:6.2.2

### Para criar o banco de dados, acesse o servidor e digite:
	CREATE DATABASE znuny CHARACTER SET = 'utf8' COLLATE = 'utf8_general_ci';
	GRANT ALL ON znuny.* TO 'znuny'@'%' IDENTIFIED BY 'znuny';

Adicione essas configurações no arquivo conf.d/znuny.cnf do banco de dados (MariaDB ou MySQL)

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
 
### Backup e Restore
Backup direto do banco de dados

	mysqldump -u znuny -pznuny --add-drop-database --databases znuny | gzip > /tmp/znuny.sql.gz

Para restaurar direto no banco de dados

	gunzip < znuny.sql.gz | mariadb -u znuny -pznuny

Criar uma rotina de backup full todos os dias as 5:00 da manhã e deletar os backup com mais de 8 dias.

Adicionar no crontab do container:

	05 05 * * * /opt/otrs/scripts/backup.pl -d /opt/backups/ -c gzip -r 8 -f fullbackup

### Opções de verificações
	su -c "/opt/otrs/bin/otrs.CheckModules.pl --all" -s /bin/bash otrs
	su -c "/opt/otrs/bin/otrs.Console.pl Maint::Config::Rebuild" -s /bin/bash otrs
	su -c "/opt/otrs/bin/otrs.Console.pl Admin::Package::UpgradeAll" -s /bin/bash otrs

### Configurar redirecionado de URL.
Criar um arquivo para as configurações

	vi /etc/apache2/sites-available/znuny.conf

Cole o conteúdo no arquivo

	<VirtualHost *:80>
	  ServerName helpdesk.local
	  DocumentRoot "/opt/otrs/bin/cgi-bin/"
	  Alias /otrs-web/ "/opt/otrs/var/httpd/htdocs/"
	  <Location "/otrs-web/">
	    SetHandler default-handler
	  </Location>
          <Directory "/opt/otrs/bin/cgi-bin">
	    AllowOverride None
	    Options +ExecCGI
	    Order allow,deny
	    Allow from all
	    ErrorDocument 403 /customer.pl
	    DirectoryIndex customer.pl
	    AddHandler  perl-script .pl .cgi
	    PerlResponseHandler ModPerl::Registry
	    PerlOptions +ParseHeaders
	    PerlOptions +SetupEnv
	    </Directory>
	</Virtualhost>

	<VirtualHost *:80>
	  ServerName suporte.local
	  DocumentRoot "/opt/otrs/bin/cgi-bin/"
	  Alias /otrs-web/ "/opt/otrs/var/httpd/htdocs/"
	  <Location "/otrs-web/">
	    SetHandler default-handler
	  </Location>
	  <Directory "/opt/otrs/bin/cgi-bin">
	    AllowOverride None
	    Options +ExecCGI
            Order allow,deny
            Allow from all
            ErrorDocument 403 /index.pl
            DirectoryIndex index.pl
            AddHandler  perl-script .pl .cgi
            PerlResponseHandler ModPerl::Registry
            PerlOptions +ParseHeaders
            PerlOptions +SetupEnv
          </Directory>
	</Virtualhost>

 Habilite o arquivo

 	a2ensite znuny
