import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserActivityService {
  UserActivityService._();

  static final instance = UserActivityService._();
  DateTime? _lastSentAt;

  Future<void> markActive() async {
    final userRef = currentUserReference;
    if (userRef == null) return;
    final now = DateTime.now();
    if (_lastSentAt != null && now.difference(_lastSentAt!).inMinutes < 10) {
      return;
    }
    _lastSentAt = now;
    try {
      await userRef.set({
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      _lastSentAt = null;
    }
  }
}
