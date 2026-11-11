# Blacksmith BOSH Release v2.7.0

This release bumps the Blacksmith service broker to v1.8.0, which adds a certificate inventory with operator-approved rotation, a Run command batch operation, a new SSH terminal in the console, and tighter handling of tenant request parameters. It also adds job properties that switch the certificate features and the Run command operation on and off.

## Upgrading

Moving from v2.6.0 needs no manifest change. The new properties all have defaults, so an existing deployment keeps working and gets the inventory without further settings. The notes for v2.5.0 still apply to anyone upgrading from an earlier release, because `bosh.ca_cert` is required, and plain HTTP needs `bosh.allow_http`.

The release adds `certificates.inventory.enabled`, which defaults to true, and `certificates.rotation.enabled` and `certificates.patch_in_place.enabled`, which both default to false. Patching in place takes effect only when rotation is also on. These switches, and `credhub.cleanup.enabled`, now accept only a real true or false, and the render fails on a quoted string such as "false", "no", or "off", where before, any string counted as true. Check any manifest that quotes one of them before the upgrade.

The credhub block now fails the render when only some of its four connection properties are set, even with `credhub.cleanup.enabled` off. Set `credhub.url`, `credhub.ca_cert`, `credhub.client_secret`, and `credhub.director_name` together, or none of them.

Rotation regenerates certificates through the broker's CredHub connection, so it can work only when those credhub properties are set.

The Run command operation can now be switched off with `commands.enabled`. Root stays refused by default, and `commands.allow_root` turns it on only while commands are enabled. The release also takes `commands.credential.key`, a secret that adds a second credential to every command request, and `bosh.director_workers`, which tells the broker how many workers the director has. When set, `bosh.director_workers` must be a whole number of 2 or more, and the render fails on anything lower. A property that is left unset stays out of the broker's configuration, so the broker keeps its own default, which is Run command on, root refused, no second credential, and four director workers.

## What changed in Blacksmith v1.8.0

- The broker keeps an inventory of the certificates behind its service instances and shows their expiry dates in the console, and an operator can rotate selected leaf certificates by redeploying, or by patching them in place on the VMs.

- A new Run command batch operation runs one command on every VM behind the selected service instances, with a preview, a confirmation for dangerous commands, bounded parallelism, and a pause when a node fails.

- Batch jobs can choose to pause on failure, and the console gained a wterm SSH terminal with color schemes, a maximize control, and tabs that survive a reload.

- All BOSH calls now go through the boshapi client, and all YAML handling goes through graft.

- Request parameters from a tenant are now treated as plain text, so they can no longer reach the broker's template operators, and Cloud Foundry registrations no longer store the admin password.

- The broker's own release notes are at https://github.com/blacksmith-community/blacksmith/releases/tag/v1.8.0.
