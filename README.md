# Znuny
This is a simple way to create a Docker container with Znuny version 6.0.37.

## Build container
``
docker build -t znuny:6.0.37 . 
``

## Run container
``
docker run -d --name znuny -p 80:80 -p 443:443 znuny:6.0.37
``
