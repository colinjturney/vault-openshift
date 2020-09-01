#!/bin/sh

eval $(crc oc-env)

export VAULT_ADDR=http://127.0.0.1:8200
vault login root

# Configure policies for both Vault Agent and Cert Manager
vault policy write vault-agent-policy - <<EOF
path "secret/data/myapp/*" {
  capabilities = ["read", "list"]
}

path "pki/issue/vault-agent" {
  capabilities = ["create","update"]
}

EOF

vault policy write cert-manager-policy - <<EOF
path "pki*" {
  capabilities = ["read", "list"]
}

path "pki/roles/cert-manager" {
  capabilities = ["create", "update"]
}

path "pki/sign/cert-manager" {
  capabilities = ["create", "update"]
}

path "pki/issue/cert-manager" {
  capabilities = ["create"]
}

EOF

# Create some dummy test data on kv store
vault kv put secret/myapp/config username='appuser' \
        password='suP3rsec(et!' \
        ttl='30s'

# Get some things things we need from OpenShift to configure Vault Auth Methods

export VAULT_SA_NAME=$(oc get sa vault-auth -o json | jq -r '.secrets[] | select(.name|test(".token.")) | .name')
export SA_JWT_TOKEN=$(oc get secret $VAULT_SA_NAME \
    -o jsonpath="{.data.token}" | base64 --decode; echo)
export SA_CA_CRT=$(oc get secret $VAULT_SA_NAME \
    -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
export OPENSHIFT_HOST="kubernetes.default"

# Enable the Kubernetes Authentication Method
vault auth enable kubernetes

# Configure Kubernetes Authentication Method
vault write auth/kubernetes/config \
        token_reviewer_jwt="$SA_JWT_TOKEN" \
        kubernetes_host="https://$OPENSHIFT_HOST:6443" \
        kubernetes_ca_cert="$SA_CA_CRT"

# Configure roles for both vault-agent and cert-manager

vault write auth/kubernetes/role/vault-agent-auth \
        bound_service_account_names=vault-agent-auth \
        bound_service_account_namespaces=vault-demo \
        policies=vault-agent-policy \
        ttl=24h

vault write auth/kubernetes/role/cert-manager-auth \
        bound_service_account_names=cert-manager-auth \
        bound_service_account_namespaces=cert-manager \
        policies=cert-manager-policy \
        ttl=24h
