kubectl get deploy myclock -o json | jq -C .spec | cat -n
kubectl get deploy myclock -o json | jq -C .status | cat -n
