#!/bin/sh

oc delete -f configs/vault-service-accounts.yaml
oc delete -f configs/www-vault-agent-colin-testing.yaml

helm uninstall vault

oc delete project vault-demo
