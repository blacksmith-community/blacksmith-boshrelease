# Blacksmith BOSH Release v2.5.2

This release bumps the Blacksmith service broker to v1.6.2, which names the stemcell OS correctly for service instances on noble, resolute, and later Ubuntu stemcells. Before this, the broker left the OS blank for any stemcell newer than jammy, and the UI showed such a stemcell as "/<version>".

## Upgrading

No job properties change, so moving from v2.5.1 needs no manifest change. The notes for v2.5.0 still apply to anyone upgrading from an earlier release, because `bosh.ca_cert` is required and plain HTTP needs `bosh.allow_http`.

## What changed in Blacksmith v1.6.2

- The broker's VM monitor now recognises any `ubuntu-<codename>` in a stemcell's name, while still recognising the CentOS 7 and Windows stemcells.

- The broker's own release notes are at https://github.com/blacksmith-community/blacksmith/releases/tag/v1.6.2.
