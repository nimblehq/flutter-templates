# Flutter Templates

All the templates that can be used to kick off a new Flutter application quickly.

## Usage

Clone the repository

`git clone git@github.com:nimblehq/flutter-templates.git`

## Documentation

Checkout the [Wiki](https://github.com/nimblehq/flutter-templates/wiki) page to access the full documentation.

## Use the template

### Setup a new project

Before using the template, ensure that you have installed the following prerequisites on your system:

- [Mason CLI](https://pub.dev/packages/mason_cli) 0.1.0-dev.44

Follow these steps to set up a new project from the template:

- Fetch all required bricks by running the command:

  - `$ mason get`

- Generate the new project by running the following command:

  - `$ mason make template`

  > You can find the detailed information on `make` command options and usage in the [Mason documentation](https://github.com/felangel/mason/tree/master/packages/mason_cli#overview).

- Once the project is generated at `/{project_name}`, please refer to the [Getting Started](https://github.com/nimblehq/flutter-templates/tree/develop/bricks/template/__brick__/%7B%7Bproject_name.snakeCase()%7D%7D#getting-started) documentation to prepare your project for development.

That's it! You have now set up a new Flutter project using the template.

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
