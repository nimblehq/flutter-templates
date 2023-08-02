import 'package:json_annotation/json_annotation.dart';
import 'package:{{project_name.snakeCase()}}/domain/models/user.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  final String email;
  final String username;

  UserResponse(this.email, this.username);

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  User toUser() => User(
        email: email,
        username: username,
      );
}
