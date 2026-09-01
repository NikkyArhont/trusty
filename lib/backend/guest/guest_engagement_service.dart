import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/service_record.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/init/sync_contacts.dart';

const _guestOpenCountKey = 'guest_engagement_open_count_v1';
const _contactsPromptShownKey = 'guest_contacts_prompt_shown_v1';
const _contactsResultShownKey = 'guest_contacts_result_shown_v1';
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

  if (openCount < 2) return;
  await Future<void>.delayed(const Duration(seconds: 2));
  if (!currentUserIsAnonymous) return;

  final context = await _navigationContext();
  if (context == null || !context.mounted || _guestDialogVisible) return;

  final hasPermission = await hasContactsPermission();
  if (!hasPermission && preferences.getBool(_contactsPromptShownKey) != true) {
    await preferences.setBool(_contactsPromptShownKey, true);
    await _showContactsPrompt(context);
    return;
  }

  if (hasPermission && preferences.getBool(_contactsResultShownKey) != true) {
    await preferences.setBool(_contactsResultShownKey, true);
    await syncContacts();
    final matchingServices = await _matchingServiceCount();
    if (context.mounted) {
      await _showContactsResult(context, matchingServices);
    }
    return;
  }

  if (openCount >= 3 && preferences.getBool(_pushPromptShownKey) != true) {
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

Future<int> _matchingServiceCount() async {
  try {
    final snapshot = await ServiceRecord.collection.get();
    return snapshot.docs.where((document) {
      final service = ServiceRecord.fromSnapshot(document);
      return recommendationPhoneHashesForService(
        service,
      ).any((hash) => contactNameForPhoneHash(hash) != null);
    }).length;
  } catch (_) {
    return 0;
  }
}

Future<void> _showContactsPrompt(BuildContext context) async {
  _guestDialogVisible = true;
  try {
    final shouldSync = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.people_alt_outlined,
          color: FlutterFlowTheme.of(dialogContext).primary,
          size: 40,
        ),
        title: const Text(
          'Найдите рекомендации знакомых',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Сарафан сопоставит контакты прямо на устройстве и покажет, кто рекомендует мастеров. Имена и номера не добавляются в ваш профиль.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Позже'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Проверить контакты'),
          ),
        ],
      ),
    );
    if (shouldSync != true || !context.mounted) return;

    final synchronized = await syncContacts(requestPermission: true);
    if (!context.mounted) return;
    if (synchronized) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_contactsResultShownKey, true);
    }
    if (!context.mounted) return;
    final message = synchronized
        ? 'Контакты проверены. Совпадения появятся рядом с услугами.'
        : 'Доступ к контактам не предоставлен.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  } finally {
    _guestDialogVisible = false;
  }
}

Future<void> _showContactsResult(BuildContext context, int count) async {
  _guestDialogVisible = true;
  try {
    final text = count > 0
        ? 'Мы нашли рекомендации ваших знакомых для $count ${_serviceWord(count)}. Они отмечены в каталоге.'
        : 'Пока совпадений нет. Каталог всё равно доступен, а новые рекомендации могут появиться позже.';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          count > 0 ? Icons.recommend_rounded : Icons.explore_outlined,
          color: FlutterFlowTheme.of(dialogContext).primary,
          size: 40,
        ),
        title: Text(
          count > 0 ? 'Есть рекомендации знакомых' : 'Продолжайте знакомство',
          textAlign: TextAlign.center,
        ),
        content: Text(text, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Смотреть услуги'),
          ),
        ],
      ),
    );
  } finally {
    _guestDialogVisible = false;
  }
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

String _serviceWord(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return 'услуги';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
    return 'услуг';
  }
  return 'услуг';
}

void resetGuestEngagementSession() {
  _guestLaunchRecorded = false;
  _guestDialogVisible = false;
}
