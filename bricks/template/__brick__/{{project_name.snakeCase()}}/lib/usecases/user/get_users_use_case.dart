import 'package:{{project_name.snakeCase()}}/api/exception/network_exceptions.dart';
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
    return _credentialRepository
        .getUsers()
        .then((value) =>
            Success(value) as Result<List<User>>) // ignore: unnecessary_cast
        .onError<NetworkExceptions>(
            (err, stackTrace) => Failed(UseCaseException(err)));
  }
}
