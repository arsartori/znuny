# Znuny
This is a simple way to create a Docker container with Znuny 6.0.36.

## Build container
``
docker build -t znuny:6.0.36
``

## Run container
``
docker run -d --name znuny -p 80:80 -p 443:443 znuny:6.0.36
``

## If upgrade from old version
### Backup **Config.pm** file
``
docker cp znuny:/opt/otrs/Kernel/Config.pm .
``

### Run with Config.pm and upgrade DB
``
docker run -d --name znuny -p 80:80 -p 443:443 -v Config.pm:/opt/otrs/Kernel/Config.pm znuny:6.0.36
``