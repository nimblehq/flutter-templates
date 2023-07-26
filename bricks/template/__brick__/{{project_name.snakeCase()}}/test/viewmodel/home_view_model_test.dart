import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:{{project_name.snakeCase()}}/usecases/base/base_use_case.dart';
import 'package:{{project_name.snakeCase()}}/home_view_model.dart';
import 'package:{{project_name.snakeCase()}}/main.dart';
import 'package:{{project_name.snakeCase()}}/model/user.dart';

import '../mocks/generate_mocks.mocks.dart';
import '../mocks/response/user_response_mocks.dart';

void main() {
  group("HomeViewModelTest", () {
    late ProviderContainer container;
    late MockGetUsersUseCase mockGetUsersUseCase;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockGetUsersUseCase = MockGetUsersUseCase();

      container = ProviderContainer(
        overrides: [
          homeViewModelProvider.overrideWith((ref) => HomeViewModel(
                mockGetUsersUseCase,
              )),
        ],
      );
      addTearDown(container.dispose);
    });

    test('When calling get user list successfully, it returns correctly',
        () async {
      final expectedResult = [User.fromUserResponse(UserResponseMocks.mock())];
      when(mockGetUsersUseCase.call())
          .thenAnswer((_) async => Success(expectedResult));

      final usersStream =
          container.read(homeViewModelProvider.notifier).usersStream;
      expect(usersStream, emitsInOrder([expectedResult]));

      container.read(homeViewModelProvider.notifier).getUsers();
    });
  });
}
