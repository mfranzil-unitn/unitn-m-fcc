export KUBECONFIG="$HOME/.kube/kind-config-$USER"

#Get current context
kubectl config current-context

#Get clusters
kubectl config get-clusters

#Show configs
kubectl config view

#kubectl get <objtype>
kubectl get nodes
kubectl api-resources
kubectl get all
kubectl get pod

#Start pods
kubectl run --image=jpetazzo/clock clockpod
kubectl create deployment --image=jpetazzo/clock clockdep

#Scale the deployment to 5 replicas
kubectl scale deployment clockdep --replicas=5

#Execute command on pod
kubectl exec –it <POD_NAME> /bin/sh


