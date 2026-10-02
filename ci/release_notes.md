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

# Blacksmith

- Bumped Blacksmith to v1.4.7, which makes a failed Valkey bind or unbind say why it failed. Every Valkey ACL error now names the step that failed (dial, AUTH, PING, ACL SETUSER, ACL DELUSER, or ACL SAVE), the node's address, and whether TLS was in use, and it adds a likely cause when it can. A node that answers `MISCONF` because it cannot write its snapshots now gets a hint to check that node's disk and server log, where before the platform saw only "internal server error".
- Every failed attempt inside the ACL retry loop is logged at error level with the instance ID, the binding ID, the address, and the attempt number.
- The broker library moves to osbapi v2.0.2. An error the library has no mapping for still returns a 500, but its description is now the error's own message, so `cf` shows the operator the cause. Every 5xx is logged with the operation, the request path, and the instance and binding IDs, through Blacksmith's own logger under the `osbapi` name. This brings back a broker-library log line for failed requests, which v1.4.5 had dropped.
- Error text that reaches the platform never carries a binding password or the admin password. Valkey echoes part of a rejected ACL SETUSER back in its reply, and Blacksmith now redacts the password from that reply. The broker also refuses a `vault.address` that has credentials embedded in it.

# Blacksmith

- Bumped Blacksmith to v1.4.8, which fixes how the broker answers Cloud Foundry's last-operation polls. Until now the broker looked at the newest BOSH task on the deployment and treated anything that wasn't a delete as a provision. A finished `bosh ssh`, `restart`, `recreate`, or `cck` task could therefore make Cloud Foundry report a delete as succeeded while BOSH was still deleting the deployment. On the way, the broker also added the instance back to vm-monitor and could reschedule the SHIELD backup it had just removed.

- The broker now returns operation data with every provision and deprovision, and it records the accepted operation in Vault before it answers. A delete finishes only when the delete task the broker started is done and the director confirms the deployment is gone, and it fails when that task fails. A create finishes only on its own deploy task, so a task someone runs by hand on the deployment can't finish it early or hide a failed deploy. Polling a delete never runs the steps that follow a create.

- The broker names its own deploy and delete tasks from the deployment's BOSH events. It no longer takes the newest task, which could be a `bosh ssh` session or a vm-monitor vitals request that ran while the deploy or delete was in progress.

- If the broker restarts in the middle of a create or delete, the next poll recovers the task from the deployment's events. If BOSH never started the task and nothing is running on the deployment, the poll answers failed and says the operation was interrupted, so the request can be retried instead of waiting out Cloud Controller's polling timeout.

- A failed delete attempt that the broker is going to retry no longer reports the delete as failed. A repeated delete request for an instance whose delete is still running is accepted without starting a second delete. The broker removes an instance from its index only when the director confirms the deployment is gone, so a director error no longer counts as that confirmation. When a deploy fails, the broker still deletes the failed deployment, but now it does so in the background and only once.

- Creates and deletes that an earlier release accepted and that are still running during the upgrade keep working, because the broker falls back to the state it recorded in Vault. No configuration changes are required.

# Blacksmith

- Bumped Blacksmith to v1.4.9, which makes Valkey ACL operations fail at once, with an explanation, instead of retrying a request that can't succeed. A MISCONF reply, a WRONGPASS reply, a NOAUTH reply, or a NOPERM reply now ends the operation on the first attempt. Each failure message names the likely causes, such as a Valkey instance that can't write its persistence files, an admin password that no longer matches the one Valkey was started with, or an admin user that lacks permission to manage ACL users.

- The broker log no longer carries credentials, manifest bodies, secret environment values, rabbitmqctl arguments, or credential query parameters. Failed init script output also has VAULT_TOKEN and BOSH_CLIENT_SECRET masked before it is logged or returned.

- The broker library moves to osbapi v2.0.3. It maps an unauthorized error to a 401, a quota error to a 422, an invalid-parameter error to a 400, and a binding conflict to a 409, so Cloud Foundry shows the operator a specific status instead of a generic 500.

- No configuration changes are required.
