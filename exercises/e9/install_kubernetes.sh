#Install kind
cd
wget https://github.com/kubernetes-sigs/kind/releases/download/v0.10.0/kind-linux-amd64
sudo mv kind-linux-amd64 /usr/local/bin/kind
sudo chmod a+x /usr/local/bin/kind

#Install KubeCTL
KC_REL=v1.20.0
curl -LO https://storage.googleapis.com/kubernetes-release/release/$KC_REL/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version

#Install completions
kubectl completion bash >> ~/.bashrc
source $HOME/.bashrc
