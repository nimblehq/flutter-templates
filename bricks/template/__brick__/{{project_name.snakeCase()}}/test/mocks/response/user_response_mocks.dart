import 'package:{{project_name.snakeCase()}}/api/response/user_response.dart';

class UserResponseMocks {
  static UserResponse mock() {
    return UserResponse(
      "email",
      "username",
    );
  }
}
