import 'package:dio/dio.dart';
import 'package:{{project_name.snakeCase()}}/api/api_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  ApiService,
  DioError,
])
main() {
  // empty class to generate mock repository classes
}
