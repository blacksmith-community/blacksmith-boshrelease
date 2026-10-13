# Blacksmith BOSH Release v2.5.0

This release bumps the Blacksmith service broker to v1.6.0. The broker no longer embeds the bosh CLI, and it now talks to the BOSH director only through the director's REST API. Two of the job's properties change in ways that can stop a deploy or keep the broker from starting, so please read the first section before you upgrade.

## Before you upgrade

- **`bosh.ca_cert` is now required**

  A manifest that leaves it unset, or sets it to a blank value, now fails to render at deploy time with a message that names the property, instead of deploying a broker that can't start. The broker verifies the director's certificate, and its UAA's, against this CA whatever the scheme of `bosh.address`. The Genesis kit's external-director mode already sets it from `params.external_bosh.cacert`, and the kit's default mode will set it from the director's CA starting with the next kit release.

- **Plain HTTP needs `bosh.allow_http`**

  We added `bosh.allow_http`, which defaults to `false`. The broker refuses a `bosh.address` that starts with `http://` unless it's `true`, because the director's credentials would travel over plain HTTP, so we suggest setting it only for development. `bosh.ca_cert` is still required when it's on.

## What changed in Blacksmith v1.6.0

- Every director operation now goes through the boshapi client, so the broker no longer runs bosh CLI code or exports `BOSH_ENVIRONMENT`, `BOSH_CLIENT`, `BOSH_CLIENT_SECRET`, or `BOSH_CA_CERT` into its environment.

- When a delete finishes on the director but the broker can't remove the instance from its index, the broker now keeps answering that the delete is in progress, so Cloud Foundry's polling eventually times out. Before, the broker told Cloud Foundry that the delete had succeeded while the instance was still indexed.

- The broker now gives up on a BOSH task, and releases its slot, when it has been unable to read that task from the director for six hours. A read that succeeds starts the count again, so a long task that the broker can still read is followed to its end. The task itself keeps running on the director. The broker's `bosh.task_watch_max` setting changes the six hours, but this job doesn't render that setting, so the default applies to every deployment of the release.

- The broker's own release notes list the API changes, such as the manifest routes no longer returning a placeholder manifest and the configs API returning the director's content unchanged. They're at https://github.com/blacksmith-community/blacksmith/releases/tag/v1.6.0.

## Other changes since v2.4.0

- We added `bosh.request_timeout`, the number of seconds Blacksmith waits for any single BOSH director request, with a default of 60. Long director tasks aren't bounded by it, because Blacksmith follows them by task ID. A value that isn't a positive whole number fails the job render with a message that names the property.

- The job now quotes every credential and free-text value it writes into `blacksmith.conf`. That covers the bosh address, username, and password, the shield block, the broker's username and password, the Cloud Foundry API entries, and the bosh network name. A value with a colon followed by a space, a hash, a quote, a backslash, or nothing at all reaches Blacksmith exactly as written, and a password made only of digits stays a string. Ports and booleans keep their YAML types.

- CredHub cleanup is now on by default. `credhub.cleanup.enabled` defaults to `true`, and `credhub.cleanup.sweep` defaults to `dry-run`, which logs what the sweep would delete and removes nothing. An unquoted `sweep: off` in a manifest now means the string `off`, not `false`.

- A broker with no CredHub connection logs one warning at startup and deletes nothing, so a deploy that sets none of the CredHub properties renders and runs as it did before. The four connection properties, `credhub.url`, `credhub.ca_cert`, `credhub.client_secret`, and `credhub.director_name`, now default to an empty string, and they go together. While cleanup is enabled, setting only some of them fails the job render with a message that names the missing ones.

- To keep cleanup off on purpose, set `credhub.cleanup.enabled` to `false`. To move the sweep from logging to deleting, set `credhub.cleanup.sweep` to `delete` once the dry-run log looks right.

- The release's job template specs now run before every release is built.
