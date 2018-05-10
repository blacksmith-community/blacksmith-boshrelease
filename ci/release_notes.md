# Improvements

- Removed the `config: true` value from the blacksmith.conf
  configuration file template; Blacksmith doesn't honor that
  anymore and only honors the BLACKSMITH_DEBUG environment
  variable (which we were already setting).
