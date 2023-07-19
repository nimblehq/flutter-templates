import 'package:{{project_name.snakeCase()}}/main_view_state.dart';
import 'package:{{project_name.snakeCase()}}/usecases/user/get_users_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainViewModel extends StateNotifier<MainViewState> {
  final GetUsersUseCase _getUsersUseCase;

  MainViewModel(
    this._getUsersUseCase,
  ) : super(const MainViewState.init());
}
