#!/bin/sh

eval $(crc oc-env)

# Apply cert-manager demo configurations

oc apply -f configs/www-cert-manager-colin-testing.yaml
