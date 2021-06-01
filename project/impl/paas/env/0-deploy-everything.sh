# Certificates
docker cp /etc/docker/certs.d/***REMOVED***\:8081/ca.crt $(docker ps --filter NAME=eval-control-plane -q):/usr/local/share/ca-certificates/ca.crt;
docker exec -it $(docker ps --filter NAME=eval-control-plane -q) /bin/bash update-ca-certificates;
sudo systemctl daemon-reload;
sudo systemctl restart docker;
# NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml;
kubectl label node ${CLUSTER_NAME}-control-plane ingress-ready=true;
kubectl wait --namespace ingress-nginx \
--for=condition=ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=30s;
# Namespace
kubectl create namespace centodiciotto-dev;
# Secrets
kubectl apply -f sql/secret-sql-cred.yml;
kubectl apply -f secret-docker-cred.yml;
# SQL Server
kubectl apply -f sql/sql-server-pv.yml;
kubectl apply -f sql/sql-server-deployment.yml;
## Web Server
kubectl apply -f ws/web-server-deployment.yml;
kubectl apply -f ws/web-server-ingress.yml;
