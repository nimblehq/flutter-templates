import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sample/di/interceptor/app_interceptor.dart';
import 'package:injectable/injectable.dart';

const String headerContentType = 'Content-Type';
const String defaultContentType = 'application/json; charset=utf-8';

@Singleton()
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
      ..options.connectTimeout = const Duration(seconds: 3000)
      ..options.receiveTimeout = const Duration(seconds: 5000)
      ..options.headers = {headerContentType: defaultContentType}
      ..interceptors.addAll(interceptors);
  }
}
