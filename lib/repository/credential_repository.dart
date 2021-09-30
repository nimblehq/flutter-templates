import 'package:flutter_templates/api/api_service.dart';
import 'package:flutter_templates/model/response/user_response.dart';

abstract class CredentialRepository {
  Future<UserResponse> getProfile();
}

class CredentialRepositoryImpl extends CredentialRepository {
  final ApiService _apiService;

  CredentialRepositoryImpl(this._apiService);

  @override
  Future<UserResponse> getProfile() {
    return _apiService.getProfile();
  }
}
