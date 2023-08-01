import 'package:equatable/equatable.dart';
import 'package:sample/api/response/user_response.dart';

class User extends Equatable {
  final String email;
  final String username;

  const User({
    required this.email,
    required this.username,
  });

  factory User.fromUserResponse(UserResponse response) {
    return User(
      email: response.email,
      username: response.username,
    );
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        email,
        username,
      ];
}
