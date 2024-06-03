# Znuny
This is a simple way to create a Docker container with Znuny.

## Build container
```
docker build --build-arg VERSION=<version> -t znuny:<version> .
```

## Run container
```
docker run -d --name znuny -p 80:80 -p 443:443 znuny:<version>
```

## Upgrade from old version
To upgrade from old version, you need backup the 'Config.pm' file and copy to local path.
Ex: /opt/container/znuny

### Backup Config.pm file
```
docker cp znuny:/opt/otrs/Kernel/Config.pm /opt/container/znuny/Config.pm
```

### Run with Config.pm and upgrade DB
```
docker run -d --name znuny -p 80:80 -p 443:443 -v /opt/container/znuny/Config.pm:/opt/otrs/Kernel/Config.pm znuny:<version>
```

## Create Database
```
CREATE DATABASE znuny CHARACTER SET = 'utf8' COLLATE = 'utf8_general_ci';
GRANT ALL ON znuny.* TO 'znuny'@'%' IDENTIFIED BY 'znuny';
```

Add this options to conf.d/znuny.cnf

```
[mysqld]
max_allowed_packet = 64MB
innodb_log_file_size = 256MB
```
