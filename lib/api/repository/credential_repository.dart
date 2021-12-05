import 'package:flutter_templates/api/api_service.dart';
import 'package:flutter_templates/api/exception/network_exceptions.dart';
import 'package:flutter_templates/model/response/user_response.dart';

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
