import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/locale_keys.dart';
import '../utils/toast.dart';

class AppLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(options);

    final buf = StringBuffer();
    buf.writeln('┌─── 📤 REQUEST ──────────────────────────────────────');
    buf.writeln('│ ${options.method.toUpperCase()}  ${options.uri}');

    if (options.queryParameters.isNotEmpty) {
      buf.writeln('│ Params: ${options.queryParameters}');
    }
    if (options.data != null) {
      buf.writeln('│ Body:   ${_preview(options.data)}');
    }
    buf.write('└─────────────────────────────────────────────────────');
    debugPrint(buf.toString());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(response);

    final status = response.statusCode;
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method.toUpperCase();
    final size = _size(response.data);

    final buf = StringBuffer();
    buf.writeln('┌─── ✅ RESPONSE ─────────────────────────────────────');
    buf.writeln('│ $status  $method  $uri  ($size)');
    if (response.data != null) {
      buf.writeln('│ Data: ${_preview(response.data)}');
    }
    buf.write('└─────────────────────────────────────────────────────');
    debugPrint(buf.toString());

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isNetworkError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;

    if (isNetworkError) {
      Toast.show(
        LocaleKeys.noInternet.tr(),
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    }

    if (kDebugMode) {
      final uri = err.requestOptions.uri;
      final method = err.requestOptions.method.toUpperCase();
      final status = err.response?.statusCode ?? err.type.name;

      final buf = StringBuffer();
      buf.writeln('┌─── ❌ ERROR ────────────────────────────────────────');
      buf.writeln('│ $status  $method  $uri');
      buf.writeln('│ Message: ${err.message}');
      if (err.response?.data != null) {
        buf.writeln('│ Body: ${_preview(err.response!.data)}');
      }
      buf.write('└─────────────────────────────────────────────────────');
      debugPrint(buf.toString());
    }

    handler.next(err);
  }

  String _size(dynamic data) {
    if (data == null) return '0 B';
    final bytes = data.toString().length;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _preview(dynamic data) {
    final str = data.toString();
    return str.length > 200 ? '${str.substring(0, 200)}…' : str;
  }
}
