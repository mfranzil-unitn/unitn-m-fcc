kubectl get rs -o json | jq '.items | .[] | .metadata.name'
