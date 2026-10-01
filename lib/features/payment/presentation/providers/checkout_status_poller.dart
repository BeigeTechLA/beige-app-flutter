import 'dart:async';

/// Watches for backend-confirmed payment when hosted checkout does not redirect.
/// Schedules after each request so slow requests never overlap.
class CheckoutStatusPoller {
  CheckoutStatusPoller({required this.isPaid, required this.onPaid});

  final Future<bool> Function() isPaid;
  final void Function() onPaid;
  Timer? _timer;
  bool _stopped = false;

  void start() {
    if (_stopped || _timer != null) return;
    _schedule();
  }

  void _schedule() {
    _timer = Timer(const Duration(seconds: 3), _check);
  }

  Future<void> _check() async {
    try {
      final paid = await isPaid();
      if (_stopped) return;
      if (paid) {
        stop();
        onPaid();
        return;
      }
    } catch (_) {
      // A transient status request failure must not interrupt card entry.
    }
    if (!_stopped) _schedule();
  }

  void stop() {
    _stopped = true;
    _timer?.cancel();
  }
}
