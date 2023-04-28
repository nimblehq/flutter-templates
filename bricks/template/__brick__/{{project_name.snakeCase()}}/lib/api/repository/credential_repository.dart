import 'package:{{project_name.snakeCase()}}/api/api_service.dart';
import 'package:{{project_name.snakeCase()}}/api/exception/network_exceptions.dart';
import 'package:{{project_name.snakeCase()}}/model/response/user_response.dart';

abstract class CredentialRepository {
  Future<List<UserResponse>> getUsers();
}

class CredentialRepositoryImpl extends CredentialRepository {
  final ApiService _apiService;

  CredentialRepositoryImpl(this._apiService);

  @override
  Future<List<UserResponse>> getUsers() async {
    try {
      return await _apiService.getUsers();
    } catch (exception) {
      throw NetworkExceptions.fromDioException(exception);
    }
  }
}
