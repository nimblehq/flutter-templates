# Flutter Templates

All the templates can be used to kick off a new Flutter project quickly.

## Features

- Supports __Android__ and __iOS__ platforms *(Web and Desktop are not yet supported)*.
- MVVM with __Clean Architecture__ and pre-built foundational components.
- [Pre-set environments](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D#setup): `Staging` and `Production`. Environment variables are supplied through `.env` files through [flutter_config](https://pub.dev/packages/flutter_config).
- Dependency Injection (DI), State Management, and Navigating with [get_it](https://pub.dev/packages/get_it) and [go_router](https://pub.dev/packages/go_router).
- Networking with [dio](https://pub.dev/packages/dio) and [retrofit](https://pub.dev/packages/retrofit), JSON serializing with [json_serializable](https://pub.dev/packages/json_serializable).
- [Localization](https://docs.flutter.dev/accessibility-and-localization/internationalization) integrated in [3 initial languages](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D/lib/l10n).
- [Testing](https://docs.flutter.dev/testing)-ready (unit, integration, and widget testing), [production and deployment](https://docs.flutter.dev/deployment)-ready (to Firebase, Play Store, TestFlight, and AppStore).
- Built-in [GitHub templates & CI/CD workflows](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D/.github) integrated with Github Action to perform static code analysis, test, build and deploy app builds to app distribution services or app stores.

### Optional

- Specify the default [JSON field renaming format with json_serializable](https://pub.dev/packages/json_serializable#build-configuration) between support values: none, kebab, snake, and pascal.
- Integrate permissions requesting & checking with [permission_handler](https://pub.dev/packages/permission_handler) and its necessary basic setup.
- [Code coverage integration](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D/codecov.yml) by `Codecov`.

## Documentation

Check out the [Wiki](https://github.com/nimblehq/flutter-templates/wiki) page to access the complete documentation.

## Use the template

### Setup a new project

Before using the template, ensure that you have installed the following prerequisites on your system:

- Flutter 3.10.5
- [Mason CLI](https://pub.dev/packages/mason_cli) 0.1.0-dev.44

Follow these steps to set up a new project from the template:

- Fetch all required bricks by running the command:

  `$ mason get`

- Generate the new project by running the following command:

  `$ mason make template`

  > You can find the detailed information on `make` command options and usage in the [Mason documentation](https://github.com/felangel/mason/tree/master/packages/mason_cli#overview).

- Once the project is generated at `/{project_name}`, please refer to the [Getting Started](https://github.com/nimblehq/flutter-templates/tree/develop/bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D#getting-started) documentation to make it ready for development.

That's it! You have now set up a new Flutter project using the template 🎉

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
