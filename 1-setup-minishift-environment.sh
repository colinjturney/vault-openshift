#!/bin/sh

# Configure environment for use with CRC/OC
eval $(crc oc-env)

# Log in as the developer user. Use these credentials to access UI
oc login -u developer -p developer https://api.crc.testing:6443 --insecure-skip-tls-verify

# Apply admin policy to the developer user to get over RBAC controls for demo purposes
oc adm policy  --as system:admin add-cluster-role-to-user cluster-admin developer

# Create a new OpenShift namespace called vault-demo
oc new-project vault-demo --description="Vault Demo" --display-name="vault-demo"

# Get Vault Server IP
export EXTERNAL_VAULT_ADDR=http://$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1):8200
echo "EXTERNAL_VAULT_ADDR:${EXTERNAL_VAULT_ADDR}"

# Set up service accounts
oc create serviceaccount vault-auth
oc create serviceaccount vault-agent-auth
oc apply -f configs/vault-service-accounts.yaml

# Label namespace to ensure Vault agent webhook works
oc label namespace vault-demo vault.hashicorp.com/agent-webhook=enabled

# Deploy Vault Agent Injector
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault \
  --set "global.openshift=true" \
  --set "injector.externalVaultAddr=${EXTERNAL_VAULT_ADDR}"
