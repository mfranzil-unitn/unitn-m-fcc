# FCC-21 Project Implementation

## Main changes from the draft

- At the end, no DNS server was implemented since no substantial benefits would have been derived from it
- We decided to go forward with the docker registry implementation: we didn't want to put our application public in Docker Hub (since a paid subscription is required for managing multiple private repositories)

## Preliminaries

The project is composed of the following structure:

- IAAS-19 machine (10.235.11.219; SSH@22)
  - OpenStack (adm. panel. HTTP@80)
    - Keystone, identity management (see below)
    - Swift, resource server (HTTP@8080)
    - Nova, compute instances
      - Docker Registry (...)
- PAAS-19 machine (10.235.11.119; SSH@22)
  - Docker (CLI only)
  - Kubernetes (CLI only)
    - fcc21-control-plane cluster
      - Control Plane (172.18.0.1)
      - Worker Node (172.18.0.2)
        - Web Server Service/Deployment (10.96.60.130; 8080->80/TCP; namespace default)
        - SQL Server Service/Deployment (10.96.60.230; 5432->5432:30100/TCP; namespace default)
        - NGINX Ingress (80/TCP; namespace ingress-nginx)
  - Helm (project)

### Environment variables

The following are useful environment variables shared in all the project:

```shell
echo IAAS_IP: ${IAAS_IP:=10.235.1.219}
echo PAAS_IP: ${PAAS_IP:=10.235.1.119}

echo WS_PORT: ${WS_PORT:=80}
echo SQL_PORT: ${SQL_PORT:=5432}

echo SQL_USER: ${SQL_USER:=sqldiciotto}
echo SQL_PASSWORD: ${SQL_PASSWORD:=2bhturifjnbgtru8ei2938euj}

MASTER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' fcc21-control-plane`
```

### Credentials

On remote (IAAS/PAAS):

```shell
useradd -m -d /home/eval -s /bin/bash eval
mkdir /home/eval/.ssh/
```

```shell
cat /etc/passwd
```

> ```shell
> eval:x:1004:1004:,,,:/home/eval:/bin/bash
> ```

On local:

```shell
ssh-keygen -t rsa -b 4096 -C "FCC21-group19 eval key" -f "eval"
cat eval.pub  | ssh matteo.franzil@paas-19.fcc21.fogx.me “sudo tee -a /home/eval/.ssh/authorized_keys”
```

```shell
openstack user create --project fcc21 --password eval eval
openstack role add --user eval --project fcc21 reader
```

eval-fcc21-group19

                        per il cluster PAAS



== DOCKER IMAGE DETAILS ===================

The first Dockerfile is a simple Tomcat (Java 16, 10.0.6) container on which the application is slapped onto.

The second Dockerfile is based on a PostgreSQL 13 image. Three files are required, one for creating the table structure, the other for the actual data, the third for counters. The second one is not on GitHub as it contains confidential data.

They can be tested on the fly with this deployments:

docker run -d -e "POSTGRES_PASSWORD=${SQL_PASSWORD} POSTGRES_USER=${SQL_USER}"  
        -p ${SQL_PORT}:${SQL_PORT} --name sql mfranzil/centodiciotto-psql:2.0.1

docker run -d -p ${WS_PORT}:8080 --name c18 mfranzil/centodiciotto:2.0.0

Commands for deploying new images:

docker tag centodiciotto:latest mfranzil/centodiciotto:2.0.0
docker push mfranzil/centodiciotto:2.0.0

== CLUSTER DETAILS ========================

kubectl apply -f db-cred.yml
kubectl apply -f sql-server-pv.yml 
kubectl apply -f sql-server-deployment.yml 

(wait 10 seconds)

kubectl apply -f web-server-deployment.yml 
kubectl apply -f web-server-ingress.yml 

For quick deletion:

kubectl delete deployment.apps centodiciotto-ws; kubectl delete deployment.apps centodiciotto-psql; kubectl delete services centodiciotto-ws; kubectl delete services centodiciotto-psql

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

kubectl label node fcc21-control-plane ingress-ready=true

kubectl wait --namespace ingress-nginx \
--for=condition=ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=30s

== WEB-SERVER =============================

The web server has been adapted 
[...]

== SQL-SERVER =============================

psql postgresql://${SQL_USER}:${SQL_PASSWORD}@${MASTER_IP}:5432/postgres

== DOCKER REGISTRY ========================

== RESOURCE SERVER (Swift) ================

The Resource server requires the insertion of the assets folder, not on GitHub (since it's a very large binary one).
Its contents strictly depend on the contents of the database.

echo ADMIN_TOKEN: ${ADMIN_TOKEN:=AUTH_09709b84a64a4e3cbc903232a7bd145e}
echo RESOURCE_SERVER: ${RESOURCE_SERVER:=http://${IAAS_IP}:8080/v1/${ADMIN_TOKEN}/resource-server}
echo IDENTITY_SERVER: ${IDENTITY_SERVER:=http://${IAAS_IP}/identity/v3/auth/tokens}

echo PROJECT_REST_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "admin",
          "domain": { "id": "default" },
          "password": "password"
        }
      }
    },
    "scope": {
      "project": {
        "name": "fcc21",
        "domain": { "id": "default" }
      }
    }
  }
}' "${IDENTITY_SERVER}" | tee response.txt | grep X-Subject-Token | sed "s/X-Subject-Token: //")

This token must then be used in PUT requests (GET requests do not require authentication) towards the server. 
Its duration is specified in the response payload (saved in response.txt).

curl ${RESOURCE_SERVER}/${RESOURCE} -i -X PUT -H "X-Auth-Token: ${PROJECT_REST_TOKEN}" 

# Dockerfiles

The web server and SQL server's Dockerfile can be found at this repo: [centodiciotto](https://github.com/mfranzil/centodiciotto)

