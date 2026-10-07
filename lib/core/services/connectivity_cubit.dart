import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityCubit extends Cubit<bool> {
  final InternetConnection _checker;
  StreamSubscription<InternetStatus>? _sub;

  ConnectivityCubit(this._checker) : super(true) {
    _init();
  }

  Future<void> _init() async {
    emit(await _checker.hasInternetAccess);
    _sub = _checker.onStatusChange.listen(
      (status) => emit(status == InternetStatus.connected),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
