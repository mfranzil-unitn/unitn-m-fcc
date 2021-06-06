#!/bin/bash
source .env.local.sh
source .env.docker.sh

while true; do
    echo "Connect to [paas/iaas]: "
    read -r INPUT
    export TARGET=$INPUT

    if [[ "$TARGET" == "paas" ]]; then
        HOST=$PAAS_HOST    
    elif [[ "$TARGET" == "iaas" ]]; then
        HOST=$IAAS_HOST
    else
        echo "Please insert [paas/iaas]."
        continue
    fi

    cd $TARGET

    echo "[1/4] Pulling user profile..."
    scp ${LOGIN}@${HOST}:~/.profile ./

    if grep -q "source env/.env.docker.sh; source env/.env.$TARGET.sh" .profile; then
        echo "[2a/4] Profile ready..."    
    else
        cp .profile .profile_old
        echo "source env/.env.docker.sh; source env/.env.$TARGET.sh" >> .profile
        echo "[2b/4] Updating file for new profile..."
        scp .profile ${LOGIN}@${HOST}:~/
    fi

    rm -f .profile .profile_old

    echo "[3/4] Uploading env folder..."
    ssh ${LOGIN}@${HOST} "rm -rf ~/env && mkdir -p ~/env"
    scp -r env/ ${LOGIN}@${HOST}:~/;

    if [[ $1 == "--socks" ]] ; then
        echo "[4a/4] Connecting with SOCKSv5 proxy!"
        ssh -D localhost:${SOCKS_PORT} ${LOGIN}@${HOST} 
    else
        echo "[4b/4] Connecting!"
        ssh ${LOGIN}@${HOST}
    fi

    cd ..
    echo "Done!"

done