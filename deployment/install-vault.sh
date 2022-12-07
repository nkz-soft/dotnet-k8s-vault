#!/usr/bin/env bash

VAULT_HOST=vault-0

set -Eeuo pipefail
trap clean_up SIGINT SIGTERM ERR EXIT

function clean_up {
  exit 0
}

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm upgrade -i --wait vault hashicorp/vault -n vault

kubectl exec $VAULT_HOST -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

export VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec $VAULT_HOST -n vault -- vault operator unseal $VAULT_UNSEAL_KEY

kubectl cp config-vault.sh $VAULT_HOST:/
kubectl exec $VAULT_HOST -- bash -c "chmod +x config-vault.sh && ./config-vault.sh"
