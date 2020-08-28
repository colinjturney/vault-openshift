# Vault Openshift Demo
A demo showing a separately managed Vault server providing secrets management for
OpenShift. The demo shows how the Vault Agent Kubernetes Mutation Webhook Controller
can be used to inject a Vault Agent container into pods with appropriate annotations.

## Hardware Requirements:
Beware- CRC consumes a LOT of resources. At a casual glance, Hyperkit (upon which CRC is running), was at one time consuming approximately 21GB of memory. On my 2019 Macbook Pro with 16GB RAM, this caused a whole chunk of swap to be used too.

## Software Requirements
This demo was produced using the following software:
RedHat Code Ready Containers:
```
$ crc version
CodeReady Containers version: 1.14.0+36ad776
OpenShift version: 4.5.4 (embedded in binary)
```
HashiCorp Vault 1.4.2 (Note, Vault Enterprise not necessary for this demo):
```
$ vault version
Vault v1.5.3+ent
```
Helm 3.3.0:
```
$ helm version
version.BuildInfo{Version:"v3.3.0", GitCommit:"8a4aeec08d67a7b84472007529e8097ec3742105", GitTreeState:"dirty", GoVersion:"go1.14.6"}
```
OS X Catalina 10.15.6:
```
$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.15.6
BuildVersion:	19G2021
```

It may be possible to implement the demo with other versions of the above software, but this is neither tested
or guaranteed.

## Pre-Steps:
1. Install Code Ready Containers.
1. Install HashiCorp Vault
1. Install Helm
1. Start CRC using the `crc start` command and get ready to enter your pull secret from the Red Hat website.
1. Identify the ip address of your CRC server using the following command:
```
$ crc ip
[IP Address]
```
1. Temporarily add the following to your `/etc/hosts` file for ease of running the demo:
```
[IP Address] apps-crc.testing www.vault-agent.colin.testing www.cert-manager.colin.testing
```
1. If you are running Vault Enterprise, place a valid license key in a file called `license-vault.txt` in
this directory. The script `0-init-vault.sh` will automatically pick this up and apply it. (Disregard this step if you are running Vault Open Source).
1. Run each of the scripts in order starting from 0-... through to 6-...
1. Once scripts have run and pods deployed into vault-demo project are ready, access the following addresses
in your web browser `https://www.vault-agent.colin.testing` and `https://www.cert-manager.colin.testing`.
Observe that the certificates have a short TTL and are issued by the untrusted CA colin.testing.
1. When you are ready to kill the demo, simply run `crc stop` or `crc delete` to stop or delete the CRC deployment. Then run `99-kill-vault.sh` to kill the Vault dev server.
## Warning
This demo is provided as-is with no support or guarantee. It makes no claim as to "production-readiness" in areas including but not limited to:
- Configuration of Vault (including unsealing and configure Vault, configuration of PKI secrets engine and so on)
- Configuration of OpenShift
- Deployment of applications onto OpenShift
- Configuration and deployment of Cert Manager
