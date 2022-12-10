# dotnet-k8s-vault
Integration of .NET application with HashiCorp Vault server

## Prerequisites

- k8s cluster (something like minikube or k3s will also work)
- helm
- jg 

## Deploy Vault

To deploy and configure the Vault server:
```bash
cd dotnet-k8s-vault/deployment/
./install-vault.sh.
```

The Vault server will be created and configured in the cluster. 
There will also be created the necessary policies and access rights.

## Deploy test application

```bash
cd k8s/.helm/
helm install dotnet-vault .
```

You will see the created pod and you can check that everything worked.

```bash
export DOTNET_K8S_VAULT_PORT=$(kubectl get svc dotnet-vault -o json | jq -r ".spec.ports[].nodePort")
curl localhost:$DOTNET_K8S_VAULT_PORT/config
```

You should see something like that:
```bash
{"VaultSecrets":null,"VaultSecrets:userName":"Bob","VaultSecrets:password":"Bob_Password"}
```


