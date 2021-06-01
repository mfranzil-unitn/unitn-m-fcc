kubectl delete namespace centodiciotto-dev;
kubectl delete pv centodiciotto-psql-pv-volume;
kubectl delete namespace ingress-nginx;
docker exec eval-control-plane /bin/rm -rf /mnt/data/;