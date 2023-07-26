import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:{{project_name.snakeCase()}}/usecases/base/base_use_case.dart';
import 'package:{{project_name.snakeCase()}}/usecases/user/get_users_use_case.dart';
import 'package:{{project_name.snakeCase()}}/model/user.dart';

import '../../mocks/generate_mocks.mocks.dart';
import '../../mocks/response/user_response_mocks.dart';

void main() {
  group('GetUsersUseCase', () {
    late MockCredentialRepository mockRepository;
    late GetUsersUseCase getUsersUseCase;

    setUp(() {
      mockRepository = MockCredentialRepository();
      getUsersUseCase = GetUsersUseCase(mockRepository);
    });

    test('When getting users successfully, it returns Success result',
        () async {
      final expectedResult = [User.fromUserResponse(UserResponseMocks.mock())];
      when(mockRepository.getUsers()).thenAnswer((_) async => expectedResult);
      final result = await getUsersUseCase.call();

      expect(result, isA<Success>());
      expect((result as Success).value, expectedResult);
    });
  });
}
