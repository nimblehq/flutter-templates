# Architecture Rules

Non-obvious constraints that cannot be inferred from reading `sample/` source code alone.

## Layer Dependency Rules

| Layer    | May import from       | Must NOT import from |
|----------|-----------------------|----------------------|
| Domain   | Dart core, packages   | Data, App            |
| Data     | Domain, Dart, packages | App                 |
| App      | Domain, Data, packages | —                   |

The domain layer is pure Dart — no Flutter SDK imports.

## Annotation Conventions

| Annotation        | Used on                          | Example                          |
|-------------------|----------------------------------|----------------------------------|
| `@Injectable()`   | Use cases                        | `GetUsersUseCase`                |
| `@LazySingleton`  | Repository implementations       | `CredentialRepositoryImpl`       |
| `@Singleton`      | Providers                        | `DioProvider`                    |
| `@module`         | DI modules (abstract classes)    | `NetworkModule`, `StorageModule` |
| `@injectableInit` | DI configuration function        | `configureInjection()` in di.dart|
| `@freezed`        | ViewState classes, NetworkExceptions | `HomeViewState`              |

## Naming Conventions

| File suffix            | Location                  | Purpose                    |
|------------------------|---------------------------|----------------------------|
| `*_screen.dart`        | `lib/app/screens/<name>/` | Screen widgets             |
| `*_view_model.dart`    | `lib/app/screens/<name>/` | StateNotifier view models  |
| `*_view_state.dart`    | `lib/app/screens/<name>/` | Freezed view state classes |
| `*_use_case.dart`      | `lib/domain/usecases/`    | Use case classes           |
| `*_repository.dart`    | `lib/domain/repositories/`| Abstract repository contracts |
| `*_repository_impl.dart`| `lib/data/repositories/` | Repository implementations |
| `*_response.dart`      | `lib/data/remote/models/responses/` | API response DTOs |

Screen directories must only contain files ending with `_screen.dart`, `_view_model.dart`, or `_view_state.dart`.

## What NOT to Generate

These files are created by `build_runner` or `flutter_gen` — never generate them:

- `*.g.dart` (json_serializable, retrofit, injectable)
- `*.freezed.dart` (freezed)
- `*.config.dart` (injectable)
- `*.mocks.dart` (mockito)
- `lib/gen/` directory (flutter_gen)

## main.dart Initialization Sequence

`main()` must call these in order:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `await FlutterConfig.loadEnvVariables()`
3. `await configureInjection()`
4. `runApp(ProviderScope(child: MyApp()))`
