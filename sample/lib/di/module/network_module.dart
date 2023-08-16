import 'package:sample/data/remote/datasources/api_service.dart';
import 'package:sample/env.dart';
import 'package:sample/di/provider/dio_provider.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @Singleton(as: BaseApiService)
  ApiService provideApiService(DioProvider dioProvider) {
    return ApiService(
      dioProvider.getDio(),
      baseUrl: Env.restApiEndpoint,
    );
  }
}
