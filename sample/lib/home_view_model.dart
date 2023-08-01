import 'dart:async';
import 'package:sample/home_view_state.dart';
import 'package:sample/usecases/base/base_use_case.dart';
import 'package:sample/usecases/user/get_users_use_case.dart';
import 'package:sample/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeViewModel extends StateNotifier<HomeViewState> {
  final GetUsersUseCase _getUsersUseCase;

  HomeViewModel(
    this._getUsersUseCase,
  ) : super(const HomeViewState.init());

  final StreamController<List<User>> _usersStream = StreamController();

  Stream<List<User>> get usersStream => _usersStream.stream;

  Future<void> getUsers() async {
    final result = await _getUsersUseCase.call();
    if (result is Success<List<User>>) {
      _usersStream.add(result.value);
    } else {
      // TODO handle error
    }
  }
}
