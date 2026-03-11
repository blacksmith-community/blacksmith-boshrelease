# Blacksmith BOSH Release v2.1.1

Bumps the Blacksmith service broker to v1.2.1.

## What's New in Blacksmith v1.2.1

**Network extraction optimization** — Moved network name extraction from
live BOSH API manifest fetches to local Vault lookups. Previously, every
call to `GetDeploymentVMs()` triggered a `deployment.Manifest()` API round
trip to the BOSH Director. Blacksmith now reads the pre-stored manifest
from Vault for each instance, reducing Director load and improving binding
response times.

## Deploying

```yaml
releases:
- name:    blacksmith
  version: 2.1.1
  url:     https://github.com/blacksmith-community/blacksmith-boshrelease/releases/download/v2.1.1/blacksmith-2.1.1.tgz
  sha1:    sha256:PENDING
```

## Upgrade Notes

This is a performance patch with no configuration changes required.
Existing deployments benefit from reduced BOSH Director API calls during
service binding operations.
