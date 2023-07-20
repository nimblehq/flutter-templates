import 'package:dio/dio.dart';
import 'package:{{project_name.snakeCase()}}/api/api_service.dart';
import 'package:{{project_name.snakeCase()}}/api/repository/credential_repository.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  ApiService,
  DioError,
  CredentialRepository,
])
main() {
  // empty class to generate mock repository classes
}
