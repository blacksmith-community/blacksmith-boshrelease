# Release v2.0.8

## Component Updates

Updated Blacksmith to v1.0.8

### Blacksmith v1.0.8 Changes

From the [upstream release](https://github.com/blacksmith-community/blacksmith/releases/tag/v1.0.8):

**Bug Fixes:**
- Fixed an issue where Forges that implement the `unconfigure` endpoint could be unconfigured without proper `bosh-url` set, which then causes blacksmith to not be able to delete the deployment.

This release ensures that unconfiguration operations properly handle BOSH URL settings, preventing orphaned deployments that cannot be deleted.