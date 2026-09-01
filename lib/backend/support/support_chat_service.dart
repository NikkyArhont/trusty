import 'dart:convert';

import '/auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const supportAccountName = 'Служба поддержки Сарафана';
const supportLogoAsset = 'assets/images/app_launcher_icon.png';
const supportAdminPhone = '79183633636';

bool get isCurrentSupportAdmin =>
    currentPhoneNumber.replaceAll(RegExp(r'\D'), '') == supportAdminPhone;

String get currentUserSupportChatId => 'support_$currentUserUid';

Future<String> ensureCurrentUserSupportChat() async {
  return _ensureSupportChat('ensureSupportChat');
}

Future<String> ensureSupportChatForUser(String userId) async {
  final normalizedUserId = userId.trim();
  if (normalizedUserId.isEmpty) {
    throw ArgumentError.value(userId, 'userId', 'Не указан пользователь');
  }
  return _ensureSupportChat(
    'ensureAdminSupportChat',
    body: {'userId': normalizedUserId},
  );
}

Future<String> _ensureSupportChat(
  String functionName, {
  Map<String, dynamic>? body,
}) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null || token.isEmpty) {
    throw StateError('Пользователь не авторизован');
  }

  final response = await http
      .post(
        Uri.parse(
          'https://us-central1-trusty-kzh1sb.cloudfunctions.net/$functionName',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body == null ? null : jsonEncode(body),
      )
      .timeout(const Duration(seconds: 20));
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200) {
    throw StateError(
      (data['details'] ?? data['error'] ?? 'Не удалось открыть поддержку')
          .toString(),
    );
  }

  final chatId = (data['chatId'] as String? ?? '').trim();
  if (chatId.isEmpty) throw StateError('Не получен идентификатор чата');
  return chatId;
}
