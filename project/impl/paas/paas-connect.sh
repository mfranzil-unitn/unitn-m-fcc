#!/bin/bash
if [ -z "$ENV_SET" ]; then
   echo "Please run .env.local.sh";
   exit;
fi

scp ${LOGIN}@${PAAS_HOST}:~/.profile ./

if grep -q "source env/.env.paas.sh; source env/.env.docker.sh" .profile; then
    echo "Environment ready, connecting..."    
else
    cp .profile .profile_old
    echo "source env/.env.paas.sh; source env/.env.docker.sh" >> .profile
    echo "Updating .profile file for new environment..."
    scp .profile ${LOGIN}@${PAAS_HOST}:~/
fi

rm .profile

ssh ${LOGIN}@${PAAS_HOST} "rm -rf ~/env && mkdir -p ~/env"

scp -r env/ ${LOGIN}@${PAAS_HOST}:~/;

if [[ $1 == "--socks" ]] ; then
    ssh -D localhost:${SOCKS_PORT} ${LOGIN}@${PAAS_HOST} 
else
    ssh ${LOGIN}@${PAAS_HOST}
fi