#!/bin/bash
# Inserting version
echo "Please insert the required version (current: ${CURRENT_VERSION:=none}):"
read -r VERSION
export CURRENT_VERSION=$VERSION
# Web Server
docker tag ${WS_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION};
docker tag ${WS_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:latest;
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION};
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:latest;
# SQL Server
docker tag ${SQL_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${SQL_IMAGE}:${CURRENT_VERSION};
docker tag ${SQL_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${SQL_IMAGE}:latest;
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${SQL_IMAGE}:${CURRENT_VERSION};
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${SQL_IMAGE}:latest;
