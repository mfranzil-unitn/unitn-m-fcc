#!/bin/bash
# (invoke local env) . ../local-env.sh
if [ -z "$ENV_SET" ]; then
   echo "Please run local-env.sh";
   exit;
fi

scp ${LOGIN}@${PAAS_HOST}:{~/.profile,~/.bash_logout} ./
cp .profile .profile_old
cp .bash_logout .bash_logout_old
echo "source paas-env.sh; source local-docker-env.sh" >> .profile
echo "rm paas-env.sh; rm local-docker-env.sh; mv .profile_old .profile; mv .bash_logout_old .bash_logout" >> .bash_logout
scp {paas-env.sh,../local-docker-env.sh,.profile,.profile_old,.bash_logout,.bash_logout_old} ${LOGIN}@${PAAS_HOST}:~/;

if [[ $1 == "--socks" ]] ; then
    ssh -D localhost:${SOCKS_PORT} ${LOGIN}@${PAAS_HOST} 
else
    ssh ${LOGIN}@${PAAS_HOST}
fi

rm .profile .profile_old .bash_logout .bash_logout_old
