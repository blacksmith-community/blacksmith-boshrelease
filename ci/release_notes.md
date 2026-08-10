# Blacksmith BOSH Release v2.2.1

Bumps the Blacksmith service broker to v1.3.1.

## What's Fixed in Blacksmith v1.3.1

**Unbind no longer fails for classic Valkey plans** — Unbind chose the
Valkey ACL path from the plan id, while bind chooses it from the
credential content. Classic shared-password plans matched the plan-id
check, so unbinding one failed with `admin_password required for Valkey
service`, even though no per-binding ACL user was ever created for it.

Unbind now applies the same check as bind. A plan whose credentials carry
no ACL trigger fields has nothing to remove, so the unbind succeeds as a
no-op. Plans that do use per-binding ACL credentials are unaffected and
still have their user deleted.

This pairs with valkey-forge v1.1.1, which adds the `standalone-classic`
and `cluster-classic` plan types.

## Pre-upgrade release

Built on v2.2.0. This is a patch on the deployed line: the only change is
the Blacksmith blob. The bundled Safe (1.9.0) and Vault (1.14.10) are
deliberately unchanged, so none of the v2.3.0 upgrade content is included.
