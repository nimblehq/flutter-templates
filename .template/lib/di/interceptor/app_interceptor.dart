import 'dart:io';

import 'package:dio/dio.dart';

class AppInterceptor extends Interceptor {
  final bool _requireAuthenticate;

  AppInterceptor(this._requireAuthenticate);

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_requireAuthenticate) {
      // TODO header authorization here
      // options.headers
      //     .putIfAbsent(HEADER_AUTHORIZATION, () => "");
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    if ((statusCode == HttpStatus.forbidden ||
            statusCode == HttpStatus.unauthorized) &&
        _requireAuthenticate) {
      _doRefreshToken(err, handler);
    } else {
      handler.next(err);
    }
  }

  Future<void> _doRefreshToken(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    // TODO Request new token
    //...
    // TODO Update new token header
    //...
  }
}
