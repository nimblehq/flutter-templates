import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TestUtil {
  static Widget startAppWith(Widget widget) {
    _initDependencies();
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: widget,
    );
  }

  static void _initDependencies() {
    PackageInfo.setMockInitialValues(
        appName: 'Flutter templates testing',
        packageName: '',
        version: '',
        buildNumber: '',
        buildSignature: '');
    FlutterConfig.loadValueForTesting({'SECRET': 'This is only for testing'});
  }
}
