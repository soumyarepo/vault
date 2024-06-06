# vault
this is vault tutorial classes







class2
az login
az ad sp create-for-rbac --name vaultlearing
change client_id    client_secret 
conect aks with azure cli
kubectl get nodes,pods,all,pvc
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault --set "server.dev.enabled=true"
nohup kubectl port-forward pod/vault-0 8200:8200 &> port-forward.log &
helm install vault hashicorp/vault --set='ui.enabled=true' --set='ui.serviceType=LoadBalancer'
then veryfiy from ui pvc bonding
copy the lb url :8200
kubectl exec -it vault-0 /bin/sh