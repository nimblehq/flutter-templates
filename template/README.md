# Flutter Templates

[![codecov](https://codecov.io/gh/nimblehq/flutter-templates/branch/main/graph/badge.svg?token=ATUNXDX218)](https://codecov.io/gh/nimblehq/flutter-templates)

All the templates that can be used to kick off a new Flutter application quickly.

## Usage

Clone the repository

`git clone git@github.com:nimblehq/flutter-templates.git`

## Prerequisite

- Flutter 2.10.3
- Flutter version manager (recommend): [fvm](https://fvm.app/)

## Getting Started

### Setup

- Create these `.env` files in the root directory according to the flavors and add the required
  environment variables into them. The example environment variable is in `.env.sample`.

  - Staging: `.env.staging`

  - Production: `.env`

- Run code generator

  - `$ fvm flutter packages pub run build_runner build --delete-conflicting-outputs`

### Run

- Run the app with the desire app flavor:

  - Staging: `$ fvm flutter run --flavor staging`

  - Production: `$ fvm flutter run --flavor production`

### Test

- Run unit testing:

  - `$ fvm flutter test`

- Run integration testing:

  - `$ fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/{test_file}.dart --flavor staging`

  - For example:

    `$ fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/my_home_page_test.dart --flavor staging`

- Code coverage integration:

  - CodeCov: for the private repository, we need to set up a [TeamBot](https://docs.codecov.com/docs/team-bot) in `codecov.yml`.

## License

This project is Copyright (c) 2014 and onwards. It is free software,
and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

## About

![Nimble](https://assets.nimblehq.co/logo/dark/logo-dark-text-160.png)

This project is maintained and funded by Nimble.

We love open source and do our part in sharing our work with the community!
See [our other projects][community] or [hire our team][hire] to help build your product.

[community]: https://github.com/nimblehq
[hire]: https://nimblehq.co/
