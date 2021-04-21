kubectl get pod -o json | jq '.items | .[] | .kind, .metadata.name, .metadata.ownerReferences'
