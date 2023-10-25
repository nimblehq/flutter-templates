import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

const _keyAccessToken = 'KEY_ACCESS_TOKEN';

abstract class SecureStorage {
  Future<String?> get accessToken;

  Future<void> storeAccessToken(String accessToken);

  Future<void> clearAll();
}

@Singleton(as: SecureStorage)
class SecureStorageImpl extends SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorageImpl(this._storage);

  @override
  Future<String?> get accessToken => _storage.read(key: _keyAccessToken);

  @override
  Future<void> storeAccessToken(String accessToken) {
    return _storage.write(key: _keyAccessToken, value: accessToken);
  }

  @override
  Future<void> clearAll() {
    return _storage.deleteAll();
  }
}
