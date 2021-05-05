kubectl create deploy --image=jpetazzo/clock clock --replicas=5

kubectl get po -o json | jq -r '.items[] | .metadata.name' | head -n3 | xargs -I{} kubectl label pods {} com=frontend env=prod
kubectl get po -o json | jq -r '.items[] | .metadata.name' | tail -n2 | xargs -I{} kubectl label pods {} com=backend
kubectl get po -o json | jq -r '.items[] | .metadata.name' | tail -n1 | xargs -I{} kubectl label pods {} env=dev

kubectl get pod --show-labels
kubectl get po -l com=backend
kubectl get po -l com!=backend
kubectl get po -l env=prod,env=dev
kubectl get po -l 'env in (prod,dev)'

