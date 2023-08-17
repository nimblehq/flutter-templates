import 'package:{{project_name.snakeCase()}}/app/screens/home/home_view_model.dart';
import 'package:{{project_name.snakeCase()}}/app/screens/home/home_view_state.dart';
import 'package:{{project_name.snakeCase()}}/domain/usecases/get_users_use_case.dart';
import 'package:{{project_name.snakeCase()}}/main.dart';
import 'package:{{project_name.snakeCase()}}/di/di.dart';
import 'package:{{project_name.snakeCase()}}/gen/assets.gen.dart';
import 'package:{{project_name.snakeCase()}}/app/resources/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeViewState>((ref) {
  return HomeViewModel(
    getIt.get<GetUsersUseCase>(),
  );
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(homeViewModelProvider.notifier).getUsers();
  }

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
            const SizedBox(height: 8),
            Assets.svg.flutterLogo.svg(
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.hello),
            Text(
              FlutterConfig.get('SECRET'),
              style: const TextStyle(
                color: AppColors.nimblePrimaryBlue,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/$routePathSecondScreen'),
              child: const Text("Navigate to Second Screen"),
            ),
          ],
        ),
      ),
    );
  }
}
