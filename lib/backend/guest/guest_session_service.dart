import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/user_record.dart';
import '/flutter_flow/nav/nav.dart';

/// Creates a durable anonymous Firebase session for people who want to browse
/// before confirming their phone number.
Future<bool> ensureGuestSession(BuildContext context) async {
  if (loggedIn) return true;

  GoRouter.of(context).prepareAuthEvent();
  final guest = await authManager.signInAnonymously(context);
  if (guest == null) return false;

  final guestId = guest.uid?.trim() ?? '';
  if (guestId.isNotEmpty) {
    await UserRecord.collection.doc(guestId).set({
      'isGuest': true,
      'guestCreatedAt': FieldValue.serverTimestamp(),
      'pushNotificationsEnabled': true,
    }, SetOptions(merge: true));
  }
  return true;
}
