import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:{{project_name.snakeCase()}}/l10n/app_localizations.dart';
import 'package:{{project_name.snakeCase()}}/di/di.dart';
import 'package:{{project_name.snakeCase()}}/gen/assets.gen.dart';
import 'package:{{project_name.snakeCase()}}/app/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  final envFile =
      packageInfo.packageName.endsWith('.staging') ? '.env.staging' : '.env';
  await dotenv.load(fileName: envFile);
  await configureInjection();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

const routePathRootScreen = '/';
const routePathSecondScreen = 'second';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: routePathRootScreen,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: [
          GoRoute(
            path: routePathSecondScreen,
            builder: (BuildContext context, GoRouterState state) =>
                const SecondScreen(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: Assets.fonts.neuzeit,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second Screen"),
      ),
    );
  }
}
