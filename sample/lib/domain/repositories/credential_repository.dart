import 'package:sample/domain/models/user.dart';

abstract class CredentialRepository {
  Future<List<User>> getUsers();
}
