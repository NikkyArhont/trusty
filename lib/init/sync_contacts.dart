import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _contactsCacheKey = 'contacts_sync_cache';
const _contactsLastSyncKey = 'contacts_last_sync_ms';

// Global map to store normalized phone to contact name mapping.
Map<String, String> globalContactsMap = {};
Map<String, String> _globalContactHashesMap = {};

void _replaceGlobalContacts(Map<String, String> contacts) {
  globalContactsMap = contacts;
  _globalContactHashesMap = {
    for (final contact in contacts.entries)
      sha256.convert(utf8.encode(contact.key)).toString(): contact.value.trim(),
  };
}

String? contactNameForPhoneHash(String phoneHash) {
  final normalizedHash = phoneHash.trim().toLowerCase();
  if (normalizedHash.isEmpty) return null;
  return _globalContactHashesMap[normalizedHash];
}

Future<DateTime?> getLastContactsSyncDate() async {
  final prefs = await SharedPreferences.getInstance();
  final milliseconds = prefs.getInt(_contactsLastSyncKey);
  return milliseconds == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(milliseconds);
}

bool isContactsSyncOlderThanThreeMonths(
  DateTime lastSyncDate, {
  DateTime? now,
}) {
  final currentDate = now ?? DateTime.now();
  final targetMonthStart = DateTime(currentDate.year, currentDate.month - 3);
  final targetMonthLastDay = DateTime(
    targetMonthStart.year,
    targetMonthStart.month + 1,
    0,
  ).day;
  final thresholdDay = currentDate.day > targetMonthLastDay
      ? targetMonthLastDay
      : currentDate.day;
  final threshold = DateTime(
    targetMonthStart.year,
    targetMonthStart.month,
    thresholdDay,
    currentDate.hour,
    currentDate.minute,
    currentDate.second,
    currentDate.millisecond,
    currentDate.microsecond,
  );
  return lastSyncDate.isBefore(threshold);
}

Future<void> _loadCachedContacts() async {
  if (!await hasContactsPermission()) {
    _replaceGlobalContacts({});
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final encodedContacts = prefs.getString(_contactsCacheKey);
  if (encodedContacts == null || encodedContacts.isEmpty) {
    _replaceGlobalContacts({});
    return;
  }

  final decodedContacts = jsonDecode(encodedContacts);
  if (decodedContacts is Map<String, dynamic>) {
    _replaceGlobalContacts(
      decodedContacts.map(
        (phone, name) => MapEntry(phone, name?.toString() ?? ''),
      ),
    );
  }
}

Future<void> _saveContactsSync(
  Map<String, String> contacts,
  DateTime synchronizedAt,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_contactsCacheKey, jsonEncode(contacts));
  await prefs.setInt(
    _contactsLastSyncKey,
    synchronizedAt.millisecondsSinceEpoch,
  );
}

Future<bool> hasContactsPermission() async {
  if (kIsWeb) {
    return false;
  }
  try {
    final status = await FlutterContacts.permissions.check(PermissionType.read);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  } catch (e) {
    print('Error checking contacts permission: $e');
    return false;
  }
}

Future<bool> syncContacts({bool requestPermission = false}) async {
  try {
    if (!requestPermission) {
      await _loadCachedContacts();
      return await getLastContactsSyncDate() != null;
    }

    if (kIsWeb) {
      return false;
    }

    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );
      Map<String, String> newMap = {};

      for (var contact in contacts) {
        if (contact.phones.isNotEmpty) {
          for (var phone in contact.phones) {
            String normalized = normalizePhone(phone.number);
            if (normalized.isNotEmpty) {
              // Store the display name
              newMap[normalized] = contact.displayName ?? '';
            }
          }
        }
      }
      _replaceGlobalContacts(newMap);
      await _saveContactsSync(newMap, DateTime.now());
      return true;
    }
  } catch (e) {
    print('Error syncing contacts: $e');
  }
  return false;
}

String normalizePhone(String rawPhone) {
  // Remove all non-digit characters
  String digitsOnly = rawPhone.replaceAll(RegExp(r'\D'), '');

  if (digitsOnly.isEmpty) return '';

  // Handle Russian prefixes +7 and 8
  if (digitsOnly.length == 11) {
    if (digitsOnly.startsWith('8')) {
      return '7${digitsOnly.substring(1)}';
    } else if (digitsOnly.startsWith('7')) {
      return digitsOnly;
    }
  } else if (digitsOnly.length == 10) {
    // Some people save as 9991112233 without prefix
    return '7$digitsOnly';
  }

  return digitsOnly;
}
