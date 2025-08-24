# Release Notes for v2.0.7

## Summary
This release updates Blacksmith to v1.0.7 and adds Cloud Foundry API endpoints configuration support to the broker.

## Changes Since v2.0.6

### Features
- **Cloud Foundry Integration**: Added support for configuring Cloud Foundry API endpoints in the broker
  - New `broker.cf.apis` property for configuring multiple CF endpoints
  - Each endpoint can specify name, endpoint URL, username, and password
  - Configuration is rendered in blacksmith.conf for broker consumption

### Component Updates
- **Blacksmith**: Updated from v1.0.6 to v1.0.7
  - New config management methods for BOSH director
  - Improved vault backup functionality
  - Cloud Foundry API integration
  - Enhanced user interface
  - Fixed SSH connection disconnection issues
  - Fixed reconciler metadata population
  - Cleaned up RabbitMQ audit functionality

## Configuration Example

To configure CF endpoints in your deployment:

```yaml
instance_groups:
- name: blacksmith
  jobs:
  - name: blacksmith
    properties:
      broker:
        cf:
          apis:
            production:
              name: "production-cf"
              endpoint: "https://api.system.production.example.com"
              username: "blacksmith"
              password: "secure-password"
```

## Upgrade Notes
This release is backwards compatible. The CF endpoints configuration is optional and existing deployments will continue to work without any changes.