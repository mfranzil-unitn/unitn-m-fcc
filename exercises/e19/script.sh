kubectl get namespaces
kubectl get pod -n kube-system -o wide
kubectl get daemonset -n kube-system

MYNS=$(echo $USER | sed -e 's/\.//g')
kubectl create ns $MYNS;
kubectl run --image=jpetazzo/clock myclock -n $MYNS

kubectl get pod
kubectl get pod -n $MYNS
kubectl get pod --all-namespaces

