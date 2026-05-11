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
- JDK 17 — Android Studio 2024.2+ ships with JDK 21, which breaks the bundled Gradle 7.5. In Android Studio: `Settings → Build Tools → Gradle → Gradle JDK` → select a JDK 17 install. Or run `flutter config --jdk-dir=/path/to/jdk-17`.
- An AI assistant (Claude, ChatGPT, etc.)

### Steps

1. Feed the spec files in `specs/` to an AI assistant. Start with `specs/generation-prompt.md` which references all other specs.

2. Provide your project parameters (see table above).

3. The AI generates a complete Flutter project following the architecture, patterns, and conventions documented in the specs.

4. Verify the generated project builds:

    ```bash
    cd /path/to/generated/project
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter analyze
    flutter test
    flutter build apk --debug --flavor staging -t lib/main.dart
    flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart  # macOS only
    ```

    If all pass, the project is ready. The AI handles substitutions correctly in practice (verified by benchmark across multiple models); native Flutter tooling is the gate for correctness.

### Spec files

| File | Content |
|------|---------|
| `specs/generation-prompt.md` | AI prompt with parameters, substitution map, and self-check |
| `specs/architecture-rules.md` | Architecture invariants (layer rules, patterns, conventions) |

### Golden reference

The `sample/` directory is the single source of truth. It is continuously validated by CI (`pub get`, `build_runner`, `analyze`, `test`, `flutter build apk`, `flutter build ios`). When `sample/` is green, substituted copies of it will build.

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
