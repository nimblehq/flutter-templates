import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_templates/gen/assets.gen.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // TODO: implement Routes then remove `home: MyHomePage()` and use initialRoute instead.
  final String initialRoute;

  const MyApp({
    Key? key,
    this.initialRoute = '/',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: Assets.fonts.neuzeit,
      ),
      home: const MyHomePage(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(snapshot.data?.appName ?? "")
                  : const SizedBox.shrink();
            }),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Image.asset(
                Assets.images.nimbleLogo.path,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.hello),
            Text(
              FlutterConfig.get('SECRET'),
              style: const TextStyle(color: Colors.black, fontSize: 24),
            )
          ],
        ),
      ),
    );
  }
}
