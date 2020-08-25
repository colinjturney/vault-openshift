#!/bin/sh

# cat <<EOF | oc apply -f -
# apiVersion: cert-manager.io/v1alpha2
# kind: Certificate
# metadata:
#   name: cert-manager.colin.testing
#   namespace: vault-demo
# spec:
#   secretName: www.cert-manager.colin.testing
#   issuerRef:
#     name: vault-issuer
#   commonName: www.cert-manager.colin.testing
#   dnsNames:
#   - www.cert-manager.colin.testing
# EOF

oc apply -f configs/www-cert-manager-colin-testing.yaml
