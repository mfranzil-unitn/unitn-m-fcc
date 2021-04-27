# Delete previous single-node cluster to save resources
# kind delete cluster --name $USER

# Optional: inspect manifest
# cat kind-multi-node.yaml | yq -C r - | cat -n
kind create cluster --config kind-multi-node.yaml --name $USER
export KUBECONFIG="$(kind get kubeconfig-path --name=$USER)"
kubectl cluster-info
kubectl get nodes