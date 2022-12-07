#!/usr/bin/env bash

set -Eeuo pipefail
trap clean_up SIGINT SIGTERM ERR EXIT

function clean_up {
  exit 0
}

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm upgrade -i vault hashicorp/vault -n vault


kubectl exec vault-0 -n vault -- vault status
kubectl exec vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

export VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY

