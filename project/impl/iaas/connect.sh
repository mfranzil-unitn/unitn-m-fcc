#!/bin/bash
# (invoke local env) . ../local-env.sh
if [ -z "$ENV_SET" ]; then
   echo "Please run local-env.sh";
   exit;
fi

scp ${LOGIN}@${IAAS_HOST}:{~/.profile,~/.bash_logout} ./
cp .profile .profile_old
cp .bash_logout .bash_logout_old
echo "source iaas-env.sh;" >> .profile
echo "rm iaas-env.sh; rm ssh-docker-reg.sh; mv .profile_old .profile; mv .bash_logout_old .bash_logout" >> .bash_logout
scp {iaas-env.sh,.profile,.profile_old,.bash_logout,.bash_logout_old} ${LOGIN}@${IAAS_HOST}:~/;

if [[ $1 == "--socks" ]] ; then
    ssh -D localhost:${SOCKS_PORT} ${LOGIN}@${IAAS_HOST} 
else
    ssh ${LOGIN}@${IAAS_HOST}
fi

rm .profile .profile_old .bash_logout .bash_logout_old
