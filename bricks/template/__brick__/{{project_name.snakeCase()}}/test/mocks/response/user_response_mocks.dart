import 'package:{{project_name.snakeCase()}}/api/response/user_response.dart';

class UserResponseMocks {
  static UserResponse mock() {
    return const UserResponse(
      email: "email",
      username: "username",
    );
  }
}
