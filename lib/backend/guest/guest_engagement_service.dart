import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';

const _guestOpenCountKey = 'guest_engagement_open_count_v1';
const _pushPromptShownKey = 'guest_push_prompt_shown_v1';

bool _guestLaunchRecorded = false;
bool _guestDialogVisible = false;

Future<void> recordGuestLaunchAndShowIfEligible() async {
  if (!currentUserIsAnonymous || _guestLaunchRecorded) return;
  _guestLaunchRecorded = true;

  final preferences = await SharedPreferences.getInstance();
  final openCount = (preferences.getInt(_guestOpenCountKey) ?? 0) + 1;
  await preferences.setInt(_guestOpenCountKey, openCount);

  final userRef = currentUserReference;
  if (userRef != null) {
    unawaited(
      userRef
          .set({
            'guestOpenCount': FieldValue.increment(1),
            'guestLastOpenedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .catchError((_) {}),
    );
  }

  if (openCount < 3) return;
  await Future<void>.delayed(const Duration(seconds: 2));
  if (!currentUserIsAnonymous) return;

  final context = await _navigationContext();
  if (context == null || !context.mounted || _guestDialogVisible) return;

  if (preferences.getBool(_pushPromptShownKey) != true) {
    await _maybeShowPushPrompt(context, preferences);
  }
}

Future<BuildContext?> _navigationContext() async {
  for (var attempt = 0; attempt < 30; attempt++) {
    final context = appNavigatorKey.currentContext;
    if (context != null && context.mounted) return context;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  return null;
}

Future<void> _maybeShowPushPrompt(
  BuildContext context,
  SharedPreferences preferences,
) async {
  if (kIsWeb) return;
  try {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await preferences.setBool(_pushPromptShownKey, true);
      if (settings.authorizationStatus != AuthorizationStatus.denied) {
        await initPushNotificationsForCurrentUser(requestPermission: false);
      }
      return;
    }

    _guestDialogVisible = true;
    await preferences.setBool(_pushPromptShownKey, true);
    if (!context.mounted) return;
    final enable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.notifications_active_outlined,
          color: FlutterFlowTheme.of(dialogContext).primary,
          size: 40,
        ),
        title: const Text(
          'Сообщать о новых рекомендациях?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Мы можем иногда сообщать, когда в Сарафане появляются новые услуги и рекомендации. Имена знакомых в уведомлениях показываться не будут.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Не сейчас'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Разрешить'),
          ),
        ],
      ),
    );
    if (enable == true) {
      await setPushPreferenceEnabled(true);
    }
  } catch (error) {
    if (kDebugMode) debugPrint('Guest push prompt error: $error');
  } finally {
    _guestDialogVisible = false;
  }
}

void resetGuestEngagementSession() {
  _guestLaunchRecorded = false;
  _guestDialogVisible = false;
}
