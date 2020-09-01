#!/bin/sh

eval $(crc oc-env)

# Apply vault-agent demo configurations

oc apply -f configs/www-vault-agent-colin-testing.yaml --namespace=vault-demo
