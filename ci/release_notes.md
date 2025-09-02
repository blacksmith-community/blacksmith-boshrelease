# Blacksmith v2.0.11

This release updates the Blacksmith broker to version 1.0.11, bringing enhanced UI configuration options and improved operational resilience.

## Component Updates

- **Blacksmith** updated from v1.0.10 to v1.0.11

## Upstream Changes (Blacksmith v1.0.11)

### New Features

- **UI SSH Enable/Disable Configuration**: Added new UI configuration option to enable or disable SSH functionality, providing better control over access methods
- **Graceful Degradation**: Implemented graceful degradation of functionality when services are unavailable or unconfigured, improving system stability and user experience

### Technical Improvements

- **Enhanced Configuration Management**: Improved handling of missing or misconfigured components to prevent service disruption
- **Better Error Handling**: Enhanced error recovery mechanisms when dependent services are unavailable
- **Operational Reliability**: Strengthened service resilience to handle partial system failures gracefully

## Deploying

To use this BOSH release, include the following in your BOSH deployment manifest:

```yaml
releases:
- name:    blacksmith
  version: 2.0.11
  url:     https://github.com/blacksmith-community/blacksmith-boshrelease/releases/download/v2.0.11/blacksmith-2.0.11.tgz
  sha1:    sha256:PENDING
```

**Note**: The SHA256 checksum will be added once the release tarball is created.

## Upgrade Notes

This release is fully backward compatible with v2.0.10. No configuration changes are required when upgrading. The new SSH configuration option and graceful degradation features will take effect immediately upon deployment.

## Known Issues

None at this time.

## Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [Blacksmith BOSH Release GitHub repository](https://github.com/blacksmith-community/blacksmith-boshrelease).
