# Demo Node Config

This repository contains the configuration of the [Monocle Demo Node][demo-node].
Configuration must be provided via [Dhall][dhall-lang] using the
[dhall-monocle][dhall-monocle] binding.

## How to edit

- Change config.dhall according to your need
- Ensure the configuration format by running:

```
dhall-to-yaml <<< ./config.yaml
dhall --ascii format --inplace ./config.dhall
```

- Submit the Pull Request
- Wait for the CI to success [TODO]

## Configuration to land on the demo node

As of now, no auto deployment playbook is implemented. That means, once your
proposal is merged, you'll need to wait for the maintainer to update the demo
node configuration.


[demo-node]: https://demo.changemetrics.io/
[dhall-lang]: https://dhall-lang.org
[dhall-monocle]: https://github.com/change-metrics/dhall-monocle
