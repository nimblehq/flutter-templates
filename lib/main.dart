import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_templates/gen/assets.gen.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: Assets.fonts.neuzeit,
      ),
      home: MyHomePage(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(snapshot.data?.appName ?? "")
                  : SizedBox.shrink();
            }),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 24,),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Image.asset(Assets.images.nimbleLogo.path, fit: BoxFit.fitWidth),
            ),
            SizedBox(height: 24,),
            Text(AppLocalizations.of(context)!.hello),
            Text(FlutterConfig.get('SECRET'), style: TextStyle(color: Colors.black, fontSize: 24))
          ],
        ),
      ),
    );
  }
}
