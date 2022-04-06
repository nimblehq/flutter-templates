# Flutter Templates

All the templates that can be used to kick off a new Flutter application quickly.

## Usage

Clone the repository

`git clone git@github.com:nimblehq/flutter_templates.git`

## Use the template

### Setup a new project

- To set up a new project from the template, run the command:

  - `$ make run PACKAGE_NAME={com.your.package} PROJECT_NAME={your_project_name} APP_NAME="{Your App Name}"`

  - Then clean the project: `$ fvm flutter clean`

  - Re-fetch the project: `$ fvm flutter pub get`

- Parameters detail:

  | Parameter name | Is mandatory | Description                                                                     |
  | :------------- | :----------: | :------------------------------------------------------------------------------ |
  | PACKAGE_NAME   |     Yes      | The application package name. The naming convention follows `com.your.package`  |
  | PROJECT_NAME   |     Yes      | The application project name. The naming convention follows `your_project_name` |
  | APP_NAME       |     Yes      | The application name.                                                           |
  | APP_VERSION    |      No      | The app version that is set when initialize the project. Default is `0.1.0`     |
  | BUILD_NUMBER   |      No      | The build number that is set when initialize the project. Default is `1`        |

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
