import 'package:{{project_name.snakeCase()}}/domain/models/user.dart';

abstract class CredentialRepository {
  Future<List<User>> getUsers();
}
