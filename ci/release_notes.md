# Blacksmith BOSH Release v2.6.0

This release bumps the Blacksmith service broker to v1.7.0, which adds release upgrades to the broker's upgrade feature. Until now, an upgrade task could only move service instances to a new stemcell. A task can now also name target versions of BOSH releases, such as a new valkey-forge or bpm, and the broker sets those versions in each instance's manifest before it redeploys that instance.

## Upgrading

No job properties change, so moving from v2.5.2 needs no manifest change. The notes for v2.5.0 still apply to anyone upgrading from an earlier release, because `bosh.ca_cert` is required, and plain HTTP needs `bosh.allow_http`.

The broker never uploads a release, so every target version of a release upgrade must already be on the director. The broker now also refuses a stemcell upgrade for an instance that another unfinished upgrade task holds, and requests that it can't act on now get a 400, where they used to get a 500.

## What changed in Blacksmith v1.7.0

- An upgrade request can carry release targets, either alone or together with a stemcell target, and the upgrade tab in the UI offers the releases each deployment runs.

- The broker's API gained `GET /b/bosh/releases` and `GET /b/bosh/deployment-releases`, which list the director's releases and the releases Blacksmith manages in each deployment.

- The broker refuses to upgrade an instance that another unfinished upgrade task already holds, and it skips a stored upgrade task that it can't decode, where before it retried that task until shutdown.

- The broker's own release notes are at https://github.com/blacksmith-community/blacksmith/releases/tag/v1.7.0.
