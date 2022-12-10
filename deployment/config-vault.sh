#!/bin/sh

vault login $1

vault secrets enable -path=secrets kv-v2

vault kv put secrets/services/dotnet username='Bob' password='Bob_Password'

vault kv get secrets/services/dotnet

vault auth enable kubernetes

vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

vault policy write service - <<EOF
path "secrets/data/services/dotnet" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/service \
        bound_service_account_names=* \
        bound_service_account_namespaces=* \
        policies=service \
        ttl=24h
