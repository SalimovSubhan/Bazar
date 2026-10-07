import 'dart:async';
import 'package:bazar/app/router/app_router.dart';
import 'package:flutter/material.dart';

enum ToastType { success, error }

enum ToastPosition { top, bottom }

class Toast {
  Toast._();

  static final _active = <_Entry>[];

  static void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
    ToastType type = ToastType.success,
    VoidCallback? onTap,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    dismissAll();

    late OverlayEntry overlayEntry;
    final key = GlobalKey<_ToastState>();

    void onDismiss() {
      overlayEntry.remove();
      _active.removeWhere((e) => e.overlayEntry == overlayEntry);
    }

    overlayEntry = OverlayEntry(
      builder: (_) => _Toast(
        key: key,
        message: message,
        duration: duration,
        position: position,
        type: type,
        onDismiss: onDismiss,
        onTap: onTap,
      ),
    );

    _active.add(_Entry(overlayEntry: overlayEntry, key: key));
    overlay.insert(overlayEntry);
  }

  static void dismissAll() {
    for (final e in List.of(_active)) {
      e.key.currentState?.dismiss();
    }
  }
}

class _Entry {
  final OverlayEntry overlayEntry;
  final GlobalKey<_ToastState> key;
  _Entry({required this.overlayEntry, required this.key});
}

class _Toast extends StatefulWidget {
  const _Toast({
    super.key,
    required this.message,
    required this.duration,
    required this.position,
    required this.type,
    required this.onDismiss,
    this.onTap,
  });

  final String message;
  final Duration duration;
  final ToastPosition position;
  final ToastType type;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<Offset> _enterAnim;
  late final AnimationController _exitCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  final _swipeX = ValueNotifier<double>(0);
  bool _dismissing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    final slideBegin = widget.position == ToastPosition.bottom
        ? const Offset(0, 1.5)
        : const Offset(0, -1.5);
    _enterAnim = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack));

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _fadeAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _enterCtrl.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _swipeX.dispose();
    _enterCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, dismiss);
  }

  Future<void> dismiss({bool callOnTap = false}) async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _timer?.cancel();
    await _exitCtrl.forward();
    widget.onDismiss();
    if (callOnTap) widget.onTap?.call();
  }

  Color get _bgColor {
    return switch (widget.type) {
      ToastType.success => const Color.fromRGBO(27, 120, 60, 0.92),
      ToastType.error => const Color.fromRGBO(213, 0, 0, 0.7),
    };
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    final double vertBase = widget.position == ToastPosition.bottom
        ? mq.padding.bottom + 80
        : mq.padding.top + 8;

    return Positioned(
      left: 0,
      right: 0,
      top: widget.position == ToastPosition.top ? vertBase : null,
      bottom: widget.position == ToastPosition.bottom ? vertBase : null,
      child: SlideTransition(
        position: _enterAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => dismiss(callOnTap: true),
              onHorizontalDragUpdate: (d) {
                if (_dismissing) return;
                _timer?.cancel();
                _swipeX.value = (_swipeX.value + d.delta.dx).clamp(-sw, sw);
              },
              onHorizontalDragEnd: (d) {
                if (_dismissing) return;
                if (_swipeX.value.abs() > sw * 0.28 ||
                    d.velocity.pixelsPerSecond.dx.abs() > 350) {
                  dismiss();
                } else {
                  _swipeX.value = 0;
                  _startTimer();
                }
              },
              child: ValueListenableBuilder<double>(
                valueListenable: _swipeX,
                builder: (_, x, child) => Opacity(
                  opacity: (1.0 - x.abs() / (sw * 0.55)).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(x, 0),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final hasAction = widget.onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.76,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter Tight',
                ),
                textAlign: hasAction ? TextAlign.start : TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasAction) ...[
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Обновить',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter Tight',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
