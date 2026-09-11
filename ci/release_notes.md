# Blacksmith BOSH Release v2.3.0

Security-focused release: bumps the Blacksmith service broker to v1.4.0 and swaps the bundled Vault binary from 1.14.10 to 1.21.4.

## What's New in Blacksmith v1.4.0

**Broker API library modernized (brokerapi v8 → v13)** — The broker moves from the end-of-life `pivotal-cf/brokerapi/v8` to the maintained `code.cloudfoundry.org/brokerapi/v13`. Service provisioning and binding behavior are unchanged; the one operator-visible effect is the broker's log output format (see Upgrade Notes).

**Bundled Vault binary 1.14.10 → 1.21.4** — The embedded Vault server the broker uses for per-instance credential storage moves to 1.21.4, the terminal Vault 1.x Community Edition release, clearing the reachable Vault CVE set.

**Go dependency and toolchain refresh** — Rebuilt on Go 1.25.12 with refreshed security-sensitive dependencies (x/crypto, x/net, grpc, go-jose, circl, vault/api). The shipped broker binary scans clean for reachable vulnerabilities.

## Upgrade Notes

**Log format change (the one operator-visible change)** — Broker-library log lines now emit standard-library structured JSON (`slog`) instead of Lager-format JSON. If you ship or alert on broker logs by parsing Lager fields (`source`, `message`, `data`), re-key those rules to the `slog` JSON shape before or alongside the upgrade. Provisioning, binding, and credential behavior are otherwise unchanged.

**Ephemeral disk during the swap** — The 1.21.4 Vault binary is larger than 1.14.10; the broker VM needs enough `/var/vcap/data` to extract the new package alongside the old one during the upgrade. Ensure the broker instance group has an adequately sized ephemeral disk.

No configuration changes are required, and there are no changes to service provisioning, binding, or credential formats.

# Safe

- Bumped Safe to v1.10.0

# Safe

- Bumped Safe to v1.20.0

# Safe

- Bumped Safe to v1.22.0

# Safe

- Bumped Safe to v1.23.0

# Safe

- Bumped Safe to v1.24.0

# Blacksmith

- Bumped Blacksmith to v1.4.2

# Blacksmith

- Bumped Blacksmith to v1.4.3, which lets the broker trust a private CA when it talks to the Cloud Foundry API.
- Added `broker.cf.ca_cert` and `broker.cf.skip_ssl_validation`. They are rendered into every `broker.cf.apis` entry as `cacert` and `skip_ssl_validation`, and an entry may set its own `ca_cert` or `skip_ssl_validation` to override them.
- Removed `bosh.skip_ssl_validation`. The broker's BOSH client never read it, so a director with a private CA has always needed `bosh.ca_cert`.

# Blacksmith

- Bumped Blacksmith to v1.4.4, which fixes the deprovision-during-provision race: a deprovision is now rejected with a concurrency error while the instance's provision task is still running, only a director 404 counts as a missing deployment (an in-flight first deploy with an empty manifest no longer does), and the reconciler reports deployments that have neither an index entry nor a CF instance instead of adopting them, while sweeping index entries whose deployment the director confirms gone.

# Blacksmith

- Bumped Blacksmith to v1.4.5, which moves the broker from `code.cloudfoundry.org/brokerapi/v13` to `github.com/fivetwenty-io/osbapi/v2` and adds a tombstone sweep to the vault index reconciler.
- The broker library change is not visible in service provisioning, binding, or credential formats, and the OSB endpoints, status codes, and error bodies are unchanged. The one thing operators will notice is that the structured `slog` JSON lines the previous library wrote for each broker request are gone, because the new library does not log on its own. Blacksmith still writes its own request and routing log lines, so alerting that keys on those lines keeps working, and anything that keyed on the library's `slog` lines should move to them.
- Basic authentication on the `/v2` endpoints is enforced by Blacksmith's own front door exactly as before, and a request that omits `X-Broker-Api-Version` is still accepted, now with version 2.17 filled in.
- The reconciler now sweeps deleted tombstones out of the vault index. A tombstone that names no deployment ages out on its own without a director call, and a tombstone that names a deployment is removed once the director confirms the deployment is gone and no task is running for it. The deprovision race guards from v2.3.6 are unchanged.
