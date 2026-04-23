import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:{{project_name.snakeCase()}}/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:{{project_name.snakeCase()}}/main.dart';

class TestUtil {
  /// This is useful when we test the whole app with the real configs(styling,
  /// localization, routes, etc)
  static Widget pumpWidgetWithRealApp(String initialRoute) {
    _initDependencies();
    return MyApp();
  }

  /// We normally use this function to test a specific [widget] without
  /// considering much about theming.
  static Widget pumpWidgetWithShellApp(Widget widget) {
    _initDependencies();
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: widget,
    );
  }

  static void _initDependencies() {
    PackageInfo.setMockInitialValues(
      appName: '{{app_name.titleCase()}} testing',
      packageName: '{{package_name.dotCase()}}',
      version: '',
      buildNumber: '',
      buildSignature: '',
    );
    dotenv.loadFromString(
      envString: [
        'SAMPLE_CONFIG=This is only for testing',
        'REST_API_ENDPOINT=https://example.com',
      ].join('\n'),
    );
  }
}
