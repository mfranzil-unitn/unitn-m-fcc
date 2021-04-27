RANDOM_PORT=`kubectl get svc lb-example-random -o jsonpath='{.spec.ports[0].nodePort}'`
