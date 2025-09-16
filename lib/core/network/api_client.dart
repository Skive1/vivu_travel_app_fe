import 'package:dio/dio.dart';

abstract class ApiClient {
  Future<Response> get(String path);
  Future<Response> post(String path, {dynamic data});
  Future<Response> put(String path, {dynamic data});
  Future<Response> delete(String path);
}

class ApiClientImpl implements ApiClient {
  final Dio dio;

  ApiClientImpl(this.dio);

  @override
  Future<Response> get(String path) {
    return dio.get(path);
  }

  @override
  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  @override
  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  @override
  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
