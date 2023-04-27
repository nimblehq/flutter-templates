# Flutter Templates

All the templates that can be used to kick off a new Flutter application quickly.

## Usage

Clone the repository

`git clone git@github.com:nimblehq/flutter-templates.git`

## Documentation

Checkout the [Wiki](https://github.com/nimblehq/flutter-templates/wiki) page to access the full documentation.

## Template Usage

Before using the template, make sure you have the following prerequisites installed on your system:

- [Mason CLI](https://pub.dev/packages/mason_cli) 0.1.0-dev.44
- Flutter 3.0.5
- Flutter version manager (recommend): [fvm](https://fvm.app/)

To set up a new project from the template, follow these steps:

- Open your terminal and run the following command:

  - `$ mason make template`

- Navigate to the newly created project using the following command:

  - `$ cd {project_name}`

- Clean the project by running the command:

  - `$ fvm flutter clean`

- Re-fetch the project by running the command:

  - `$ fvm flutter pub get`

- Run code generator using the command:
  - `$ fvm flutter packages pub run build_runner build --delete-conflicting-outputs`

- Once you have completed these steps, your new Flutter project is ready to develop!

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
