# Blacksmith v2.0.14

This release updates the Redis Forge documentation to reference version 1.4.0, which includes important security updates and Redis version improvements.

## Documentation Updates

- **Redis Forge Example**: Updated README.md documentation to reference redis-forge v1.4.0
  - Redis 6 upgraded to version 6.2.20
  - Redis 7 updated to version 7.2.11
  - Includes patches addressing CVE vulnerabilities in both Redis versions

## Deploying

To use this BOSH release, include the following in your BOSH deployment manifest:

```yaml
releases:
- name:    blacksmith
  version: 2.0.14
  url:     https://github.com/blacksmith-community/blacksmith-boshrelease/releases/download/v2.0.14/blacksmith-2.0.14.tgz
  sha1:    sha256:PENDING
```

**Note**: The SHA256 checksum will be added once the release tarball is created.

## Redis Forge Configuration

For those deploying Redis services with Blacksmith, the recommended Redis Forge release is now v1.4.0:

```yaml
properties:
  bosh:
    releases:
      - name: redis-forge
        version: 1.4.0
        url: https://github.com/blacksmith-community/redis-forge-boshrelease/releases/download/v1.4.0/redis-forge-1.4.0.tgz
        sha1: sha256:480c94ba6a7743c9796913d74425cb95d5cdfa685abbff73cd0beea71ff6d535
```

## Upgrade Notes

This is a documentation-only release with no functional changes to the Blacksmith broker itself. Existing deployments can continue running without modification.

If you are using Redis Forge, consider upgrading to v1.4.0 to benefit from the latest Redis security patches and version updates.

## Known Issues

None at this time.

## Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [Blacksmith BOSH Release GitHub repository](https://github.com/blacksmith-community/blacksmith-boshrelease).
