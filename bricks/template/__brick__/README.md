# {{app_name.titleCase()}}

[![codecov](https://codecov.io/gh/nimblehq/{{project_name.paramCase()}}/branch/main/graph/badge.svg?token=ATUNXDX218)](https://codecov.io/gh/nimblehq/{{project_name.paramCase()}})

## Prerequisite

- Flutter 3.41.6
- Flutter version manager (recommend): [fvm](https://fvm.app/)

This project needs **Dart 3.8+**. If `flutter pub get` reports Dart **3.7.x** or an SDK constraint error, switch to Flutter **3.41.6** (e.g. `fvm use 3.41.6`) and run `fvm flutter pub get` again.

## Getting Started

### Setup

- Update the bundled environment files in the root directory with the required
environment variables for each flavor.

  - Staging: `.env.staging`
  - Production: `.env`

- The bundled `.env` and `.env.staging` values are **public sample config only**. Never place real API keys/tokens/secrets in Flutter assets; keep secrets server-side or in secure runtime delivery. See flutter_dotenv security guidance: https://pub.dev/packages/flutter_dotenv

- To make the Android release build,

  - put the `release.keystore` at the `android/config` folder,

  - create the `signing.properties` file to provide keystore credentials in the `android` folder. The example file is `signing.properties.sample`.

### Run

- Run code generator for JSON models, DI dependencies, etc:

  - `$ fvm flutter packages pub run build_runner build --delete-conflicting-outputs`

- Run the app with the desired app flavor:

  - `$ fvm flutter run --flavor staging`
  - `$ fvm flutter run --flavor production`

- Check code formatting & static code analyzing:

  - `$ dart format --set-exit-if-changed .`
  - `$ fvm flutter analyze .`

### Test

- Run unit testing:

  - `$ fvm flutter test`
  - `$ fvm flutter test --machine --coverage`

- Run integration testing:

  - `$ fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/{test_file}.dart --flavor staging`

  - For example:

    `$ fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/my_home_page_test.dart --flavor staging`

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
