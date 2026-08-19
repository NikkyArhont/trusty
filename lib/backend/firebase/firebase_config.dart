import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
_firestoreWarmupSubscription;
StreamSubscription<User?>? _firestoreWarmupAuthSubscription;
String? _firestoreWarmupUid;
Future<void>? _firestoreWarmupReady;

Future<void> _keepFirestoreWarm(User? user) {
  final uid = user?.uid;
  if (_firestoreWarmupUid == uid) {
    return _firestoreWarmupReady ?? Future.value();
  }

  _firestoreWarmupUid = uid;
  final previousSubscription = _firestoreWarmupSubscription;
  _firestoreWarmupSubscription = null;
  if (previousSubscription != null) {
    unawaited(previousSubscription.cancel());
  }
  if (user == null) {
    _firestoreWarmupReady = Future.value();
    return _firestoreWarmupReady!;
  }

  final ready = Completer<void>();

  _firestoreWarmupSubscription = FirebaseFirestore.instance
      .collection('user')
      .doc(user.uid)
      .snapshots()
      .listen(
        (_) {
          if (!ready.isCompleted) ready.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!ready.isCompleted) ready.complete();
          if (kDebugMode) debugPrint('Firestore warmup listener: $error');
        },
      );

  _firestoreWarmupReady = ready.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () {},
  );
  return _firestoreWarmupReady!;
}

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBxRuIweYlCmcLiyCCDRZF_bWrCcLdtN7U',
        authDomain: 'trusty-kzh1sb.firebaseapp.com',
        projectId: 'trusty-kzh1sb',
        storageBucket: 'trusty-kzh1sb.firebasestorage.app',
        messagingSenderId: '592998402745',
        appId: '1:592998402745:web:740f02638732221f03a968',
      ),
    );
    await _keepFirestoreWarm(FirebaseAuth.instance.currentUser);
    _firestoreWarmupAuthSubscription ??= FirebaseAuth.instance
        .authStateChanges()
        .listen((user) => unawaited(_keepFirestoreWarm(user)));
  } else {
    await Firebase.initializeApp();
  }
}
