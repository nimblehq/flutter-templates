# Flutter Templates

All the templates can be used to kick off a new Flutter project quickly.

## Features

- Supports __Android__ and __iOS__ platforms *(Web and Desktop are not yet supported)*.
- [__Clean Architecture__](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) with `MVVM` and pre-built foundational components.
- [Pre-set environments](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D#setup): `Staging` and `Production`. Environment variables are supplied through `.env` files through [flutter_config](https://pub.dev/packages/flutter_config).
- Dependency Injection (DI), State Management, and Navigating with [get_it](https://pub.dev/packages/get_it), [flutter_riverpod](https://pub.dev/packages/flutter_riverpod), and [go_router](https://pub.dev/packages/go_router).
- Networking with [dio](https://pub.dev/packages/dio) and [retrofit](https://pub.dev/packages/retrofit), JSON serializing with [json_serializable](https://pub.dev/packages/json_serializable).
- Integrated local [secure storage](https://pub.dev/packages/flutter_secure_storage).
- [Localization](https://docs.flutter.dev/accessibility-and-localization/internationalization) integrated in [3 initial languages](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D/lib/l10n).
- [Testing](https://docs.flutter.dev/testing)-ready (unit, integration, and widget testing), [production and deployment](https://docs.flutter.dev/deployment)-ready (to Firebase, Play Store, TestFlight, and AppStore).
- Built-in [GitHub templates & CI/CD workflows](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D/.github) integrated with GitHub Actions to perform static code analysis, test, build and deploy app builds to app distribution services or app stores.

### Optional (enable by [generator command parameters](#set-up-a-new-project))

- Specify the default [JSON field renaming format with json_serializable](https://pub.dev/packages/json_serializable#build-configuration) between support values: none, kebab, snake, and pascal.
- Integrate permissions requesting & checking with [permission_handler](https://pub.dev/packages/permission_handler) and its necessary basic setup.
- [Code coverage integration](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D/codecov.yml) by `Codecov`.

## Use the template

### Prerequisites

Before using the template, ensure that you have installed the following prerequisites on your system:

- Flutter 3.10.5
- [Mason CLI](https://pub.dev/packages/mason_cli) 0.1.0-dev.44

### Set up a new project

Follow these steps to set up a new project from the template:

1. Use [Use this template](https://github.com/new?template_name=flutter-templates&template_owner=nimblehq) feature to create your new project repository or clone this template repository to your local machine.

2. Fetch all required bricks by running the command:

    `$ mason get`

3. Generate the new project by running the following command with [supported arguments](bricks/template/brick.yaml):

    `$ mason make template` and then provide necessary inputs.

    or

    `$ mason make template -c mason-config.json` to provide necessary inputs via a JSON file, e.g., [mason-config.json](mason-config.json) for the sample project.

Once the project is generated, please refer to the [Getting Started](bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D#getting-started) documentation to make it ready for development.

That's it! You have now set up a new Flutter project using the template 🎉

> **Note**
>
> The script generates all project files to the current working folder as default and cleans up all template stuff in the end. Run it with [Custom Output Directory](https://github.com/felangel/mason/tree/master/packages/mason_cli#custom-output-directory) to set a custom output folder and keep the template stuff to rerun.
>
> `$ mason make template -c mason-config.json -o my_flutter_project`
>
> You can find detailed information on `make` command options and usage in the [Mason documentation](https://github.com/felangel/mason/tree/master/packages/mason_cli#overview).

## Documentation

Check out the [Wiki](https://github.com/nimblehq/flutter-templates/wiki) page to access the complete documentation.

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
