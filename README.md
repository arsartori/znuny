# Znuny
This is the simple version of howto create a Znuny Docker Container.
Version: 6.0.37

## Build Docker Container
``
docker build -t znuny:6.0.37 . 
``

## Run
``
docker run -d --name znuny -p 80:80 -p 443:443 znuny:6.0.37
``
