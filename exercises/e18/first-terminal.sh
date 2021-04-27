# Optional: decrease current workload
# kubectl delete deploy -l app!=lb-example

# Start watching workload
kubectl get pod -o wide -w
