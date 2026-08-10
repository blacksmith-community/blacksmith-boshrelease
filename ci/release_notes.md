# Blacksmith BOSH Release v2.2.2

Bumps the Blacksmith service broker to v1.3.2.

## What's Fixed in Blacksmith v1.3.2

**Service instances are attributed to the right plan** — a plan whose ID
extends another plan's ID (for example `standalone-classic` alongside
`standalone`) was recorded against the shorter plan. `LastOperation` then
looked for a deployment name built from that wrong plan, found nothing,
and the instance sat at "create in progress" forever even though its BOSH
deployment had succeeded.

Deployment matching now compares the whole plan ID rather than the first
prefix that happens to fit, and an instance's operations are resolved
using the deployment name recorded when it was provisioned.

This affects any plan whose ID extends another's, not only the `-classic`
plans that surfaced it.

## Pre-upgrade release

Built on v2.2.1. This is a patch on the deployed line: the only change is
the Blacksmith blob. The bundled Safe (1.9.0) and Vault (1.14.10) are
deliberately unchanged, so none of the v2.3.0 upgrade content is included.
