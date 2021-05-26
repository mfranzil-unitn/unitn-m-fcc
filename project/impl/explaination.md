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
    - Cluster
      - Control Plane (172.18.0.1)
      - Worker Node (172.18.0.2)
        - Web Server Service/Deployment (10.96.60.130; ClusterIP 8080->80/TCP; namespace default)
        - SQL Server Service/Deployment (10.96.60.230; NodePort 5432->5432:30100/TCP; namespace default)
        - NGINX Ingress (80/TCP; namespace ingress-nginx)
  - Helm (project)

### Environment variables

The environment variables can be found in the respective files.

## Project details

### IAAS-19

#### Keystone, identity management

First, we need to authenticate against Keystone for accessing the resource servers. These are the snippets:

```shell
echo TOKEN: TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "${OS_USERNAME}",
          "domain": { "id": "${OS_PROJECT_DOMAIN_ID}" },
          "password": "${OS_PASSWORD}"
        }
      }
    },
    "scope": {
      "project": {
        "name": "${OS_PROJECT_NAME}",
        "domain": { "id": "${OS_PROJECT_DOMAIN_ID}" }
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

First, we need to set up tunneling for connecting from localhosts using the classic SOCKS method (make sure proxying is on). Then, we log in:

```shell
docker login ${DOCKER_REG_IP}:${DOCKER_REG_PORT} # provide ${DOCKER_REG_USER}, ${DOCKER_REG_PASSWORD}
```

We can now push stuff to the Docker Registry using its IP and port as repository prefix.

```shell
docker tag ${WS_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION:=a.b.c}
docker tag ${WS_IMAGE}:latest ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:latest
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:${CURRENT_VERSION}
docker push ${DOCKER_REG_IP}:${DOCKER_REG_PORT}/${WS_IMAGE}:latest
```

### PAAS-19

These are the ports used in the final config:

```shell
: ${WS_PORT_EXT:=80} # Exposed port on the ingress
: ${WS_PORT_INT:=8080} # Internal tomcat port
: ${SQL_PORT_EXT:=30100} # Exposed port on the nodeport
: ${SQL_PORT_INT:=5432} # Internal PSQL port
```

#### Kubernetes cluster details

These commands apply the configuration and the Ingress.

For quick deletion of everything:

```shell
kubectl delete deployment.apps ${WS_IMAGE}; kubectl delete deployment.apps ${SQL_IMAGE}; kubectl delete services ${WS_IMAGE}; kubectl delete services ${SQL_IMAGE}
```

For re-deploying everything

```shell
kubectl apply -f sql-server-deployment.yml; kubectl apply -f web-server-deployment;
```

For rolling update:

#### Web server details

The first Dockerfile is a simple Tomcat (Java 16, 10.0.6) container on which the application is slapped onto. It can be found (along with the following one) at  [centodiciotto](https://github.com/mfranzil/centodiciotto).

The web server has been adapted from its previous version (tag `1.0.0`, released Jan 2020) by adding API calls to Keystone on OpenStack and RESTful calls to the resource server, along with minor bug fixes. Finally, the API was elevated to newer versions of Jakarta and Tomcat. This resulted in version `2.0.0`. On the other hand, version `2.0.1` added automated backoff for SQL connections.

#### SQL server details

The second Dockerfile is based on a PostgreSQL 13 image. Three files are required, one for creating the table structure, the other for the actual data, the third for counters. The second one is not on GitHub as it contains confidential data.

For connecting (external port due to NodePort redirection):

```shell
psql postgresql://${SQL_USER}:${SQL_PASSWORD}@${MASTER_IP}:30100/${SQL_DB}
```
