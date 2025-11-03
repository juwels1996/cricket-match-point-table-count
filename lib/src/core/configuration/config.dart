import 'package:cricket_scorecard/src/core/const.dart';
import 'package:dio/dio.dart';

class DioConfig {
  static final DioConfig _instance = DioConfig._internal();

  factory DioConfig() {
    return _instance;
  }

  late final Dio _dio;

  DioConfig._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Constants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Dio get dio => _dio;
}
