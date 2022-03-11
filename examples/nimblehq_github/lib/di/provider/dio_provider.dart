import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nimblehq_github/di/interceptor/app_interceptor.dart';

const String HEADER_CONTENT_TYPE = 'Content-Type';
const String DEFAULT_CONTENT_TYPE = 'application/json; charset=utf-8';

class DioProvider {
  Dio? _dio;

  Dio getDio() {
    if (_dio == null) {
      _dio = _createDio();
    }
    return _dio!;
  }

  Dio _createDio({bool requireAuthenticate = false}) {
    final dio = Dio();
    final appInterceptor = AppInterceptor(requireAuthenticate);
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
      ..options.headers = {HEADER_CONTENT_TYPE: DEFAULT_CONTENT_TYPE}
      ..interceptors.addAll(interceptors);
  }
}
