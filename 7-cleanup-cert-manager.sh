#!/bin/sh

oc delete -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.crds.yaml

oc delete project cert-manager

helm uninstall cert-manager
