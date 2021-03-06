#!/usr/bin/env bash
#grep -q "^source iaas-env.sh;" .profile && echo ".profile already updated" || echo "source iaas-env.sh" >> .profile
#grep -q "^rm iaas-env.sh && rm ssh-docker-reg.sh;" .bash_logout && echo ".bash_logout already updated" || echo "rm iaas-env.sh && rm ssh-docker-reg.sh;" >> .bash_logout
. ./fcc21-openrc.sh
# OS_AUTH_URL = http://REDACTED/identity
# OS_USERNAME = REDACTED
# OS_PASSWORD = REDACTED
# OS_PROJECT_NAME = REDACTED
# OS_PROJECT_ID = REDACTED
# OS_PROJECT_DOMAIN_ID = REDACTED
export IAAS_IP=REDACTED # local iaas ip
export PAAS_IP=REDACTED # local paas ip
export RESOURCE_SERVER=http://${IAAS_IP}:8080/v1/AUTH_${OS_PROJECT_ID}/resource-server
export IDENTITY_SERVER=${OS_AUTH_URL}/v3/auth/tokens
# For accessing NVMs
export EVAL_ACC=REDACTED
export EVAL_PASSWORD=REDACTED
# NVM Docker Reg
export DOCKER_REG_KEY=.ssh/docker-reg-priv
if [ -f "$DOCKER_REG_KEY" ]; then
    echo "$DOCKER_REG_KEY exists, enabling access."
else 
    echo "$DOCKER_REG_KEY does not exist. Cannot access Docker Registry."
fi
echo "ssh debian@${DOCKER_REG_IP} -i .ssh/docker-reg-priv" > ssh-docker-reg.sh && chmod +x ssh-docker-reg.sh
docker login ${DOCKER_REG_IP}:${DOCKER_REG_PORT};