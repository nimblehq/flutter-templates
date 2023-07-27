import 'package:dio/dio.dart';
import 'package:sample/api/api_service.dart';
import 'package:sample/api/repository/credential_repository.dart';
import 'package:sample/usecases/user/get_users_use_case.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  ApiService,
  CredentialRepository,
  DioError,
  GetUsersUseCase,
])
main() {
  // empty class to generate mock repository classes
}
