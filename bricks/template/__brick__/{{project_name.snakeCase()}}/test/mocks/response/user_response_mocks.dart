import 'package:{{project_name.snakeCase()}}/data/datasources/remote/response/user_response.dart';

class UserResponseMocks {
  static UserResponse mock() {
    return UserResponse(
      "email",
      "username",
    );
  }
}
