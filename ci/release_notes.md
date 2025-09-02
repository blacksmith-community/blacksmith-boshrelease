# Blacksmith v2.0.10

This release updates the Blacksmith broker to version 1.0.10, bringing UI bug fixes, improvements to WebSocket infrastructure, API performance, and UI enhancements.

## Component Updates

- **Blacksmith** updated from v1.0.9 to v1.0.10

## Upstream Changes (Blacksmith v1.0.10)

### New Features

- **WebSocket Infrastructure Upgrade**: Migrated from gorilla/websocket to nhooyr.io/websocket for improved connection management and reliability
- **API Compression**: Added gzip compression for API responses, reducing payload sizes and improving performance
- **Query Parameter Support**: Implemented query parameter support for SSH instance selection, enabling more flexible instance targeting
- **UI Modernization**: Integrated Tailwind CSS framework and enhanced JavaScript functionality for a better user experience

### Performance Improvements

- **Optimized API Responses**: Filtered large fields from API responses to improve UI rendering performance
- **Enhanced WebSocket Message Handling**: Improved message processing efficiency for real-time communications
- **Better Connection Management**: Strengthened BOSH director connection handling with improved error recovery

### Bug Fixes

- Fixed Cloud Foundry service name handling to ensure proper service instance identification
- Resolved UI display issues with service instance information
- Corrected SSH streaming connection timeout problems that could cause dropped connections
- Improved error recovery in reconciler operations for better system resilience

### Technical Improvements

- Reduced overall API response sizes for faster data transfer
- Enhanced CSS styling for improved visual consistency
- Strengthened error handling throughout the codebase
- Improved connection reliability for SSH streaming sessions

## Deploying

To use this BOSH release, include the following in your BOSH deployment manifest:

```yaml
releases:
- name:    blacksmith
  version: 2.0.10
  url:     https://github.com/blacksmith-community/blacksmith-boshrelease/releases/download/v2.0.10/blacksmith-2.0.10.tgz
  sha1:    sha256:PENDING
```

**Note**: The SHA256 checksum will be added once the release tarball is created.

## Upgrade Notes

This release is fully backward compatible with v2.0.9. No configuration changes are required when upgrading. The WebSocket infrastructure changes and API improvements will take effect immediately upon deployment.

## Known Issues

None at this time.

## Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [Blacksmith BOSH Release GitHub repository](https://github.com/blacksmith-community/blacksmith-boshrelease).
