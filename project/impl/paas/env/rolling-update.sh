#!/bin/bash
CURRENT_VERSION=`kubectl get deployment.apps "$WS_IMAGE" -o=jsonpath='{$.spec.template.spec.containers[:1].image}' | sed "s;"$DOCKER_REG_IP":"$DOCKER_REG_PORT"/"$WS_IMAGE":;;"`
echo "Please insert the required version (current: ${CURRENT_VERSION}):"
read -r VERSION
kubectl get deployment.apps ${WS_IMAGE} -o yaml | sed "s;${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION};${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${VERSION};" | kubectl replace -f -;
kubectl get deployment.apps ${PSQL_IMAGE} -o yaml | sed "s;${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${SQL_IMAGE}:${CURRENT_VERSION};${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${SQL_IMAGE}:${VERSION};" | kubectl replace -f -;