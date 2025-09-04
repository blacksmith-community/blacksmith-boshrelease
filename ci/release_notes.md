# Blacksmith v2.0.13

This release updates the Blacksmith broker to version 1.0.13, introducing powerful Vault Auto-Unseal capabilities, enhanced reconciler functionality, and significant code quality improvements for increased operational reliability.

## Component Updates

- **Blacksmith** updated from v1.0.12 to v1.0.13

## Upstream Changes (Blacksmith v1.0.13)

### New Features

- **Vault Auto-Unseal Support**: Revolutionary new automatic Vault unsealing functionality with configurable health monitoring and intelligent retry logic, eliminating manual intervention for Vault restarts
- **Enhanced Reconciler Functionality**: Advanced broker-based binding reconstruction with Cloud Foundry service discovery integration, preserving existing instance names during reconciliation operations
- **Improved Vault Integration**: Smart Vault health monitoring with configurable check intervals and graceful degradation modes for enhanced system resilience

### Technical Improvements

- **Configuration Standardization**: All configuration keys have been standardized to lowercase format for consistency and improved maintainability
- **Code Quality Excellence**: Passed comprehensive `golangci-lint` checks across the entire codebase, ensuring adherence to Go best practices and eliminating potential issues
- **Race Condition Prevention**: Added comprehensive race condition testing and safeguards to prevent concurrency-related issues in high-load environments
- **Operational Reliability**: Enhanced error handling and retry mechanisms throughout the system for improved stability under adverse conditions

### Development & Testing Enhancements

- **Enhanced Test Coverage**: Expanded test suite with race condition detection and improved validation scenarios
- **Development Tooling**: Improved development environment setup and debugging capabilities
- **Code Maintainability**: Refactored codebase following Go best practices with improved documentation and error handling

### Breaking Changes

- **Configuration Format**: Configuration keys have been changed to lowercase format. Existing deployments will need configuration updates during upgrade (see Upgrade Notes below)

## Deploying

To use this BOSH release, include the following in your BOSH deployment manifest:

```yaml
releases:
- name:    blacksmith
  version: 2.0.13
  url:     https://github.com/blacksmith-community/blacksmith-boshrelease/releases/download/v2.0.13/blacksmith-2.0.13.tgz
  sha1:    sha256:PENDING
```

**Note**: The SHA256 checksum will be added once the release tarball is created.

## Upgrade Notes

**IMPORTANT**: This release contains breaking changes in configuration format.

### Required Actions Before Upgrade

1. **Update Configuration Keys**: Convert all configuration keys to lowercase format in your deployment manifests
2. **Review Vault Auto-Unseal Settings**: Configure new auto-unseal parameters if you want to enable this feature
3. **Configure Health Check Intervals**: Review and set appropriate health check intervals for your environment
4. **Test Vault Restart Scenarios**: Validate that your Vault configuration works correctly with the new auto-unseal functionality

### Migration Steps

1. Update your deployment manifest configuration keys from uppercase/camelCase to lowercase
2. Deploy the new release
3. Monitor logs for any configuration warnings or errors
4. Test Vault operations to ensure proper functionality

### Backward Compatibility

While the core functionality remains backward compatible, the configuration format changes require manifest updates. The new auto-unseal and enhanced reconciler features are optional and can be enabled incrementally.

## Known Issues

None at this time.

## Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [Blacksmith BOSH Release GitHub repository](https://github.com/blacksmith-community/blacksmith-boshrelease).
