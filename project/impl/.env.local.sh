#!/usr/bin/env bash
export LAB_DOMAIN=.fcc21.fogx.me # Our lab domain
export IAAS_PREFIX=iaas- # Our lab prefix
export PAAS_PREFIX=paas- # Our lab prefix
# asking for name
echo "Who are you? [matteo.franzil/claudio.facchinetti]: "
read -r NAME_INPUT
export NAME=$NAME_INPUT
export EMAIL=${NAME}@studenti.unitn.it  # Your unitn email as provided
export GROUP_NUM=19 # Your group number
export LOGIN="$(printf "%s" ${EMAIL} | sed -e 's/@.*$//')" # The login will be the local-part of your email address
# some more stuff
export IAAS_HOST="${IAAS_PREFIX}${GROUP_NUM}${LAB_DOMAIN}" # The host plus your group plus the course domain
export PAAS_HOST="${PAAS_PREFIX}${GROUP_NUM}${LAB_DOMAIN}"
# site names for completeness
#export IAAS_SITE=$(ssh ${LOGIN}@${IAAS_HOST} hostname) # iaas-19
#export PAAS_SITE=$(ssh ${LOGIN}@${PAAS_HOST} hostname) # paas-19
# Socks port
export SOCKS_PORT=8888