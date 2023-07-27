import 'package:sample/api/exception/network_exceptions.dart';
import 'package:sample/api/repository/credential_repository.dart';
import 'package:sample/usecases/base/base_use_case.dart';
import 'package:sample/model/user.dart';
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
