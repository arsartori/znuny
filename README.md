# Znuny
This is the first version I've used: 6.0.36

## Build Docker Container
docker build -t znuny:6.0.37 . 

## Run
``
docker run -d --name znuny -p 80:80 -p 443:443 znuny:6.0.37
``
