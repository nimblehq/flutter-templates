import 'package:dio/dio.dart';
import 'package:sample/data/remote/models/responses/user_response.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

abstract class BaseApiService {
  Future<List<UserResponse>> getUsers();
}

@RestApi()
abstract class ApiService extends BaseApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // TODO add API endpoint
  @override
  @GET('users')
  Future<List<UserResponse>> getUsers();
}
