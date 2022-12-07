#!/usr/bin/env bash

set -Eeuo pipefail
trap clean_up SIGINT SIGTERM ERR EXIT

function clean_up {
  exit 0
}

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install vault hashicorp/vault -n vault
kubectl exec vault-0 -n vault -- vault status
kubectl exec vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

export VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY

: '
kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh

vault secrets enable -path=secrets kv-v2

vault kv put secrets/services/dotnet username='Bob' password='Bob_Password'

vault kv get secrets/services/dotnet

vault auth enable kubernetes

vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

vault policy write service - <<EOF
path "secrets" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/service \
        bound_service_account_names=* \
        bound_service_account_namespaces=* \
        policies=service \
        ttl=24h
'
