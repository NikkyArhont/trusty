import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/backend/schema/service_record.dart';

const _legacyContactsCacheKey = 'contacts_sync_cache';
const _contactsHashCacheKey = 'contacts_hash_cache_v2';
const _contactsLastSyncKey = 'contacts_last_sync_ms';

// Global map to store normalized phone to contact name mapping.
Map<String, String> globalContactsMap = {};
Map<String, String> _globalContactHashesMap = {};
Map<String, String> _globalContactPhonesByHash = {};

String phoneHash(String normalizedPhone) =>
    sha256.convert(utf8.encode(normalizedPhone)).toString();

void _replaceGlobalContacts(Map<String, String> contacts) {
  globalContactsMap = contacts;
  _globalContactHashesMap = {
    for (final contact in contacts.entries)
      phoneHash(contact.key): contact.value.trim(),
  };
  _globalContactPhonesByHash = {
    for (final contact in contacts.entries) phoneHash(contact.key): contact.key,
  };
}

void _replaceGlobalContactHashes(Map<String, String> contacts) {
  globalContactsMap = {};
  _globalContactPhonesByHash = {};
  _globalContactHashesMap = {
    for (final contact in contacts.entries)
      contact.key.trim().toLowerCase(): contact.value.trim(),
  }..removeWhere((hash, _) => hash.isEmpty);
}

String? contactNameForPhoneHash(String phoneHash) {
  final normalizedHash = phoneHash.trim().toLowerCase();
  if (normalizedHash.isEmpty) return null;
  return _globalContactHashesMap[normalizedHash];
}

String? contactNameForPhone(String rawPhone) {
  final normalized = normalizePhone(rawPhone);
  if (normalized.isEmpty) return null;
  return contactNameForPhoneHash(phoneHash(normalized));
}

String? contactPhoneForPhoneHash(String rawHash) {
  final normalizedHash = rawHash.trim().toLowerCase();
  if (normalizedHash.isEmpty) return null;
  return _globalContactPhonesByHash[normalizedHash];
}

String? contactPhoneForPhone(String rawPhone) {
  final normalized = normalizePhone(rawPhone);
  if (normalized.isEmpty) return null;
  return contactPhoneForPhoneHash(phoneHash(normalized));
}

Set<String> recommendationPhoneHashesForService(ServiceRecord service) {
  final hashes = <String>{
    ...service.recommenderPhoneHashes.map((hash) => hash.trim().toLowerCase()),
  };
  for (final rawPhone in service.recommenderPhones) {
    final normalized = normalizePhone(rawPhone);
    if (normalized.isNotEmpty) hashes.add(phoneHash(normalized));
  }
  for (final recommendation in service.recommendations) {
    final savedHash = recommendation.phoneHash.trim().toLowerCase();
    if (savedHash.isNotEmpty) {
      hashes.add(savedHash);
      continue;
    }
    final normalized = normalizePhone(recommendation.phone);
    if (normalized.isNotEmpty) hashes.add(phoneHash(normalized));
  }
  hashes.removeWhere((hash) => hash.isEmpty);
  return hashes;
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
  final encodedContacts = prefs.getString(_contactsHashCacheKey);
  if (encodedContacts == null || encodedContacts.isEmpty) {
    final legacyContacts = prefs.getString(_legacyContactsCacheKey);
    if (legacyContacts == null || legacyContacts.isEmpty) {
      _replaceGlobalContactHashes({});
      return;
    }
    final decodedLegacy = jsonDecode(legacyContacts);
    if (decodedLegacy is Map<String, dynamic>) {
      final contacts = decodedLegacy.map(
        (phone, name) => MapEntry(phone, name?.toString() ?? ''),
      );
      _replaceGlobalContacts(contacts);
      await _saveContactsSync(contacts, DateTime.now());
    }
    return;
  }

  final decodedContacts = jsonDecode(encodedContacts);
  if (decodedContacts is Map<String, dynamic>) {
    _replaceGlobalContactHashes(
      decodedContacts.map(
        (hash, name) => MapEntry(hash, name?.toString() ?? ''),
      ),
    );
  }
}

Future<void> _saveContactsSync(
  Map<String, String> contacts,
  DateTime synchronizedAt,
) async {
  final prefs = await SharedPreferences.getInstance();
  final hashedContacts = <String, String>{
    for (final contact in contacts.entries)
      phoneHash(contact.key): contact.value.trim(),
  }..removeWhere((hash, _) => hash.isEmpty);
  await prefs.setString(_contactsHashCacheKey, jsonEncode(hashedContacts));
  await prefs.remove(_legacyContactsCacheKey);
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

Future<Map<String, String>> _readDeviceContacts() async {
  final contacts = await FlutterContacts.getAll(
    properties: {ContactProperty.phone},
  );
  final result = <String, String>{};

  for (final contact in contacts) {
    for (final phone in contact.phones) {
      final normalized = normalizePhone(phone.number);
      if (normalized.isNotEmpty) {
        result[normalized] = contact.displayName ?? '';
      }
    }
  }
  return result;
}

Future<bool> syncContacts({bool requestPermission = false}) async {
  try {
    if (!requestPermission) {
      await _loadCachedContacts();
      if (await hasContactsPermission()) {
        final currentContacts = await _readDeviceContacts();
        _replaceGlobalContacts(currentContacts);
        await _saveContactsSync(currentContacts, DateTime.now());
      }
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
      final newMap = await _readDeviceContacts();
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
