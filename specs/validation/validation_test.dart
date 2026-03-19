// Consolidated Validation Test
// Replaces: validate_parameters.sh, validate_structure.sh, invariant_architecture_test.dart
// Usage: Copy to project's test/ dir and run with SAMPLE_DIR env var:
//   SAMPLE_DIR=/path/to/sample flutter test test/validation_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectRoot = _findProjectRoot();
  final sampleDir = Platform.environment['SAMPLE_DIR'];

  // =========================================================
  // Group 1: Parameter Substitution (from validate_parameters.sh)
  // =========================================================
  group('Parameter Substitution', () {
    final paramsFile = File('$projectRoot/.generation_params');
    if (!paramsFile.existsSync()) return;

    final params = _readGenerationParams(paramsFile);
    final projectName = params['project_name'] ?? '';
    final packageName = params['package_name'] ?? '';
    final appName = params['app_name'] ?? '';
    final appVersion = params['app_version'] ?? '';
    final buildNumber = params['build_number'] ?? '';
    final jsonFieldRename = params['json_field_rename'] ?? '';
    final addPermissionHandler = params['add_permission_handler'] ?? 'false';

    test('project_name in pubspec.yaml', () {
      final content = File('$projectRoot/pubspec.yaml').readAsStringSync();
      expect(content, contains('name: $projectName'));
    });

    test('project_name in Dart imports', () {
      final importPattern = 'package:$projectName/';
      var count = 0;
      for (final dir in ['lib', 'test', 'integration_test']) {
        for (final file in _dartFilesIn('$projectRoot/$dir')) {
          if (file.readAsStringSync().contains(importPattern)) count++;
        }
      }
      expect(count, greaterThan(0),
          reason: "No Dart imports found using 'package:$projectName/'");
    });

    test('package_name in Android build.gradle', () {
      final content =
          File('$projectRoot/android/app/build.gradle').readAsStringSync();
      expect(content, contains('namespace "$packageName"'));
      expect(content, contains('applicationId "$packageName"'));
      expect(content, contains('applicationId "$packageName.staging"'));
    });

    test('package_name in iOS Constants.rb', () {
      final content = File('$projectRoot/ios/fastlane/Constants/Constants.rb')
          .readAsStringSync();
      expect(content, contains("'$packageName.staging'"));
      expect(content, contains("'$packageName'"));
    });

    test('app_name in iOS Constants.rb', () {
      final content = File('$projectRoot/ios/fastlane/Constants/Constants.rb')
          .readAsStringSync();
      expect(content, contains("'$appName Staging'"));
      expect(content, contains("'$appName'"));
    });

    test('app_name in iOS project.pbxproj', () {
      final content = File('$projectRoot/ios/Runner.xcodeproj/project.pbxproj')
          .readAsStringSync();
      expect(content, contains('APP_DISPLAY_NAME = "$appName Staging"'));
      expect(content, contains('APP_DISPLAY_NAME = "$appName"'));
    });

    test('app_name in integration test', () {
      final content = File('$projectRoot/integration_test/utils/test_util.dart')
          .readAsStringSync();
      expect(content, contains("appName: '$appName testing'"));
    });

    test('version in pubspec.yaml', () {
      final content = File('$projectRoot/pubspec.yaml').readAsStringSync();
      expect(content, contains('version: $appVersion+$buildNumber'));
    });

    test('json_field_rename in build.yaml', () {
      final content = File('$projectRoot/build.yaml').readAsStringSync();
      expect(content, contains('field_rename: "$jsonFieldRename"'));
    });

    if (addPermissionHandler == 'true') {
      test('permission_handler dependency present', () {
        final content = File('$projectRoot/pubspec.yaml').readAsStringSync();
        expect(content, contains('permission_handler:'));
      });

      test('permission_wrapper.dart exists', () {
        expect(
          File('$projectRoot/lib/utils/wrappers/permission_wrapper.dart')
              .existsSync(),
          isTrue,
        );
      });

      test('permission build configurations in Podfile', () {
        final content = File('$projectRoot/ios/Podfile').readAsStringSync();
        expect(content, contains('GCC_PREPROCESSOR_DEFINITIONS'));
      });
    } else {
      test('permission_handler dependency absent', () {
        final content = File('$projectRoot/pubspec.yaml').readAsStringSync();
        expect(content, isNot(contains('permission_handler:')));
      });

      test('permission_wrapper.dart does not exist', () {
        expect(
          File('$projectRoot/lib/utils/wrappers/permission_wrapper.dart')
              .existsSync(),
          isFalse,
        );
      });
    }
  });

  // =========================================================
  // Group 2: Structure (from validate_structure.sh)
  // =========================================================
  group('Structure', () {
    if (sampleDir == null || sampleDir.isEmpty) return;

    test('Required directories exist', () {
      final missing = <String>[];

      final sampleLibDir = Directory('$sampleDir/lib');
      if (sampleLibDir.existsSync()) {
        for (final entity in sampleLibDir.listSync(recursive: true)) {
          if (entity is! Directory) continue;
          if (entity.path.contains('/.')) continue;
          final relative = entity.path.substring(sampleDir.length + 1);
          if (relative.startsWith('lib/gen')) continue;
          if (_isConditional(relative)) continue;
          if (!Directory('$projectRoot/$relative').existsSync()) {
            missing.add(relative);
          }
        }
      }

      if (!Directory('$projectRoot/test').existsSync()) missing.add('test');
      if (!Directory('$projectRoot/integration_test').existsSync()) {
        missing.add('integration_test');
      }

      expect(missing, isEmpty,
          reason: 'Missing directories:\n${missing.join('\n')}');
    });

    test('Required lib/ source files exist', () {
      final missing = <String>[];
      for (final file in _dartFilesIn('$sampleDir/lib')) {
        final relative = file.path.substring(sampleDir.length + 1);
        if (relative.startsWith('lib/gen/')) continue;
        if (_isGenerated(file.path)) continue;
        if (_isConditional(relative)) continue;
        if (!File('$projectRoot/$relative').existsSync()) {
          missing.add(relative);
        }
      }
      expect(missing, isEmpty,
          reason: 'Missing lib files:\n${missing.join('\n')}');
    });

    test('Localization files exist', () {
      final missing = <String>[];
      final l10nDir = Directory('$sampleDir/lib/l10n');
      if (l10nDir.existsSync()) {
        for (final file in l10nDir.listSync()) {
          if (file is File && file.path.endsWith('.arb')) {
            final relative = file.path.substring(sampleDir.length + 1);
            if (!File('$projectRoot/$relative').existsSync()) {
              missing.add(relative);
            }
          }
        }
      }
      expect(missing, isEmpty,
          reason: 'Missing l10n files:\n${missing.join('\n')}');
    });

    test('Root config files exist', () {
      final rootFiles = [
        'pubspec.yaml',
        'build.yaml',
        'analysis_options.yaml',
        '.env.sample',
        '.gitignore',
      ];
      final missing = rootFiles
          .where((f) => !File('$projectRoot/$f').existsSync())
          .toList();
      expect(missing, isEmpty,
          reason: 'Missing root files:\n${missing.join('\n')}');
    });

    test('Test files exist', () {
      final missing = <String>[];
      for (final file in _dartFilesIn('$sampleDir/test')) {
        if (_isGenerated(file.path)) continue;
        final relative = file.path.substring(sampleDir.length + 1);
        if (!File('$projectRoot/$relative').existsSync()) {
          missing.add(relative);
        }
      }
      expect(missing, isEmpty,
          reason: 'Missing test files:\n${missing.join('\n')}');
    });

    test('Integration test files exist', () {
      final missing = <String>[];
      for (final file in _dartFilesIn('$sampleDir/integration_test')) {
        final relative = file.path.substring(sampleDir.length + 1);
        if (!File('$projectRoot/$relative').existsSync()) {
          missing.add(relative);
        }
      }
      expect(missing, isEmpty,
          reason: 'Missing integration test files:\n${missing.join('\n')}');
    });
  });

  // =========================================================
  // Group 3: Naming Conventions (from validate_structure.sh)
  // =========================================================
  group('Naming Conventions', () {
    test('All .dart filenames are snake_case', () {
      final violations = <String>[];
      for (final file in _dartFilesIn('$projectRoot/lib')) {
        final basename = file.uri.pathSegments.last;
        if (basename.contains(RegExp(r'[A-Z]'))) {
          violations.add(file.path);
        }
      }
      expect(violations, isEmpty,
          reason: 'Non-snake_case filenames:\n${violations.join('\n')}');
    });

    test('Screen files follow naming convention', () {
      final screensDir = Directory('$projectRoot/lib/app/screens');
      if (!screensDir.existsSync()) return;

      final violations = <String>[];
      for (final file in _dartFilesIn(screensDir.path)) {
        final basename = file.uri.pathSegments.last;
        if (_isGenerated(basename)) continue;
        if (!basename.endsWith('_screen.dart') &&
            !basename.endsWith('_view_model.dart') &&
            !basename.endsWith('_view_state.dart')) {
          violations.add(basename);
        }
      }
      expect(violations, isEmpty,
          reason:
              'Screen files must end with _screen.dart, _view_model.dart, or _view_state.dart:\n${violations.join('\n')}');
    });

    test('UseCase files end with _use_case.dart', () {
      final usecaseDir = Directory('$projectRoot/lib/domain/usecases');
      if (!usecaseDir.existsSync()) return;

      final violations = <String>[];
      for (final file in _dartFilesIn(usecaseDir.path)) {
        final basename = file.uri.pathSegments.last;
        if (file.path.contains('/base/')) continue;
        if (!basename.endsWith('_use_case.dart')) {
          violations.add(basename);
        }
      }
      expect(violations, isEmpty,
          reason:
              'UseCase files must end with _use_case.dart:\n${violations.join('\n')}');
    });

    test('Repository impl files end with _impl.dart', () {
      final repoDir = Directory('$projectRoot/lib/data/repositories');
      if (!repoDir.existsSync()) return;

      final violations = <String>[];
      for (final file in _dartFilesIn(repoDir.path)) {
        final basename = file.uri.pathSegments.last;
        if (_isGenerated(basename)) continue;
        if (!basename.endsWith('_impl.dart')) {
          violations.add(basename);
        }
      }
      expect(violations, isEmpty,
          reason:
              'Data repository files must end with _impl.dart:\n${violations.join('\n')}');
    });

    test('Test mirror exists for each screen', () {
      final screensDir = Directory('$projectRoot/lib/app/screens');
      if (!screensDir.existsSync()) return;

      final violations = <String>[];
      for (final entity in screensDir.listSync()) {
        if (entity is! Directory) continue;
        final screenName =
            entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
        final testMirror =
            Directory('$projectRoot/test/app/screens/$screenName');
        if (!testMirror.existsSync()) {
          violations.add('Missing test mirror: test/app/screens/$screenName/');
        } else {
          final hasTests = testMirror
              .listSync(recursive: true)
              .whereType<File>()
              .any((f) => f.path.endsWith('_test.dart'));
          if (!hasTests) {
            violations
                .add('No *_test.dart files in test/app/screens/$screenName/');
          }
        }
      }
      expect(violations, isEmpty,
          reason: 'Test mirror issues:\n${violations.join('\n')}');
    });
  });

  // =========================================================
  // Group 4: Architecture Invariants (from invariant_architecture_test.dart)
  // =========================================================
  group('Architecture Invariants', () {
    group('Import Rules', () {
      test('Domain layer does not import from data or app layers', () {
        final violations = <String>[];
        for (final file in _dartFilesIn('$projectRoot/lib/domain')) {
          final lines = file.readAsStringSync().split('\n');
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (_isImportLine(line) &&
                (_importsLayer(line, '/data/') ||
                    _importsLayer(line, '/app/'))) {
              violations.add('${file.path}:${i + 1}: $line');
            }
          }
        }
        expect(violations, isEmpty,
            reason:
                'Domain layer must not import from data/ or app/:\n${violations.join('\n')}');
      });

      test('Data layer does not import from app layer', () {
        final violations = <String>[];
        for (final file in _dartFilesIn('$projectRoot/lib/data')) {
          final lines = file.readAsStringSync().split('\n');
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (_isImportLine(line) && _importsLayer(line, '/app/')) {
              violations.add('${file.path}:${i + 1}: $line');
            }
          }
        }
        expect(violations, isEmpty,
            reason:
                'Data layer must not import from app/:\n${violations.join('\n')}');
      });
    });

    group('UseCase Pattern', () {
      test('Use case files extend UseCase or NoParamsUseCase', () {
        final useCaseDir = Directory('$projectRoot/lib/domain/usecases');
        if (!useCaseDir.existsSync()) {
          fail('lib/domain/usecases/ directory does not exist');
        }

        final useCaseFiles = _dartFilesIn(useCaseDir.path)
            .where((f) =>
                !f.path.contains('/base/') &&
                f.path.endsWith('_use_case.dart') &&
                !f.path.endsWith('.g.dart'))
            .toList();

        for (final file in useCaseFiles) {
          final content = file.readAsStringSync();
          expect(
            content.contains('extends UseCase<') ||
                content.contains('extends NoParamsUseCase<'),
            isTrue,
            reason: '${file.path} must extend UseCase or NoParamsUseCase',
          );
        }
      });

      test('Use case files are annotated with @Injectable()', () {
        final useCaseDir = Directory('$projectRoot/lib/domain/usecases');
        if (!useCaseDir.existsSync()) return;

        final useCaseFiles = _dartFilesIn(useCaseDir.path)
            .where((f) =>
                !f.path.contains('/base/') &&
                f.path.endsWith('_use_case.dart') &&
                !f.path.endsWith('.g.dart'))
            .toList();

        for (final file in useCaseFiles) {
          final content = file.readAsStringSync();
          expect(content.contains('@Injectable()'), isTrue,
              reason: '${file.path} must be annotated with @Injectable()');
        }
      });
    });

    group('Repository Pattern', () {
      test('Domain repositories are abstract classes', () {
        final repoDir = Directory('$projectRoot/lib/domain/repositories');
        if (!repoDir.existsSync()) {
          fail('lib/domain/repositories/ directory does not exist');
        }

        for (final file in _dartFilesIn(repoDir.path)
            .where((f) => !f.path.endsWith('.g.dart'))) {
          final content = file.readAsStringSync();
          expect(content.contains('abstract class'), isTrue,
              reason: '${file.path} must contain an abstract class');
        }
      });

      test('Data repositories use @LazySingleton annotation', () {
        final repoDir = Directory('$projectRoot/lib/data/repositories');
        if (!repoDir.existsSync()) {
          fail('lib/data/repositories/ directory does not exist');
        }

        for (final file in _dartFilesIn(repoDir.path)
            .where((f) => !f.path.endsWith('.g.dart'))) {
          final content = file.readAsStringSync();
          expect(content.contains('@LazySingleton'), isTrue,
              reason: '${file.path} must use @LazySingleton annotation');
        }
      });
    });

    group('ViewModel Pattern', () {
      test('ViewModel files extend StateNotifier', () {
        for (final file in _dartFilesIn('$projectRoot/lib/app').where((f) =>
            f.path.endsWith('_view_model.dart') &&
            !f.path.endsWith('.g.dart'))) {
          final content = file.readAsStringSync();
          expect(content.contains('extends StateNotifier<'), isTrue,
              reason: '${file.path} must extend StateNotifier');
        }
      });
    });

    group('ViewState Pattern', () {
      test('ViewState files use @freezed annotation', () {
        for (final file in _dartFilesIn('$projectRoot/lib/app').where((f) =>
            f.path.endsWith('_view_state.dart') &&
            !f.path.endsWith('.freezed.dart'))) {
          final content = file.readAsStringSync();
          expect(content.contains('@freezed'), isTrue,
              reason: '${file.path} must use @freezed annotation');
        }
      });
    });

    group('DI Setup', () {
      test('di.dart has @injectableInit and GetIt.instance', () {
        final diFile = File('$projectRoot/lib/di/di.dart');
        expect(diFile.existsSync(), isTrue,
            reason: 'lib/di/di.dart must exist');
        final content = diFile.readAsStringSync();
        expect(content.contains('@injectableInit'), isTrue,
            reason: 'di.dart must contain @injectableInit');
        expect(content.contains('GetIt.instance'), isTrue,
            reason: 'di.dart must reference GetIt.instance');
      });
    });

    group('NetworkExceptions', () {
      test('Uses @freezed and has fromDioException', () {
        final file =
            File('$projectRoot/lib/domain/exceptions/network_exceptions.dart');
        expect(file.existsSync(), isTrue,
            reason: 'network_exceptions.dart must exist');
        final content = file.readAsStringSync();
        expect(content.contains('@freezed'), isTrue,
            reason: 'NetworkExceptions must use @freezed annotation');
        expect(content.contains('fromDioException'), isTrue,
            reason:
                'NetworkExceptions must have fromDioException static method');
      });
    });

    group('App Initialization', () {
      test('main.dart contains required initialization sequence', () {
        final mainFile = File('$projectRoot/lib/main.dart');
        expect(mainFile.existsSync(), isTrue,
            reason: 'lib/main.dart must exist');
        final content = mainFile.readAsStringSync();
        expect(content.contains('WidgetsFlutterBinding.ensureInitialized()'),
            isTrue,
            reason:
                'main.dart must call WidgetsFlutterBinding.ensureInitialized()');
        expect(content.contains('FlutterConfig.loadEnvVariables()'), isTrue,
            reason: 'main.dart must call FlutterConfig.loadEnvVariables()');
        expect(content.contains('configureInjection()'), isTrue,
            reason: 'main.dart must call configureInjection()');
        expect(content.contains('ProviderScope'), isTrue,
            reason: 'main.dart must use ProviderScope for Riverpod');
      });
    });
  });
}

// --- Helper functions ---

String _findProjectRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) return Directory.current.path;
    dir = parent;
  }
  return dir.path;
}

List<File> _dartFilesIn(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.contains('/.'))
      .toList();
}

bool _isImportLine(String line) {
  if (line.startsWith('//') || line.startsWith('///')) return false;
  return line.startsWith('import ') && line.contains("'");
}

bool _importsLayer(String line, String layerPath) {
  return line.contains(layerPath);
}

Map<String, String> _readGenerationParams(File file) {
  final params = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final eqIndex = line.indexOf('=');
    if (eqIndex < 0) continue;
    final key = line.substring(0, eqIndex).trim();
    final value = line.substring(eqIndex + 1).trim();
    params[key] = value;
  }
  return params;
}

bool _isGenerated(String filename) {
  final basename = filename.split('/').last;
  return basename.endsWith('.g.dart') ||
      basename.endsWith('.freezed.dart') ||
      basename.endsWith('.config.dart') ||
      basename.endsWith('.mocks.dart');
}

bool _isConditional(String path) {
  return path.startsWith('lib/utils');
}
