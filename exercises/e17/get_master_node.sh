MASTER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $USER-control-plane`
echo "My cluster is available from outside world using its master node IP, which is $MASTER_IP"


