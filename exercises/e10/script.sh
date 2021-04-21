# Create cluster
kind create cluster --name $USER

# Show context
kubectl cluster-info --context kubernetes-admin@$USER

# Export context
export CONTEXT=kubernetes-admin@$USER

kubectl run --image=jpetazzo/clock clock-test --context ${CONTEXT}
kubectl create deploy --image=nginx webserver-test --context ${CONTEXT}




