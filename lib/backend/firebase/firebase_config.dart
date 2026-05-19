import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBxRuIweYlCmcLiyCCDRZF_bWrCcLdtN7U",
            authDomain: "trusty-kzh1sb.firebaseapp.com",
            projectId: "trusty-kzh1sb",
            storageBucket: "trusty-kzh1sb.firebasestorage.app",
            messagingSenderId: "592998402745",
            appId: "1:592998402745:web:740f02638732221f03a968"));
  } else {
    await Firebase.initializeApp();
  }
}
