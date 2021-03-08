# Demo Node Config

This repository contains the configuration of the [Monocle Demo Node][demo-node].
Configuration is defined using the [Dhall][dhall-lang] language and the
[dhall-monocle][dhall-monocle] binding.

## How to edit

- Change config.dhall according to your need
- Ensure the configuration format by running:

```
dhall-to-yaml --file config.dhall
dhall format --inplace ./config.dhall
```

- Submit the Pull Request
- Wait for the CI to success

[demo-node]: https://demo.changemetrics.io/
[dhall-lang]: https://dhall-lang.org
[dhall-monocle]: https://github.com/change-metrics/dhall-monocle
