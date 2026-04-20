# Blacksmith BOSH Release v2.2.0

Bumps the Blacksmith service broker to v1.3.0.

## What's New in Blacksmith v1.3.0

**Per-binding Valkey ACL** — Valkey service bindings now get their own
ACL-isolated users scoped to per-binding credentials. Broker bind/unbind
flows create and remove ACL users atomically with the Vault credential
lifecycle. Requires Valkey forge v1.1.0+ for the service-side plumbing.

**Configurable reconciler and Vault retention** — The reconciler interval
and Vault secret `max_versions` are now configurable via broker properties,
letting operators tune garbage collection and credential retention without
rebuilding.

**UI improvements** — Batch operation bulk selection for multi-instance
workflows, and general layout polish.

## Deploying

```yaml
releases:
- name:    blacksmith
  version: 2.2.0
  url:     https://github.com/blacksmith-community/blacksmith-boshrelease/releases/download/v2.2.0/blacksmith-2.2.0.tgz
  sha1:    sha256:PENDING
```

## Upgrade Notes

This release introduces per-binding Valkey ACL support. If you have the
Valkey forge deployed, bump it to v1.1.0 or later — the ACL features
require the matching forge-side plumbing.

No breaking changes for existing non-Valkey deployments; new broker
properties for reconciler/Vault retention fall back to sensible defaults
when unset.
