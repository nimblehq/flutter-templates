import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get restApiEndpoint {
    return dotenv.get('REST_API_ENDPOINT');
  }
}
