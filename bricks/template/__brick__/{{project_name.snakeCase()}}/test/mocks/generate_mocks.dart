import 'package:dio/dio.dart';
import 'package:{{project_name.snakeCase()}}/api/api_service.dart';
import 'package:{{project_name.snakeCase()}}/api/repository/credential_repository.dart';
import 'package:{{project_name.snakeCase()}}/usecases/user/get_users_use_case.dart';
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
