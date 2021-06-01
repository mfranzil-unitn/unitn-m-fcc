# Setting up recap

This is all stuff that needs to be done only once.

## Creating eval users

Please execute local-env.sh first on local and the corresponding envs on remote.

### Accounts on IAAS and PAAS

```shell
useradd -m -d /home/${EVAL_ACC} -s /bin/bash ${EVAL_ACC}
sudo usermod -a -G docker ${EVAL_ACC} # only on PAAS
mkdir /home/${EVAL_ACC}/.ssh/
```

```shell
cat /etc/passwd
```

> ```shell
> ${EVAL_ACC}:x:1004:1004:/home/${EVAL_ACC}:/bin/bash
> ```

### SSH key for local -> remote

On local: stash the private key in your PC, the public key in `/home/${EVAL_ACC}/.ssh/authorized_keys`.

```shell
ssh-keygen -t rsa -b 4096 -C "FCC21-group${GROUP_NUM} ${EVAL_ACC} key" -f "${EVAL_ACC}"
cat ${EVAL_ACC}.pub  | ssh ${LOGIN}@${PAAS_HOST} “sudo tee -a /home/${EVAL_ACC}/.ssh/authorized_keys”
```

Passphrase: ${EVAL_ACC}-***REMOVED***-group${GROUP_NUM}

### Providing SSH keys to the IAAS::eval user

Just do again the previous paragraph, stashing the private key in the (IAAS) evaluation user SSH folder and the public one in the NVM.

### Providing OpenStack access to the IAAS::eval user

We assume the presence of a project named ${OS_PROJECT_NAME}

```shell
openstack user create --project ${OS_PROJECT_NAME} --password ${EVAL_ACC} ${EVAL_PASS}
openstack role add --user ${EVAL_ACC} --project ${OS_PROJECT_NAME} reader
```

### Providing Kubernetes access to the PAAS::eval user

First, wipe any cluster present. Then:

```shell
kind create cluster ${CLUSTER_NAME}
ln -s /home/${EVAL_ACC}/.kube/config /home/${EVAL_ACC}/.kube/kind-config-${CLUSTER_NAME}
```

## Proxying to the Docker Registry

On Windows machines, we need to edit the proxy settings on Docker Desktop and add under the Resources > Proxies > HTTP Proxy `socks5://127.0.0.1:${SOCKS_PORT}`. On Linux machines, we append the following lines to the `/etc/systemd/system/docker.service.d/http-proxy.conf`
 file:

```shell
[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:${SOCKS_PORT}"
```

Finally, on the `dockerd` file we add:

```shell
"insecure-registries": [
  "${DOCKER_REG_IP}:${DOCKER_REG_PORT}"
]
```

## Installing the Kubernetes Ingress and Config

For applying everything once the cluster is up, use `0-deploy-everything.sh`

## Testing Docker images (on local)

Testing the image with Docker:

```shell
docker run -d -p 80:8080 --name c18 ${WS_IMAGE}:${CURRENT_VERSION}
```

```shell
docker run -d -e "POSTGRES_PASSWORD=${SQL_PASSWORD} POSTGRES_USER=${SQL_USER}"  
        -p 5432:5432 --name sql ${SQL_IMAGE}:${CURRENT_VERSION}
```

## Garbage collection of Docker Registry

Please do this to delete something from the Docker Registry:

```shell
rm -r <root>/v2/repositories/${name}/_manifests/tags/${tag}/index/sha256/${hash}
rm -r <root>/v2/repositories/${name}/_manifests/revisions/sha256/${hash}
```

```shell
docker exec registry bin/registry garbage-collect --dry-run /etc/docker/registry/config.yml
```
