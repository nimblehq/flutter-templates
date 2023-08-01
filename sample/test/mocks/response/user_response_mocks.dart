import 'package:sample/api/response/user_response.dart';

class UserResponseMocks {
  static UserResponse mock() {
    return UserResponse(
      "email",
      "username",
    );
  }
}
