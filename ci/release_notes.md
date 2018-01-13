# Improvements

- The `blacksmith` job now accepts a fully-formed cloud-config,
  which it will attempt to deploy to the BOSH director.
- The `blacksmith` job now accepts a list of stemcell names /
  versions / urls / sha1 checksums, which it will attempt to
  upload to the BOSH director if they are missing.

# Software Updates

Bumped https://github.com/cloudfoundry-community/blacksmith to v0.0.3
