import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AppUpdateAnnouncementResult {
  const AppUpdateAnnouncementResult({
    required this.recipientCount,
    required this.successCount,
    required this.failureCount,
  });

  final int recipientCount;
  final int successCount;
  final int failureCount;
}

Future<AppUpdateAnnouncementResult> announceAppUpdate() async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null || token.isEmpty) {
    throw StateError('Администратор не авторизован');
  }

  final response = await http
      .post(
        Uri.parse(
          'https://us-central1-trusty-kzh1sb.cloudfunctions.net/announceAppUpdate',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'confirmation': 'SEND_APP_UPDATE_PUSH'}),
      )
      .timeout(const Duration(seconds: 120));
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200) {
    throw StateError(
      (data['details'] ?? data['error'] ?? 'Не удалось отправить уведомление')
          .toString(),
    );
  }
  return AppUpdateAnnouncementResult(
    recipientCount: (data['recipientCount'] as num?)?.toInt() ?? 0,
    successCount: (data['successCount'] as num?)?.toInt() ?? 0,
    failureCount: (data['failureCount'] as num?)?.toInt() ?? 0,
  );
}
