import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/service_record.dart';
import '/backend/share_prompt/share_prompt_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/master/edit_service/edit_service_widget.dart';
import '/master/notifications/master_notifications_widget.dart';
import '/user/chat/chat_widget.dart';

bool _pushNotificationsInitialized = false;
bool _pushNotificationsInitializing = false;
bool _masterPushNavigationInitialized = false;
StreamSubscription<RemoteMessage>? _pushOpenedSubscription;
StreamSubscription<RemoteMessage>? _foregroundMessagesSubscription;
StreamSubscription<String>? _tokenRefreshSubscription;
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();
bool _localNotificationsInitialized = false;
final StreamController<void> _appUpdatePushController =
    StreamController<void>.broadcast();

Stream<void> get appUpdatePushEvents => _appUpdatePushController.stream;

enum PushPreferenceStatus { enabled, disabledByUser, systemDenied, unavailable }

Future<bool> _isPushEnabledForAccount(DocumentReference userRef) async {
  final snapshot = await userRef.get();
  return snapshot.data() is! Map ||
      (snapshot.data()! as Map<String, dynamic>)['pushNotificationsEnabled'] !=
          false;
}

Future<PushPreferenceStatus> getPushPreferenceStatus() async {
  if (kIsWeb) return PushPreferenceStatus.unavailable;
  final userRef = currentUserReference;
  if (userRef == null) return PushPreferenceStatus.unavailable;
  try {
    if (!await _isPushEnabledForAccount(userRef)) {
      return PushPreferenceStatus.disabledByUser;
    }
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return PushPreferenceStatus.systemDenied;
    }
    final token = await messaging.getToken();
    return token?.isNotEmpty == true
        ? PushPreferenceStatus.enabled
        : PushPreferenceStatus.unavailable;
  } catch (_) {
    return PushPreferenceStatus.unavailable;
  }
}

Future<PushPreferenceStatus> setPushPreferenceEnabled(bool enabled) async {
  if (kIsWeb) return PushPreferenceStatus.unavailable;
  final userRef = currentUserReference;
  if (userRef == null) return PushPreferenceStatus.unavailable;

  if (!enabled) {
    await userRef.set({
      'pushNotificationsEnabled': false,
    }, SetOptions(merge: true));
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token?.isNotEmpty == true) {
        await userRef.update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
      await messaging.setAutoInitEnabled(false);
      await messaging.deleteToken();
    } catch (_) {}
    resetPushNotificationsState();
    return PushPreferenceStatus.disabledByUser;
  }

  await userRef.set({
    'pushNotificationsEnabled': true,
  }, SetOptions(merge: true));
  _pushNotificationsInitialized = false;
  await initPushNotificationsForCurrentUser();
  return getPushPreferenceStatus();
}

const AndroidNotificationChannel _messagesChannel = AndroidNotificationChannel(
  'trusty_messages',
  'Сообщения',
  description: 'Новые сообщения и важные уведомления Сарафана',
  importance: Importance.high,
);

String _chatNotificationTag(String chatId) => 'trusty_chat_$chatId';

const MethodChannel _notificationChannel = MethodChannel(
  'trusty/notifications',
);

String? _currentOpenChatId() {
  final context = appNavigatorKey.currentContext;
  if (context == null) return null;
  try {
    final uri = Uri.parse(GoRouter.of(context).getCurrentLocation());
    if (uri.path != ChatWidget.routePath) return null;
    return uri.queryParameters['chatId']?.trim();
  } catch (_) {
    return null;
  }
}

Future<void> clearChatNotification(String? chatId) async {
  if (kIsWeb) return;
  final normalizedChatId = chatId?.trim() ?? '';
  if (normalizedChatId.isEmpty) return;

  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _initializeLocalNotifications();
      await _localNotifications.cancel(
        0,
        tag: _chatNotificationTag(normalizedChatId),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notificationChannel.invokeMethod<void>('clearChatNotification', {
        'chatId': normalizedChatId,
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Chat notification clear error: $error');
    }
  }
}

Future<void> _openChatFromPush(String chatId) async {
  final normalizedChatId = chatId.trim();
  if (normalizedChatId.isEmpty) return;

  BuildContext? navigationContext;
  for (var attempt = 0; attempt < 20; attempt++) {
    navigationContext = appNavigatorKey.currentContext;
    if (navigationContext != null) break;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  if (navigationContext?.mounted != true) return;

  await clearChatNotification(normalizedChatId);
  if (_currentOpenChatId() == normalizedChatId) return;
  final activeNavigationContext = navigationContext;
  if (activeNavigationContext == null || !activeNavigationContext.mounted) {
    return;
  }

  activeNavigationContext.pushNamed(
    ChatWidget.routeName,
    queryParameters: {
      'chatId': serializeParam(normalizedChatId, ParamType.String),
    }.withoutNulls,
  );
}

Future<void> _initializeLocalNotifications() async {
  if (_localNotificationsInitialized) return;

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  await _localNotifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      final chatId = response.payload ?? '';
      if (chatId.isNotEmpty) unawaited(_openChatFromPush(chatId));
    },
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_messagesChannel);

  _localNotificationsInitialized = true;
  final launchDetails = await _localNotifications
      .getNotificationAppLaunchDetails();
  final launchChatId = launchDetails?.notificationResponse?.payload ?? '';
  if (launchDetails?.didNotificationLaunchApp == true &&
      launchChatId.isNotEmpty) {
    unawaited(_openChatFromPush(launchChatId));
  }
}

Future<void> _showForegroundMessage(RemoteMessage message) async {
  if (message.data['type'] == 'app_update') {
    _appUpdatePushController.add(null);
    return;
  }
  if (defaultTargetPlatform != TargetPlatform.android) return;
  final notification = message.notification;
  if (notification == null) return;

  final chatId = (message.data['chatId'] ?? '').toString().trim();
  if (chatId.isNotEmpty && _currentOpenChatId() == chatId) {
    await clearChatNotification(chatId);
    return;
  }

  final notificationTag = chatId.isEmpty ? null : _chatNotificationTag(chatId);
  final notificationId = notificationTag == null
      ? message.messageId?.hashCode ??
            DateTime.now().millisecondsSinceEpoch.remainder(1 << 31)
      : 0;

  await _localNotifications.show(
    notificationId,
    notification.title ?? 'Сарафан',
    notification.body ?? 'Новое сообщение',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'trusty_messages',
        'Сообщения',
        channelDescription: 'Новые сообщения и важные уведомления Сарафана',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        tag: notificationTag,
      ),
    ),
    payload: chatId,
  );
}

Future<void> initPushNotificationsForCurrentUser({
  bool requestPermission = true,
}) async {
  if (kIsWeb) {
    return;
  }
  final userRef = currentUserReference;
  if (userRef == null ||
      _pushNotificationsInitialized ||
      _pushNotificationsInitializing) {
    return;
  }
  _pushNotificationsInitializing = true;

  try {
    if (!await _isPushEnabledForAccount(userRef)) {
      await FirebaseMessaging.instance.setAutoInitEnabled(false);
      return;
    }
    await initPushNotificationNavigationForMaster();
    await _initializeLocalNotifications();
    final messaging = FirebaseMessaging.instance;
    await messaging.setAutoInitEnabled(true);
    final permission = requestPermission
        ? await messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          )
        : await messaging.getNotificationSettings();
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (permission.authorizationStatus == AuthorizationStatus.denied ||
        permission.authorizationStatus == AuthorizationStatus.notDetermined) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apnsToken;
      for (var attempt = 0; attempt < 20; attempt++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken?.isNotEmpty == true) break;
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      if (apnsToken?.isNotEmpty != true) {
        throw StateError('APNs token is not available');
      }
    }

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await userRef.set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
      _pushNotificationsInitialized = true;
    }

    _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) async {
          if (newToken.isEmpty || currentUserReference == null) return;

          if (!await _isPushEnabledForAccount(currentUserReference!)) return;

          await currentUserReference!.set({
            'fcmTokens': FieldValue.arrayUnion([newToken]),
          }, SetOptions(merge: true));
        });
  } catch (error) {
    _pushNotificationsInitialized = false;
    if (kDebugMode) {
      print('Push notifications init error: $error');
    }
  } finally {
    _pushNotificationsInitializing = false;
  }
}

Future<void> initPushNotificationNavigationForMaster() async {
  if (kIsWeb || _masterPushNavigationInitialized) {
    return;
  }
  _masterPushNavigationInitialized = true;

  _pushOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
    _openMasterPush,
  );
  _foregroundMessagesSubscription = FirebaseMessaging.onMessage.listen(
    _showForegroundMessage,
  );
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    await _openMasterPush(initialMessage);
  }
}

Future<void> _openMasterPush(RemoteMessage message) async {
  final chatId = (message.data['chatId'] ?? '').toString().trim();
  if (chatId.isNotEmpty) {
    await _openChatFromPush(chatId);
    return;
  }

  if (message.data['type'] == 'engagement') {
    return;
  }

  if (message.data['type'] == 'app_update') {
    _appUpdatePushController.add(null);
    return;
  }

  BuildContext? navigationContext;
  for (var attempt = 0; attempt < 10; attempt++) {
    navigationContext = appNavigatorKey.currentContext;
    if (navigationContext != null) {
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  if (navigationContext == null) {
    return;
  }

  if (message.data['type'] == 'share_prompt') {
    await showSharePromptIfEligible(force: true);
    return;
  }

  final serviceId = (message.data['serviceId'] ?? '').toString().trim();
  if (serviceId.isNotEmpty) {
    final snapshot = await ServiceRecord.collection.doc(serviceId).get();
    if (snapshot.exists && navigationContext.mounted) {
      final service = ServiceRecord.fromSnapshot(snapshot);
      final isApprovedModeration =
          message.data['type'] == 'service_moderation' &&
          service.status == ServiceStatus.show;
      if (!isApprovedModeration) {
        navigationContext.pushNamed(
          EditServiceWidget.routeName,
          queryParameters: {
            'servDoc': serializeParam(service, ParamType.Document),
          }.withoutNulls,
          extra: <String, dynamic>{'servDoc': service},
        );
        return;
      }
    }
  }

  if (navigationContext.mounted) {
    navigationContext.pushNamed(MasterNotificationsWidget.routeName);
  }
}

void resetPushNotificationsState() {
  _pushNotificationsInitialized = false;
  _pushNotificationsInitializing = false;
  _masterPushNavigationInitialized = false;
  _pushOpenedSubscription?.cancel();
  _pushOpenedSubscription = null;
  _foregroundMessagesSubscription?.cancel();
  _foregroundMessagesSubscription = null;
  _tokenRefreshSubscription?.cancel();
  _tokenRefreshSubscription = null;
  resetSharePromptState();
}

Future<void> removeCurrentUserFcmToken() async {
  if (kIsWeb) {
    return;
  }
  final userRef = currentUserReference;
  if (userRef == null) {
    return;
  }
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await userRef.update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error removing FCM token: $error');
    }
  }
}
