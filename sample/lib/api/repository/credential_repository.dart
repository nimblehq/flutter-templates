import 'package:sample/api/api_service.dart';
import 'package:sample/api/exception/network_exceptions.dart';
import 'package:sample/model/user.dart';
import 'package:injectable/injectable.dart';

abstract class CredentialRepository {
  Future<List<User>> getUsers();
}

@LazySingleton(as: CredentialRepository)
class CredentialRepositoryImpl extends CredentialRepository {
  final BaseApiService _apiService;

  CredentialRepositoryImpl(this._apiService);

  @override
  Future<List<User>> getUsers() async {
    try {
      final userResponses = await _apiService.getUsers();
      return userResponses
          .map((userResponse) => User.fromUserResponse(userResponse))
          .toList();
    } catch (exception) {
      throw NetworkExceptions.fromDioException(exception);
    }
  }
}
