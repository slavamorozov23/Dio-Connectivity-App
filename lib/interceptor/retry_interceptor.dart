import 'dart:io';

import 'package:dio/dio.dart';

import 'package:dio_connectivity_app/interceptor/dio_connectivity_request_retrier.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final DioConnectivityRequestRetrier requestRetrier;
  RetryOnConnectionChangeInterceptor({
    required this.requestRetrier,
  });
  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        return requestRetrier.scheduleRequestRetry(err.requestOptions);
      } catch (e) {
        rethrow;
      }
    }
    return err;
  }

  bool _shouldRetry(DioException err) {
    return err.type is SocketException;
  }
}
