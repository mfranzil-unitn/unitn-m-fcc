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
        - Web Server Service/Deployment (10.96.60.130; ClusterIP 8080->80:30200/TCP; namespace default)
        - SQL Server Service/Deployment (10.96.60.230; NodePort 5432->5432:30100/TCP; namespace default)
        - NGINX Ingress (80/TCP; namespace ingress-nginx)

### Environment variables

The environment variables can be found in the respective files.

## Project details

### IAAS-19

#### Keystone, identity management

First, we need to authenticate against Keystone for accessing the resource servers. We run the `1_auth_token.sh` script.

This token must then be used in PUT requests (GET requests do not require authentication) towards the server.
Its duration is specified in the response payload (saved in response.txt).

#### Swift, resource server

The Resource server is provided by OpenStack directly using the Swift API. Its function is to provide a distributed data storage for the web application with a RESTful API. After being created, we inserted the required assets by our application.

```shell
curl ${RESOURCE_SERVER}/${RESOURCE} -i -X PUT -H "X-Auth-Token: ${TOKEN}" 
curl ${RESOURCE_SERVER}/ -i -X GET -H "X-Auth-Token: ${TOKEN}" 
```

#### Nova, compute instances: Docker Registry

Our OpenStack machine hosts a Docker Registry, which is nothing less than a Docker installation working as an endpoint for pushing images. We can SSH to it with user `debian` and the SSH key in the folder.

First, we need to set up tunneling for connecting from localhosts using the classic SOCKS method (make sure proxying is on). Then, we log in. This is automatically done by the `.env.iaas.sh` script.

We can now push stuff to the Docker Registry using its IP and port as repository prefix. Please use the provided script.

Docker Registry v2 has a good API. We can use it as following:

```shell
curl -v --silent -s -i --insecure -H "Content-Type: application/json; Accept: application/vnd.docker.distribution.manifest.v2+json" -u ${DOCKER_REG_USER}:${DOCKER_REG_PASSWORD} 
```

Possible targets:

```shell
-X GET https://***REMOVED***:8081/v2/_catalog
-X GET https://***REMOVED***:8081/v2/<image>/tags/list
-X DELETE https://***REMOVED***:8081/v2/<image>/manifests/<reference>
```

### PAAS-19

These are the ports used in the final config:

```shell
: ${WS_PORT_EXT:=30130} # Exposed port on the ingress
: ${WS_PORT_INT:=8080} # Internal tomcat port
: ${SQL_PORT_EXT:=30230} # Exposed port on the nodeport
: ${SQL_PORT_INT:=5432} # Internal PSQL port
```

#### Kubernetes cluster details

These commands apply the configuration and the Ingress.

For quick deletion of everything: see script in env folder.

For re-deploying everything: see script in env folder.

For rolling update, use the provided file in env folder.

#### Web server details

The first Dockerfile is a simple Tomcat (Java 16, 10.0.6) container on which the application is slapped onto. It can be found (along with the following one) at  [centodiciotto](https://github.com/mfranzil/centodiciotto).

The web server has been adapted from its previous version (tag `1.0.0`, released Jan 2020) by adding API calls to Keystone on OpenStack and RESTful calls to the resource server, along with minor bug fixes. Finally, the API was elevated to newer versions of Jakarta and Tomcat. This resulted in version `2.0.0`. On the other hand, version `2.0.1` added automated backoff for SQL connections.

The web server is available on IAAS-19 using the URL `http://***REMOVED***.mainpage.org/centodiciotto/` (no HTTPS). The url redirects to the PAAS-19 MASTER_IP variable.

#### SQL server details

The second Dockerfile is based on a PostgreSQL 13 image. Three files are required, one for creating the table structure, the other for the actual data, the third for counters. The second one is not on GitHub as it contains confidential data.

For connecting (external port due to NodePort redirection):

```shell
psql postgresql://${SQL_USER}:${SQL_PASSWORD}@${MASTER_IP}:30100/${SQL_DB}
```
