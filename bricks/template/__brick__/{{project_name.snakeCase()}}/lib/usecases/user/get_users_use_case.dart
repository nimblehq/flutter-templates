import 'package:{{project_name.snakeCase()}}/api/repository/credential_repository.dart';
import 'package:{{project_name.snakeCase()}}/usecases/base/base_use_case.dart';
import 'package:{{project_name.snakeCase()}}/model/user.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class GetUsersUseCase extends NoParamsUseCase<List<User>> {
  final CredentialRepository _credentialRepository;

  GetUsersUseCase(this._credentialRepository);

  @override
  Future<Result<List<User>>> call() async {
    try {
      final userResponses = await _credentialRepository.getUsers();
      final users = userResponses
          .map((userResponse) => User.fromUserResponse(userResponse))
          .toList();
      return Success(users);
    } catch (exception) {
      return Failed(UseCaseException(exception));
    }
  }
}
