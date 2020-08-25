#!/bin/sh

export VAULT_ADDR=http://127.0.0.1:8200
export EXTERNAL_VAULT_ADDR=http://$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1):8200

vault login root

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760h pki

vault write pki/root/generate/internal \
  common_name=colin.testing \
  ttl=8760h

vault write pki/config/urls \
  issuing_certificates="${EXTERNAL_VAULT_ADDR}/v1/pki/ca" \
  crl_distribution_points="${EXTERNAL_VAULT_ADDR}/v1/pki/crl"

vault write pki/roles/vault-agent \
  allowed_domains=*.vault-agent.colin.testing \
  allow_subdomains=true \
  allow_glob_domains=true \
  max_ttl=5m

vault write pki/roles/cert-manager \
  allowed_domains=*.cert-manager.colin.testing \
  allow_subdomains=true \
  allow_glob_domains=true \
  require_cn=false \
  max_ttl=5m
