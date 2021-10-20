# Flutter Templates

All the templates that can be used to kick off a new Flutter application quickly.

## Usage

Clone the repository

`git clone git@github.com:nimblehq/flutter_templates.git`

## Prerequisite
- Flutter 2.2
- Flutter version manager (recommend): [fvm](https://fvm.app/)

## Getting Started

- Create these env files in the root directory according to the flavors and add the required environment variables into them. The example environment variable is in `.env.sample`.

  - Staging: `.env.staging`

  - Production: `.env`

- Run the app with the desire app flavor:

  - Staging: `$ fvm flutter run --flavor staging`

  - Production: `$ fvm flutter run --flavor production`

- Run unit testing:

  - `$ fvm flutter test .`

- Run integration testing:

  - `$ fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/{test_file}.dart --flavor staging`

  - For example:

    `$ fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/my_home_page_test.dart --flavor staging`

- Generate assets folder
  
  - `$ fvm flutter packages pub run build_runner build --delete-conflicting-outputs`

## Use the template

### Setup a new project

- To set up a new project from the template, run the command:

  - `$ make init PACKAGE_NAME=${com.example} PROJECT_NAME=${project_name}`

  - Then clean the project: `$ fvm flutter clean`

  - Re-fetch the project: `$ fvm flutter pub get`

- The project uses the package name and the project name of the template if `PACKAGE_NAME` and `PROJECT_NAME` aren't specified.

- For more supporting commands, run:

  - `$ make`

  - Or `$ make help`

### Maintain the template

- While implementing a new feature or fixing an issue, there may be a chance to break the functions of `setup.py` script due to the change in the codebase (update the app name, the package directory, etc.).

- To make sure that the `setup.py` script is still working correctly, run the command:

  - `$ make test`

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
