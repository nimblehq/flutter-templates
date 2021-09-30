import 'package:flutter_templates/model/response/user_response.dart';

abstract class ApiService {
  Future<UserResponse> getProfile();
}
