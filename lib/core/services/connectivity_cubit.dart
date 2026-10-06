import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityCubit(this._connectivity) : super(true) {
    _init();
  }

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    emit(!results.contains(ConnectivityResult.none));

    _sub = _connectivity.onConnectivityChanged.listen(
      (results) => emit(!results.contains(ConnectivityResult.none)),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
