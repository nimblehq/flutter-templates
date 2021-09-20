import 'dart:async';

import 'package:flutter_templates/model/response/user_response.dart';
import 'package:flutter_templates/repository/credential_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  group('CredentialRepository - getProfile', () {
    MockApiService mockApiService = MockApiService();
    late CredentialRepository repository;

    setUp(() {
      repository = CredentialRepositoryImpl(mockApiService);
    });
    test(
        "When getting profile successfully, it emits corresponding UserResponse",
        () async {
      when(mockApiService.getProfile())
          .thenAnswer((_) async => UserResponse('test@email.com', 'test_user'));

      final result = await repository.getProfile();
      expect(result.email, 'test@email.com');
      expect(result.username, 'test_user');
    });

    test("When getting profile failed, it throws a negative error", () async {
      when(mockApiService.getProfile())
          .thenThrow(TimeoutException('There is an exception!'));

      final result = () => repository.getProfile();
      expect(
          result,
          throwsA(predicate<TimeoutException>(
              (ex) => ex.message == 'There is an exception!')));
    });
  });
}
