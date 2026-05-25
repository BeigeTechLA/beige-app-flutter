import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logEvent(String name, {Map<String, Object>? params}) async {
   if (kDebugMode) return;  // No analytics noise in dev
    await _analytics.logEvent(name: name, parameters: params);
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  static Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    Map<String, Object>? params,
  }) async {
    if (kDebugMode) return;
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: currency,
      parameters: params,
    );
  }
}
