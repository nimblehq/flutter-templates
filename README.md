# Flutter Templates

Architectural specs and a golden reference project for generating new Flutter projects with AI.

## Features

- Supports __Android__ and __iOS__ platforms *(Web and Desktop are not yet supported)*.
- [__Clean Architecture__](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) with `MVVM` and pre-built foundational components.
- Pre-set environments: `Staging` and `Production`. Environment variables are supplied through `.env` files through [flutter_config](https://pub.dev/packages/flutter_config).
- Dependency Injection (DI), State Management, and Navigating with [get_it](https://pub.dev/packages/get_it), [flutter_riverpod](https://pub.dev/packages/flutter_riverpod), and [go_router](https://pub.dev/packages/go_router).
- Networking with [dio](https://pub.dev/packages/dio) and [retrofit](https://pub.dev/packages/retrofit), JSON serializing with [json_serializable](https://pub.dev/packages/json_serializable).
- Integrated local [secure storage](https://pub.dev/packages/flutter_secure_storage).
- [Localization](https://docs.flutter.dev/accessibility-and-localization/internationalization) integrated in 3 initial languages.
- [Testing](https://docs.flutter.dev/testing)-ready (unit, integration, and widget testing), [production and deployment](https://docs.flutter.dev/deployment)-ready (to Firebase, Play Store, TestFlight, and AppStore).
- Built-in [GitHub templates & CI/CD workflows](sample/.github) integrated with GitHub Actions to perform static code analysis, test, build and deploy app builds to app distribution services or app stores.

### Customizable parameters

When generating a new project, provide these parameters to the AI:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `project_name` | Dart package name (snake_case) | `my_app` |
| `package_name` | Android/iOS bundle identifier | `co.nimblehq.myapp` |
| `app_name` | Display name | `My App` |
| `app_version` | Initial version | `0.1.0` |
| `build_number` | Initial build number | `1` |
| `json_field_rename_format` | json_serializable field rename | `snake` |
| `add_permission_handler` | Include permission_handler setup | `true` / `false` |

## Generate a new project

### Prerequisites

- Flutter SDK (>= 3.5.0)
- An AI assistant (Claude, ChatGPT, etc.)

### Steps

1. Feed the spec files in `specs/` to an AI assistant. Start with `specs/generation-prompt.md` which references all other specs.

2. Provide your project parameters (see table above).

3. The AI generates a complete Flutter project following the architecture, patterns, and conventions documented in the specs.

4. Validate the generated project:

    ```bash
    bash specs/validation/validate_all.sh /path/to/generated/project
    ```

5. The validation pipeline checks 4 layers:
   - **Layer 1:** Structure (directories, files, naming conventions)
   - **Layer 2:** Static analysis (`pub get`, `build_runner`, `format`, `analyze`)
   - **Layer 3:** Architecture invariants (import rules, patterns, DI setup)
   - **Layer 3b:** Tests (unit and widget tests pass)

### Spec files

| File | Content |
|------|---------|
| `specs/architecture.md` | 3-layer rules, UseCase/Result, Repository, ViewModel, error flow |
| `specs/dependency-injection.md` | GetIt + Injectable setup, modules, providers, interceptors |
| `specs/networking.md` | Dio + Retrofit, response mapping, token refresh, env config |
| `specs/project-structure.md` | Directory layout, naming conventions, generated files |
| `specs/dependencies.md` | Package list with versions, build.yaml, analysis_options |
| `specs/testing.md` | Mockito patterns, ProviderContainer, integration test utilities |
| `specs/cicd.md` | Workflows, flavor mapping, Fastlane, codecov |
| `specs/generation-prompt.md` | Master AI prompt with parameters and substitution map |
| `specs/validation.md` | Validation pipeline overview |

### Golden reference

The `sample/` directory contains a reference project validated by CI. AI output is compared against these patterns.

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
