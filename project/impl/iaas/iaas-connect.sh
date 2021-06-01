#!/bin/bash
if [ -z "$ENV_SET" ]; then
   echo "Please run .env.local.sh";
   exit;
fi

scp ${LOGIN}@${IAAS_HOST}:~/.profile ./

if grep -q "source env/.env.docker.sh; source env/.env.iaas.sh" .profile; then
    echo "Environment ready, connecting..."    
else
    cp .profile .profile_old
    echo "source env/.env.docker.sh; source env/.env.iaas.sh" >> .profile
    echo "Updating .profile file for new environment..."
    scp .profile ${LOGIN}@${IAAS_HOST}:~/
fi

rm .profile

ssh ${LOGIN}@${IAAS_HOST} "rm -rf ~/env && mkdir -p ~/env"

scp -r env/ ${LOGIN}@${IAAS_HOST}:~/;

if [[ $1 == "--socks" ]] ; then
    ssh -D localhost:${SOCKS_PORT} ${LOGIN}@${IAAS_HOST} 
else
    ssh ${LOGIN}@${IAAS_HOST}
fi