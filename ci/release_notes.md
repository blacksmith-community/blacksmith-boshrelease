# Blacksmith BOSH Release v2.1.0

Bumps the Blacksmith service broker to v1.2.0.

## What's New in Blacksmith v1.2.0

**Dynamic network selection for service bindings** — Blacksmith now extracts
network names from BOSH deployment manifests when constructing DNS hostnames
for service bindings. Previously, the network was always read from the
`BOSH_NETWORK` environment variable, which broke bindings when instance groups
used different networks. Each VM's binding now reflects its actual network from
the manifest, with `BOSH_NETWORK` as a fallback.

**Thread safety fixes** — Resolved data races in three packages:
- **Manifest generation**: Serialized spruce library calls which use unsafe global state
- **Vault client**: Added RWMutex with double-checked locking for concurrent client initialization
- **Global logger**: Protected Get/Set/Configure with RWMutex

**Vault API migration** — Replaced deprecated `TuneMount` with `TuneMountAllowNil`
for KV v1→v2 mount upgrades, aligning with current HashiCorp Vault SDK.

**Dependency updates** — Bumped Go module dependencies to resolve known security vulnerabilities.

## Deploying

```yaml
releases:
- name:    blacksmith
  version: 2.1.0
  url:     https://github.com/blacksmith-community/blacksmith-boshrelease/releases/download/v2.1.0/blacksmith-2.1.0.tgz
  sha1:    sha256:PENDING
```

## Upgrade Notes

This release includes thread safety improvements and a new feature for dynamic
network selection. Existing deployments should upgrade to benefit from the data
race fixes. No configuration changes are required — the new network selection
is automatic with `BOSH_NETWORK` as the fallback.
