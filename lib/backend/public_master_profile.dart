import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/backend/schema/user_record.dart';

final Map<String, UserRecord> _publicMasterProfileCache = {};
final Map<String, Future<UserRecord?>> _publicMasterProfileLoads = {};

Future<UserRecord?> loadPublicMasterProfile(DocumentReference ownerRef) {
  final cachedProfile = _publicMasterProfileCache[ownerRef.id];
  if (cachedProfile != null) return Future.value(cachedProfile);

  final load = _publicMasterProfileLoads.putIfAbsent(
    ownerRef.id,
    () => _fetchPublicMasterProfile(ownerRef),
  );
  return load.then((profile) {
    if (profile != null && profile.contactPhoneHash.isNotEmpty) {
      _publicMasterProfileCache[ownerRef.id] = profile;
    }
    if (identical(_publicMasterProfileLoads[ownerRef.id], load)) {
      _publicMasterProfileLoads.remove(ownerRef.id);
    }
    return profile;
  });
}

Future<UserRecord?> _fetchPublicMasterProfile(
  DocumentReference ownerRef,
) async {
  UserRecord? storedProfile;
  try {
    final publicSnapshot = await FirebaseFirestore.instance
        .collection('publicMasterProfiles')
        .doc(ownerRef.id)
        .get();
    if (publicSnapshot.exists) {
      storedProfile = _profileFromPublicData(
        publicSnapshot.data() ?? {},
        ownerRef,
      );
      if (storedProfile.contactPhoneHash.isNotEmpty) return storedProfile;
    }

    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) return storedProfile;

    final uri = Uri.https(
      'us-central1-trusty-kzh1sb.cloudfunctions.net',
      '/getPublicMasterProfile',
      {'masterId': ownerRef.id},
    );
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) return storedProfile;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _profileFromPublicData(data, ownerRef);
  } catch (error) {
    debugPrint('Failed to load public master profile: $error');
    return storedProfile;
  }
}

UserRecord _profileFromPublicData(
  Map<String, dynamic> data,
  DocumentReference ownerRef,
) {
  return UserRecord.getDocumentFromData({
    'masterData': {
      'title': data['title'] as String? ?? '',
      'mainPhoto': data['photo'] as String? ?? '',
      'descrip': data['description'] as String? ?? '',
      'initCat': data['categoryKey'] as String? ?? '',
    },
    'contactPhoneHash': data['contactPhoneHash'] as String? ?? '',
  }, ownerRef);
}
