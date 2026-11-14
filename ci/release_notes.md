# Blacksmith BOSH Release v2.7.2

This release bumps the Blacksmith service broker to v1.8.2, which adds a navigation rail, phone layouts, and home-screen install to the console, and makes the Activity view and the Run command screens clearer about what happened on each node.

## Upgrading

Moving from v2.7.1 needs no manifest change, and this release adds no job properties. The notes for v2.7.1 still apply to anyone upgrading from an earlier release.

Root commands stay off until we set `commands.allow_root` to `true` and redeploy. A command that runs as vcap can't use `sudo`, so a command that calls it needs to run as root without `sudo`. This release adds one sentence to the `commands.allow_root` description in the job spec that says so.

A command's error stream is now merged into its output, so anything that reads command output and expects a separate stderr should check the `merged` field that the output endpoint now returns.

## What changed in Blacksmith v1.8.2

- A single navigation rail replaces the tab strips, with a docked rail on wide screens, an icon strip on mid-size screens, and a drawer on a phone.

- Tables become labelled cards on a phone, touch controls reach 44 pixels, and text fields stop iOS from zooming the page.

- The console can be installed on a home screen. The manifest gains shortcuts and matching colors, and the manifest, favicon, and icons load without a password.

- The Activity view has one summary table for every job, links each node to its instance and VM row, and explains a failed node with its exit status, user, and the lines that matter.

- Run command merges a command's error stream into its output, labels the vcap choice as unable to use sudo, and warns when a vcap command starts with `sudo`, `su`, `doas`, or `pkexec`.

- The Tasks toolbar is one labelled row, and minimized terminals dock at the bottom of the page.

- The broker records the director tasks behind each command's SSH sessions.

- The broker moved to go-redis v9.23.0, graft v1.47.0, boshapi v0.283.10, and capi v3.236.1, and CI now runs the linter it was meant to run.

- The broker's own release notes are at https://github.com/blacksmith-community/blacksmith/releases/tag/v1.8.2.
