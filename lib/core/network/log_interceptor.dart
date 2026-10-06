import 'package:dio/dio.dart';

// ANSI color codes
class _C {
  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';

  // Text colors
  static const cyan = '\x1B[36m';
  static const green = '\x1B[32m';
  static const red = '\x1B[31m';
  static const yellow = '\x1B[33m';
  static const magenta = '\x1B[35m';
  static const white = '\x1B[37m';
  static const gray = '\x1B[90m';

  // Background colors
  static const bgBlue = '\x1B[44m';
  static const bgGreen = '\x1B[42m';
  static const bgRed = '\x1B[41m';
}

class AppLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final uri = options.uri;

    _printLine(_C.cyan);
    _print('${_C.bgBlue}${_C.bold}${_C.white}  REQUEST  ${_C.reset}  '
        '${_C.bold}${_C.cyan}$method${_C.reset}  '
        '${_C.cyan}$uri${_C.reset}');

    if (options.headers.isNotEmpty) {
      _print('${_C.yellow}${_C.bold}Headers:${_C.reset}');
      options.headers.forEach((k, v) {
        _print('  ${_C.yellow}$k${_C.reset}: ${_C.gray}$v${_C.reset}');
      });
    }

    if (options.queryParameters.isNotEmpty) {
      _print('${_C.magenta}${_C.bold}Params:${_C.reset}');
      options.queryParameters.forEach((k, v) {
        _print('  ${_C.magenta}$k${_C.reset}: ${_C.gray}$v${_C.reset}');
      });
    }

    if (options.data != null) {
      _print('${_C.white}${_C.bold}Body:${_C.reset} ${_C.gray}${options.data}${_C.reset}');
    }

    _printLine(_C.cyan);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final status = response.statusCode;
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method.toUpperCase();
    final size = _bodySize(response.data);

    _printLine(_C.green);
    _print('${_C.bgGreen}${_C.bold}${_C.white}  RESPONSE ${_C.reset}  '
        '${_C.bold}${_C.green}$status${_C.reset}  '
        '${_C.cyan}$method${_C.reset}  '
        '${_C.green}$uri${_C.reset}  '
        '${_C.gray}($size)${_C.reset}');

    if (response.data != null) {
      final preview = _dataPreview(response.data);
      _print('${_C.green}${_C.bold}Data:${_C.reset} ${_C.gray}$preview${_C.reset}');
    }

    _printLine(_C.green);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final uri = err.requestOptions.uri;
    final method = err.requestOptions.method.toUpperCase();
    final status = err.response?.statusCode;
    final type = err.type.name;

    _printLine(_C.red);
    _print('${_C.bgRed}${_C.bold}${_C.white}   ERROR   ${_C.reset}  '
        '${_C.bold}${_C.red}${status ?? type}${_C.reset}  '
        '${_C.cyan}$method${_C.reset}  '
        '${_C.red}$uri${_C.reset}');

    _print('${_C.red}${_C.bold}Type:${_C.reset}    ${_C.gray}${err.type}${_C.reset}');
    _print('${_C.red}${_C.bold}Message:${_C.reset} ${_C.gray}${err.message}${_C.reset}');

    if (err.response?.data != null) {
      final preview = _dataPreview(err.response!.data);
      _print('${_C.red}${_C.bold}Body:${_C.reset}    ${_C.gray}$preview${_C.reset}');
    }

    _printLine(_C.red);
    handler.next(err);
  }

  // ── Helpers ──────────────────────────────────────────────

  void _print(String msg) => print(msg); // ignore: avoid_print

  void _printLine(String color) =>
      _print('$color${'─' * 60}${_C.reset}');

  String _bodySize(dynamic data) {
    if (data == null) return '0 B';
    final str = data.toString();
    final bytes = str.length;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _dataPreview(dynamic data) {
    final str = data.toString();
    return str.length > 300 ? '${str.substring(0, 300)}...' : str;
  }
}
