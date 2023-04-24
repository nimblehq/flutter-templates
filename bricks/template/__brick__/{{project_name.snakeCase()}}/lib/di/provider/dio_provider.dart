import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:{{project_name.snakeCase()}}/di/interceptor/app_interceptor.dart';

const String headerContentType = 'Content-Type';
const String defaultContentType = 'application/json; charset=utf-8';

class DioProvider {
  Dio? _dio;

  Dio getDio() {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio({bool requireAuthenticate = false}) {
    final dio = Dio();
    final appInterceptor = AppInterceptor(
      requireAuthenticate,
      dio,
    );
    final interceptors = <Interceptor>[];
    interceptors.add(appInterceptor);
    if (!kReleaseMode) {
      interceptors.add(LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        requestHeader: true,
      ));
    }

    return dio
      ..options.connectTimeout = 3000
      ..options.receiveTimeout = 5000
      ..options.headers = {headerContentType: defaultContentType}
      ..interceptors.addAll(interceptors);
  }
}
