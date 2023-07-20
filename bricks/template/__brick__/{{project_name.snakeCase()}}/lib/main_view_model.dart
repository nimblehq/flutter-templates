import 'dart:async';
import 'package:{{project_name.snakeCase()}}/main_view_state.dart';
import 'package:{{project_name.snakeCase()}}/usecases/base/base_use_case.dart';
import 'package:{{project_name.snakeCase()}}/usecases/user/get_users_use_case.dart';
import 'package:{{project_name.snakeCase()}}/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainViewModel extends StateNotifier<MainViewState> {
  final GetUsersUseCase _getUsersUseCase;

  final StreamController<List<User>?> _usersStream =
      StreamController();

  MainViewModel(
    this._getUsersUseCase,
  ) : super(const MainViewState.init());

  Future<void> getUsers() async {
    final result = await _getUsersUseCase.call();
    if (result is Success<List<User>>) {
      _usersStream.add(result.value);
    } else {
      //TODO handle error
    }
  }
}
