kubectl get deploy myclock -o yaml | yq e -PC '.spec' - | cat -n
kubectl get deploy myclock -o yaml | yq e -PC '.status' - | cat -n
