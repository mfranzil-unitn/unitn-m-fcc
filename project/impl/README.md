# FCC-21 Project Implementation

## Main changes from the draft

- At the end, no DNS server was implemented since no substantial benefits would have been derived from it
- We decided to go forward with the docker registry implementation: we didn't want to put our application public in Docker Hub (since a paid subscription is required for managing multiple private repositories)

## Preliminaries

The project is composed of the following structure:

- IAAS-19 machine (***REMOVED***; SSH@22)
  - OpenStack (adm. panel. HTTP@80)
    - Keystone, identity management (see below)
    - Swift, resource server (HTTP@8080)
    - Nova, compute instances
      - Docker Registry (***REMOVED***; Docker@8081)
- PAAS-19 machine (***REMOVED***; SSH@22)
  - Docker (CLI only)
  - Kubernetes (CLI only)
    - ***REMOVED***-control-plane cluster
      - Control Plane (172.18.0.1)
      - Worker Node (172.18.0.2)
        - Web Server Service/Deployment (10.96.60.130; 8080->80/TCP; namespace default)
        - SQL Server Service/Deployment (10.96.60.230; 5432->5432:30100/TCP; namespace default)
        - NGINX Ingress (80/TCP; namespace ingress-nginx)
  - Helm (project)

### Environment variables

The following are environment variables shared in all the project:

```shell
: ${LAB_DOMAIN:=.***REMOVED***.fogx.me}  # Our lab domain
: ${IAAS_PREFIX:=iaas-}  # Our lab prefix
: ${PAAS_PREFIX:=paas-}  # Our lab prefix

: ${EMAIL:=matteo.franzil@***REMOVED***}  # Your unitn email as provided
: ${GROUP_NUM:=19}  # Your group number

LOGIN="$(printf "%s" ${EMAIL} | sed -e 's/@.*$//')" # The login will be the local-part of your email address

IAAS_HOST="${IAAS_PREFIX}${GROUP_NUM}${LAB_DOMAIN}" # The host plus your group plus the course domain
PAAS_HOST="${PAAS_PREFIX}${GROUP_NUM}${LAB_DOMAIN}"

IAAS_SITE=$(ssh ${LOGIN}@${IAAS_HOST} hostname) # iaas-19
PAAS_SITE=$(ssh ${LOGIN}@${PAAS_HOST} hostname) # paas-19

: ${EVAL_ACC:=eval}

: ${SOCKS_PORT:=8888}
```

For the remote hosts:

```shell
: ${IAAS_IP:=10.235.1.219} # local iaas ip
: ${PAAS_IP:=10.235.1.119} # local paas ip

# Keystone
: ${KEYSTONE_ACCESS_NAME:=admin}
: ${KEYSTONE_ACCESS_PASSWORD:=password}

# Swift
: ${ADMIN_TOKEN:=AUTH_09709b84a64a4e3cbc903232a7bd145e}
: ${RESOURCE_SERVER:=http://${IAAS_IP}:8080/v1/${ADMIN_TOKEN}/resource-server}
: ${IDENTITY_SERVER:=http://${IAAS_IP}/identity/v3/auth/tokens}

# Nova 
: ${DOCKER_REG_IP:=***REMOVED***}
: ${DOCKER_REG_PORT:=8081}

: ${WS_IMAGE:=centodiciotto-ws}
: ${SQL_IMAGE:=centodiciotto-psql}
: ${CURRENT_VERSION:=2.0.1}

: ${DOCKER_REG_USER:=***REMOVED***}
: ${DOCKER_REG_PASSWORD:=***REMOVED***}

: ${WS_PORT_EXT:=80}
: ${WS_PORT_INT:=8080}
: ${SQL_PORT_EXT:=30100}
: ${SQL_PORT_INT:=5432}

: ${SQL_USER:=***REMOVED***}
: ${SQL_PASSWORD:=***REMOVED***}
: ${SQL_DB:=postgres}

MASTER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ***REMOVED***-control-plane`
```

### Credentials

On remote (IAAS/PAAS):

```shell
useradd -m -d /home/${EVAL_ACC} -s /bin/bash ${EVAL_ACC}
mkdir /home/${EVAL_ACC}/.ssh/
```

```shell
cat /etc/passwd
```

> ```shell
> ${EVAL_ACC}:x:1004:1004:/home/${EVAL_ACC}:/bin/bash
> ```

On local:

```shell
ssh-keygen -t rsa -b 4096 -C "FCC21-group${GROUP_NUM} ${EVAL_ACC} key" -f "${EVAL_ACC}"
cat ${EVAL_ACC}.pub  | ssh ${LOGIN}@${PAAS_HOST} “sudo tee -a /home/${EVAL_ACC}/.ssh/authorized_keys”
```

Passphrase: ${EVAL_ACC}-***REMOVED***-group${GROUP_NUM}

```shell
openstack user create --project ***REMOVED*** --password ${EVAL_ACC} ${EVAL_ACC}
openstack role add --user ${EVAL_ACC} --project ***REMOVED*** reader
```

## Project details

### IAAS-19

#### Keystone, identity management

First, we need to authenticate against Keystone for accessing the resource servers. These are the snippets:

```shell
: application/json" -d '{ "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "${KEYSTONE_ACCESS_NAME}",
          "domain": { "id": "default" },
          "password": "${KEYSTONE_ACCESS_PASSWORD}"
        }
      }
    },
    "scope": {
      "project": {
        "name": "***REMOVED***",
        "domain": { "id": "default" }
      }
    }
  }
}' "${IDENTITY_SERVER}" | tee response.txt | grep X-Subject-Token | sed "s/X-Subject-Token: //")
```

This token must then be used in PUT requests (GET requests do not require authentication) towards the server.
Its duration is specified in the response payload (saved in response.txt).

#### Swift, resource server

The Resource server is provided by OpenStack directly using the Swift API. Its function is to provide a distributed data storage for the web application with a RESTful API. After being created, we inserted the required assets by our application.

```shell
curl ${RESOURCE_SERVER}/${RESOURCE} -i -X PUT -H "X-Auth-Token: ${PROJECT_REST_TOKEN}" 
```

#### Nova, compute instances: Docker Registry

Our OpenStack machine hosts a Docker Registry, which is nothing less than a Docker installation working as an endpoint for pushing images. We can SSH to it with user `debian` and the SSH key in the folder.

First, we need to set up tunneling for connecting from localhosts using the classic SOCKS method. Then, we log in:

```shell
docker login ${DOCKER_REG_IP}:${DOCKER_REG_PORT} # provide ${DOCKER_REG_USER}, ${DOCKER_REG_PASSWORD}
```

On Windows machines, we need to edit the proxy settings on Docker Desktop and add under the Resources > Proxies > HTTP Proxy `socks5://127.0.0.1:${SOCKS_PORT}`. On Linux machines, we append the following lines to the `/etc/systemd/system/docker.service.d/http-proxy.conf`
 file:

```shell
[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:${SOCKS_PORT}"
```

Finally, on the `dockerd` file we add:

```shell
"insecure-registries": [
  "${DOCKER_REG_IP}:8081"
]
```

Then, we push our stuff:

```shell
docker tag ${WS_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION:=a.b.c}
docker tag ${WS_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:latest
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION}
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:latest
```

### PAAS-19

#### Kubernetes cluster details

These commands apply the configuration and the Ingress.

```shell
kubectl apply -f db-cred.yml
kubectl apply -f sql-server-pv.yml 
kubectl apply -f sql-server-deployment.yml 
```

(wait 10 seconds)

```shell
kubectl apply -f web-server-deployment.yml 
kubectl apply -f web-server-ingress.yml 
```

For quick deletion of everything:

```shell
kubectl delete deployment.apps ${WS_IMAGE}; kubectl delete deployment.apps ${SQL_IMAGE}; kubectl delete services ${WS_IMAGE}; kubectl delete services ${SQL_IMAGE}
```

For installing the ingress:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
kubectl label node ***REMOVED***-control-plane ingress-ready=true
kubectl wait --namespace ingress-nginx \
--for=condition=ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=30s
```

#### Web server details

The first Dockerfile is a simple Tomcat (Java 16, 10.0.6) container on which the application is slapped onto. It can be found (along with the following one) at  [centodiciotto](https://github.com/mfranzil/centodiciotto).

The web server has been adapted from its previous version (tag `1.0.0`, released Jan 2020) by adding API calls to Keystone on OpenStack and RESTful calls to the resource server, along with minor bug fixes. Finally, the API was elevated to newer versions of Jakarta and Tomcat. This resulted in version `2.0.0`. On the other hand, version `2.0.1` added automated backoff for SQL connections.

Testing the image with Docker:

```shell
docker run -d -p ${WS_PORT_EXT}:${WS_PORT_INT} --name c18 ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION}
```

#### SQL server details

The second Dockerfile is based on a PostgreSQL 13 image. Three files are required, one for creating the table structure, the other for the actual data, the third for counters. The second one is not on GitHub as it contains confidential data.

It can be tested on the fly with this deployment (mapping internal port for now):

```shell
docker run -d -e "POSTGRES_PASSWORD=${SQL_PASSWORD} POSTGRES_USER=${SQL_USER}"  
        -p ${SQL_PORT_INT}:${SQL_PORT_INT} --name sql ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${SQL_IMAGE}:${CURRENT_VERSION}
```

For connecting (external port due to NodePort redirection):

```shell
psql postgresql://${SQL_USER}:${SQL_PASSWORD}@${MASTER_IP}:${SQL_PORT_EXT}/${SQL_DB}
```

 CREDENZIALI  per il cluster PAAS
credenzial per nvm eval
verificare funzionamento ingress
verificare tutta sta roba sopra
helm project