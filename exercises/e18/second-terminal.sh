export KUBECONFIG="$(kind get kubeconfig-path --name=$USER)"
kubectl scale deploy lb-example --replicas=6
kubectl describe service lb-example
kubectl describe service lb-example-random

# Grab master IP
MASTER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $USER-control-plane`
echo "My cluster is available from outside world sugin its master node IP, which is $MASTER_IP"

# Query the load balancer
while true; do curl -m1 http://$MASTER_IP:30000; sleep 1; done
kubectl get deploy lb-example -o yaml | sed 's/replicas: 6/replicas: 1/g' | kubectl replace -f -

# Optional: re-increase
# kubectl get deploy lb-example -o yaml | sed 's/replicas: 1/replicas: 6/g' | kubectl replace -f -
