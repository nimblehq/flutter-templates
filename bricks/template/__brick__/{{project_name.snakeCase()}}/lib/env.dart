import 'package:flutter_config_plus/flutter_config_plus.dart';

class Env {
  static String get restApiEndpoint {
    return FlutterConfigPlus.get('REST_API_ENDPOINT');
  }
}
