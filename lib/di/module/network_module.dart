import 'package:flutter_templates/api/api_service.dart';
import 'package:flutter_templates/di/provider/dio_provider.dart';
import 'package:flutter_templates/env.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @singleton
  ApiService provideApiService(DioProvider dioProvider) {
    return ApiService(
      dioProvider.getDio(),
      baseUrl: Env.restApiEndpoint,
    );
  }
}
