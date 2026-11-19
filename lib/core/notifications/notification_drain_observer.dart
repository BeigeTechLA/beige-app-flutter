import 'package:flutter/widgets.dart';

import 'push_notification_service.dart';

/// Drains any queued notification payload when the app returns to the
/// foreground.
///
/// Background notification taps that arrive while the navigator/router is not
/// yet ready (e.g. the app resumed onto splash) are re-queued into
/// `PushNotificationService._pendingPayload`. The one-shot `HomeScreen.initState`
/// drain only fires on a fresh Home mount (cold start), so it cannot flush a
/// re-queue once Home is already alive. This observer covers that gap by
/// draining on every `resumed` transition.
class NotificationDrainObserver with WidgetsBindingObserver {
  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PushNotificationService.instance.processPendingNotification();
    }
  }
}
