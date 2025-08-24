# Release v2.0.9

## Component Updates

Updated Blacksmith to v1.0.9

### Blacksmith v1.0.9 Changes

From the [upstream release](https://github.com/blacksmith-community/blacksmith/releases/tag/v1.0.9):

**New Features:**
- **Automatic Credential Recovery from Cloud Foundry**
  - Recovers missing service credentials from CF application environments
  - Supports intelligent credential normalization for various service types

- **RabbitMQ Dashboard Integration**
  - Automatically discovers and stores RabbitMQ management dashboard URLs
  - Provides one-click access to management consoles

**Bug Fixes:**
- Fixed SSH connection routing to correctly connect to selected VM instances
- Improved service dropdown filter to display human-readable service names
- Enhanced credential recovery and metadata management

**Technical Improvements:**
- Added new methods in CF Manager for fetching app environments
- Improved reconciler with Cloud Foundry integration support
- Enhanced UI/UX with better state preservation and error handling

This release is fully backward compatible and requires no configuration changes.