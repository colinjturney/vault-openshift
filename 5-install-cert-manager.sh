#!/bin/sh

# Install Jetstack's cert-manager 0.14.3 resources
oc apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.crds.yaml

# Create a namespace for cert-manager
oc new-project cert-manager --description="Cert Manager" --display-name="cert-manager"

# Add Jetstack chart repository
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager \
  --namespace cert-manager \
  --version 0.14.3 \
  jetstack/cert-manager

oc create serviceaccount cert-manager-auth

sleep 10

# If script fails at this point, might need to give it a minute or so before running this below again
# Will be waiting a while for the cert-manager-webhook pod to be running.

export ISSUER_SECRET_REF=$(oc get serviceaccount cert-manager-auth -o json | jq -r '.secrets[] | select(.name|test(".token.")) | .name')
export EXTERNAL_VAULT_ADDR=http://$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1):8200

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: vault-issuer
  namespace: cert-manager
spec:
  vault:
    server: ${EXTERNAL_VAULT_ADDR}
    path: pki/sign/cert-manager
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: cert-manager-auth
        secretRef:
          name: ${ISSUER_SECRET_REF}
          key: token
EOF
