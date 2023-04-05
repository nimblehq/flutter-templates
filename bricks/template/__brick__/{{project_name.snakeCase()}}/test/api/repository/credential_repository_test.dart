import 'package:{{project_name.snakeCase()}}/api/exception/network_exceptions.dart';
import 'package:{{project_name.snakeCase()}}/api/repository/credential_repository.dart';
import 'package:{{project_name.snakeCase()}}/model/response/user_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  group('CredentialRepository', () {
    MockApiService mockApiService = MockApiService();
    late CredentialRepository repository;

    setUp(() {
      repository = CredentialRepositoryImpl(mockApiService);
    });
    test(
        "When getting user list successfully, it emits corresponding user list",
        () async {
      when(mockApiService.getUsers()).thenAnswer((_) async => [
            UserResponse('test@email.com', 'test_user'),
          ]);

      final result = await repository.getUsers();
      expect(result.length, 1);
      expect(result[0].email, 'test@email.com');
      expect(result[0].username, 'test_user');
    });

    test("When getting user list failed, it returns NetworkExceptions error",
        () async {
      when(mockApiService.getUsers()).thenThrow(MockDioError());

      expect(
        () => repository.getUsers(),
        throwsA(isA<NetworkExceptions>()),
      );
    });
  });
}
