import 'package:{{project_name.snakeCase()}}/domain/exceptions/network_exceptions.dart';
import 'package:{{project_name.snakeCase()}}/domain/repositories/credential_repository.dart';
import 'package:{{project_name.snakeCase()}}/domain/usecases/base/base_use_case.dart';
import 'package:{{project_name.snakeCase()}}/domain/models/user.dart';
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
