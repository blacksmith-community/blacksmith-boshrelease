# Blacksmith BOSH Release v2.7.1

This release bumps the Blacksmith service broker to v1.8.1, which makes the status endpoint report real health, adds a Max in flight choice and clearer messages to the Run command screens, and fixes several terminal and Redis client problems.

## Upgrading

Moving from v2.7.0 needs no manifest change, and this release adds no job properties. The notes for v2.7.0 still apply to anyone upgrading from an earlier release.

Anything that polls `/b/status` should expect the broker to report an unhealthy dependency now. A director or Vault that can't be reached, or a Vault that is sealed, turns `healthy` to false while the response stays a 200.

## What changed in Blacksmith v1.8.1

- The `/b/status` endpoint reports the real build version and the commit, and it checks the BOSH director and Vault, including a sealed Vault, instead of always saying everything is connected.

- The Run command screens gained a Max in flight choice that goes up to what the director allows, a full-width Command box, and help text that says why the Run button is still waiting. The confirmation label now reads `To confirm, type "run as vcap" below`, and it says plainly when the typed text doesn't match.

- A terminal tab that fails to start offers Reconnect and stays marked as failed after a reload. The console also stopped writing sensitive text to the browser console.

- The Redis clients behave as they did before the upgrade to go-redis v9, so older Redis nodes still connect, `tls_uri` connections still work, silent nodes are handled as before, and the Valkey check still diagnoses the connection limit, all as they did in v1.8.0.

- The broker moved to Ginkgo v2, go-redis v9, and yaml v4, and several tests that failed now and then under load were made reliable.

- The broker's own release notes are at https://github.com/blacksmith-community/blacksmith/releases/tag/v1.8.1.
