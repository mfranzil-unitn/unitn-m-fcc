export IAAS_IP=REDACTED # local iaas ip
export PAAS_IP=REDACTED # local paas ip
export CLUSTER_NAME=REDACTED
export MASTER_IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CLUSTER_NAME"-control-plane)"