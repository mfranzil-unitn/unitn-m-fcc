kubectl taint node $SERVER_NODE node-role.kubernetes.io/master=value:NoSchedule
kubectl run --image=dsantoro/ubuntu --env="SERVER_IP=$SERVER_IP" client sleep infinity
export CLIENT_NAME=`kubectl get pod -l run=client -o jsonpath='{.items[0].metadata.name}'`
export CLIENT_IP=`kubectl get pod -l run=client -o jsonpath='{.items[0].status.podIP}'`
export CLIENT_NODE=`kubectl get pod -l run=client -o jsonpath='{.items[0].spec.nodeName}'`
echo "My client is $CLIENT_NAME. It has IP: $CLIENT_IP and runs on worker node $CLIENT_NODE"
