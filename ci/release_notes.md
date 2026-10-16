# Blacksmith BOSH Release v2.5.1

This release bumps the Blacksmith service broker to v1.6.1, which fixes how the broker reads the director's answer to a request that starts a task. A director that serves its API over HTTP/1.1 answers such a request with a 303 See Other redirect, and the broker in v2.5.0 accepted only a 302. Against that kind of director, a restart, stop, start, or recreate of a service deployment answered 500 even though the director ran it.

## Upgrading

No job properties change, so moving from v2.5.0 needs no manifest change. The notes for v2.5.0 still apply to anyone upgrading from an earlier release, because `bosh.ca_cert` is required and plain HTTP needs `bosh.allow_http`.

## What changed in Blacksmith v1.6.1

- The broker now uses boshapi v0.283.9, which treats a 303 to `/tasks/<id>` as a task redirect, the same way it treats a 302.

- The broker's own release notes are at https://github.com/blacksmith-community/blacksmith/releases/tag/v1.6.1.
