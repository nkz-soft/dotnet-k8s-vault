#!/bin/bash

VAULT_HOST=vault-0

set -Eeuo pipefail
trap clean_up SIGINT SIGTERM ERR EXIT

function clean_up {
  exit 0
}

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm upgrade -i vault hashicorp/vault --version 0.27.0 -n vault --create-namespace --wait

kubectl exec $VAULT_HOST -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

export VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
export VAULT_ROOT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")

kubectl exec $VAULT_HOST -n vault -- vault operator unseal $VAULT_UNSEAL_KEY

kubectl cp config-vault.sh $VAULT_HOST:/home/vault -n vault
kubectl exec $VAULT_HOST -n vault -- sh -c "cd /home/vault &&chmod +x config-vault.sh && sh config-vault.sh $VAULT_ROOT_TOKEN"
