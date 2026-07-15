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
