import 'package:{{project_name.snakeCase()}}/data/remote/datasources/api_service.dart';
import 'package:{{project_name.snakeCase()}}/env.dart';
import 'package:{{project_name.snakeCase()}}/di/provider/dio_provider.dart';
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
