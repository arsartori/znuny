# Znuny 6.5

### Criar imagem usando o Docker Build
	docker build -t znuny:6.5.10 --build-arg VERSION=6.5.10 .

### Para rodar o container, digite:
	docker run -d --name znuny -p 80:80 -p 443:443 znuny:6.5.10

### Para atualizar a versão, copie o arquivo 'Config.pm' de dentro do container para uma pasta no host.
	mkdir -p /opt/docker/znuny
	docker cp znuny:/opt/otrs/Kernel/Config.pm /opt/container/znuny/Config.pm

#### Para atualizar as versões 6.4.x, adicione a variavel "-e ZNUNY_UPDATE=yes"

#### Para atualizar da versão 6.3.x, adicione a variavel "-e ZNUNY_UPGRADE=yes"

	docker run -d --name znuny -p 80:80 -p 443:443 -e ZNUNY_UPGRADE=yes \
	-v /opt/container/znuny/Config.pm:/opt/otrs/Kernel/Config.pm znuny:6.5.10

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

#### Para restaurar direto no banco de dados

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


### Autenticação de Atendentes
$Self->{'AuthModule1'} = 'Kernel::System::Auth::LDAP';
$Self->{'AuthModule::LDAP::Host1'} = 'ldapserver';
$Self->{'AuthModule::LDAP::BaseDN1'} = 'DC=server,DC=local';
$Self->{'AuthModule::LDAP::UID1'} = 'sAMAccountName';
$Self->{'AuthModule::LDAP::GroupDN1'} = 'CN=Atendentes,OU=Groups,DC=server,DC=local';
$Self->{'AuthModule::LDAP::AccessAttr1'} = 'member';
$Self->{'AuthModule::LDAP::SearchUserDN1'} = 'CN=znuny,CN=Users,DC=server,DC=local';
$Self->{'AuthModule::LDAP::SearchUserPw1'} = 'senha';

### Sincronização de Atendentes
$Self->{'AuthSyncModule'} = 'Kernel::System::Auth::Sync::LDAP';
$Self->{'AuthSyncModule::LDAP::UserAttr'} = 'DN';
$Self->{'AuthModule::LDAP::UserAttr'} = 'DN';
$Self->{'AuthSyncModule::LDAP::Host'} = 'ldapserver';
$Self->{'AuthSyncModule::LDAP::BaseDN'} = 'DC=server,DC=local';
$Self->{'AuthSyncModule::LDAP::UID'} = 'sAMAccountName';
$Self->{'AuthSyncModule::LDAP::SearchUserDN'} = 'CN=znuny,CN=Users,DC=server,DC=local';
$Self->{'AuthSyncModule::LDAP::SearchUserPw'} = 'senha';
$Self->{'AuthSyncModule::LDAP::UserSyncMap'} = {
	UserFirstname => 'givenName',
	UserLastname => 'sn',
	UserEmail => 'mail',
	UserCargo => 'description',
	UserPhoneNumber => 'telephoneNumber',
};
$Self->{'AuthSyncModule::LDAP::AccessAttr'} = 'member';
$Self->{'AuthSyncModule::LDAP::UserSyncInitialGroups'} = [
	'users',
];

### Relacionar grupos com papéis do OTRS
$Self->{'AuthSyncModule::LDAP::UserSyncRolesDefinition'} = {
	'CN=Administradores OTRS,OU=OTRS Groups,DC=complemento,DC=net,DC=br' => {
		'Administrador' => 1,
	},
	'CN=Service Desk,OU=OTRS Groups,DC=complemento,DC=net,DC=br' => {
		'Atendente de Primeiro Nível' => 1,
	},
	'CN=Desenvolvedores,OU=OTRS Groups,DC=complemento,DC=net,DC=br' => {
		'Desenvolvedor' => 1,
	},
};

### Autenticação de Clientes
$Self->{'Customer::AuthModule1'} = 'Kernel::System::CustomerAuth::LDAP';
$Self->{'Customer::AuthModule::LDAP::Host1'} = 'ldapserver';
$Self->{'Customer::AuthModule::LDAP::BaseDN1'} = 'DC=server,DC=local';
$Self->{'Customer::AuthModule::LDAP::UID1'} = 'sAMAccountName';
$Self->{'Customer::AuthModule::LDAP::GroupDN1'} = 'CN=Clientes,OU=Groups,DC=server,DC=local';
$Self->{'Customer::AuthModule::LDAP::AccessAttr1'} = 'member';
$Self->{'Customer::AuthModule::LDAP::SearchUserDN1'} = 'CN=znuny,CN=Users,DC=server,DC=local';
$Self->{'Customer::AuthModule::LDAP::SearchUserPw1'} = 'senha';
$Self->{'Customer::AuthModule::LDAP::AlwaysFilter1'} =
'(&(objectclass=user)(!(objectclass=computer))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))';
# $Self->{'Customer::AuthModule::LDAP::Die1'} = 0;

### Sincronização de clientes
$Self->{CustomerUser1} = {
	Name => 'Active Directory Complemento',
	Module => 'Kernel::System::CustomerUser::LDAP',
	Params => {
		Host => '192.168.30.50',
		BaseDN => 'DC=complemento,DC=net,DC=br',
		SSCOPE => 'sub',
		UserDN => 'CN=otrs,CN=Users,DC=complemento,DC=net,DC=br',
		UserPw => 'Brasil123!',
		AlwaysFilter => '(&(objectclass=user)(!(objectclass=computer))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))',
		SourceCharset => 'utf-8',
		DestCharset => 'utf-8',
		Params => {
		port => 389,
		timeout => 120,
		async => 0,
		version => 3,
	},
},
CustomerKey => 'sAMAccountName',
CustomerID => 'mail',
CustomerUserListFields => ['cn','mail'],
CustomerUserSearchFields => ['sAMAccountName', 'cn', 'mail','givenname', 'sn'],
CustomerUserSearchPrefix => '*',
CustomerUserSearchSuffix => '*',
CustomerUserSearchListLimit => 500,
CustomerUserPostMasterSearchFields => ['mail'],
CustomerUserNameFields => ['givenname', 'sn'],
CustomerUserEmailUniqCheck => 0,
CustomerUserExcludePrimaryCustomerID => 0,
AdminSetPreferences => 0,
ReadOnly => 1,
CacheTTL => 180,
Map => [
	# var, frontend, storage, shown (1=always,2=lite), required, storage-type, http-link, readonly
	[ 'UserTitle', 'Title', 'title', 1, 0, 'var', '', 0 ],
	[ 'UserFirstname', 'Firstname', 'givenname', 1, 1, 'var', '', 0 ],
	[ 'UserLastname', 'Lastname', 'sn', 1, 1, 'var', '', 0 ],
	[ 'UserLogin', 'Username', 'sAMAccountName', 1, 1, 'var', '', 0 ],
	[ 'UserEmail', 'Email', 'mail', 1, 1, 'var', '', 0 ],
	[ 'UserCustomerID', 'CustomerID', 'sAMAccountName', 0, 1, 'var', '', 0 ],
	[ 'UserPhone', 'Phone', 'telephonenumber', 1, 0, 'var', '', 0 ],
	[ 'UserAddress', 'Address', 'postaladdress', 1, 0, 'var', '', 0 ],
	[ 'UserComment', 'Comment', 'dn', 1, 0, 'var', '', 0 ],
	[ 'DN', 'DN', 'dn', 1, 0, 'var', '', 0 ],
	],
};
