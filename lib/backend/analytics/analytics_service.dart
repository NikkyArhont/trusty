import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Central entry point for product analytics.
///
/// Event parameters must never contain names, phone numbers, messages, or
/// other personally identifiable information.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  late final FirebaseAnalyticsObserver navigationObserver =
      FirebaseAnalyticsObserver(
        analytics: _analytics,
        onError: (error) => _debugError('screen_view', error),
      );

  void setUserId(String? uid) {
    _record('set_user_id', _analytics.setUserId(id: uid));
  }

  void logLogin(String method) {
    _record('login', _analytics.logLogin(loginMethod: method));
  }

  void logServiceView({
    required String serviceId,
    required String title,
    required String category,
    required int price,
  }) {
    _record(
      'view_item',
      _analytics.logViewItem(
        currency: 'RUB',
        value: price.toDouble(),
        items: [_serviceItem(serviceId, title, category, price)],
      ),
    );
  }

  void logFavoriteAdded({
    required String serviceId,
    required String title,
    required String category,
    required int price,
  }) {
    _record(
      'add_to_wishlist',
      _analytics.logAddToWishlist(
        currency: 'RUB',
        value: price.toDouble(),
        items: [_serviceItem(serviceId, title, category, price)],
      ),
    );
  }

  void logMasterContact({
    required String serviceId,
    required String category,
    required int price,
  }) {
    _record(
      'generate_lead',
      _analytics.logGenerateLead(
        currency: 'RUB',
        value: price.toDouble(),
        parameters: {'service_id': serviceId, 'service_category': category},
      ),
    );
  }

  AnalyticsEventItem _serviceItem(
    String serviceId,
    String title,
    String category,
    int price,
  ) => AnalyticsEventItem(
    itemId: serviceId,
    itemName: title,
    itemCategory: category,
    currency: 'RUB',
    price: price,
  );

  void _record(String eventName, Future<void> event) {
    unawaited(event.catchError((error) => _debugError(eventName, error)));
  }

  static void _debugError(String eventName, Object error) {
    if (kDebugMode) {
      debugPrint('Firebase Analytics $eventName failed: $error');
    }
  }
}
