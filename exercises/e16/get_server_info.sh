export SERVER_NAME=`kubectl get pod -l app=server -o jsonpath='{.items[0].metadata.name}'`
export SERVER_IP=`kubectl get pod -l app=server -o jsonpath='{.items[0].status.podIP}'`
export SERVER_NODE=`kubectl get pod -l app=server -o jsonpath='{.items[0].spec.nodeName}'`
echo "My server is $SERVER_NAME. It has IP: $SERVER_IP and runs on worker node $SERVER_NODE"
