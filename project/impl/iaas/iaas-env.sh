#!/usr/bin/env bash
#grep -q "^source iaas-env.sh;" .profile && echo ".profile already updated" || echo "source iaas-env.sh" >> .profile
#grep -q "^rm iaas-env.sh && rm ssh-docker-reg.sh;" .bash_logout && echo ".bash_logout already updated" || echo "rm iaas-env.sh && rm ssh-docker-reg.sh;" >> .bash_logout
. ./***REMOVED***-openrc.sh
# OS_AUTH_URL = http://10.235.1.219/identity
# OS_USERNAME = admin
# OS_PASSWORD = password
# OS_PROJECT_NAME = ***REMOVED***
# OS_PROJECT_ID = 09709b84a64a4e3cbc903232a7bd145e
# OS_PROJECT_DOMAIN_ID = default
export IAAS_IP=10.235.1.219 # local iaas ip
export PAAS_IP=10.235.1.119 # local paas ip
export RESOURCE_SERVER=http://${IAAS_IP}:8080/v1/AUTH_${OS_PROJECT_ID}/resource-server
export IDENTITY_SERVER=${OS_AUTH_URL}/v3/auth/tokens
# For accessing NVMs
export EVAL_ACC=eval
export EVAL_PASSWORD=eval
# NVM Docker Reg
export DOCKER_REG_IP=***REMOVED***
export DOCKER_REG_KEY=.ssh/docker-reg-priv
if [ -f "$DOCKER_REG_KEY" ]; then
    echo "$DOCKER_REG_KEY exists, enabling access."
else 
    echo "$DOCKER_REG_KEY does not exist. Cannot access Docker Registry."
fi
echo "ssh debian@${DOCKER_REG_IP} -i .ssh/docker-reg-priv" > ssh-docker-reg.sh && chmod +x ssh-docker-reg.sh