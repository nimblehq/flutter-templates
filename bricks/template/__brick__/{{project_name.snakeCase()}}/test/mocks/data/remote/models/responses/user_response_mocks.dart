import 'package:{{project_name.snakeCase()}}/data/remote/models/responses/user_response.dart';

class UserResponseMocks {
  static UserResponse mock() {
    return UserResponse(
      "email",
      "username",
    );
  }
}
