# Certificates $(docker ps --filter NAME=eval-control-plane -q)
docker cp /etc/docker/certs.d/REDACTED\:8081/ca.crt eval-control-plane:/usr/local/share/ca-certificates/ca.crt;
docker exec -it eval-control-plane /bin/bash update-ca-certificates;
sudo systemctl daemon-reload;
sudo systemctl restart docker;