docker network create ex-network;
docker run --name backend --network ex-network -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:8.0;
docker run --name frontend --network ex-network -p4567:80 -d wordpress:5.7.1-apache;

