# Bug Fixes

- We had support in the packaged `blacksmith` daemon, but the BOSH
  release didn't set the `$BLACKSMITH_OPER_HOME` variable to
  activate it.  This has now been fixed.
