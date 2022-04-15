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
}
