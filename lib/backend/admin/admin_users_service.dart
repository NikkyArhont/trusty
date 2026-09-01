import 'dart:convert';

import '/auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AdminUsersService {
  AdminUsersService._();

  static final instance = AdminUsersService._();
  List<AdminUserInfo>? _cache;

  Future<List<AdminUserInfo>> load({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    final phone = currentPhoneNumber.replaceAll(RegExp(r'\D'), '');
    if (phone != '79183633636') throw StateError('Доступ запрещён');
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) throw StateError('Нет авторизации');

    final response = await http
        .get(
          Uri.parse(
            'https://us-central1-trusty-kzh1sb.cloudfunctions.net/getAdminUsers',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(
        (body['details'] ?? body['error'] ?? 'Ошибка загрузки').toString(),
      );
    }
    _cache = (body['users'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => AdminUserInfo.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return _cache!;
  }

  AdminUserInfo? findCached(String userId) {
    for (final user in _cache ?? const <AdminUserInfo>[]) {
      if (user.id == userId) return user;
    }
    return null;
  }
}

class AdminUserInfo {
  const AdminUserInfo({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.photo,
    required this.bio,
    required this.createdAt,
    required this.lastActiveAt,
    required this.hasActiveDevice,
    required this.pushNotificationsEnabled,
    required this.isGuest,
    required this.registrationComplete,
    required this.clientCity,
    required this.masterStarted,
    required this.masterComplete,
    required this.master,
    required this.services,
  });

  factory AdminUserInfo.fromJson(Map<String, dynamic> json) {
    DateTime? date(String key) => DateTime.tryParse(json[key] as String? ?? '');
    return AdminUserInfo(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Пользователь',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      createdAt: date('createdAt'),
      lastActiveAt: date('lastActiveAt'),
      hasActiveDevice: json['hasActiveDevice'] == true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] != false,
      isGuest: json['isGuest'] == true,
      registrationComplete: json['registrationComplete'] == true,
      clientCity: json['clientCity'] as String? ?? '',
      masterStarted: json['masterStarted'] == true,
      masterComplete: json['masterComplete'] == true,
      master: AdminMasterInfo.fromJson(
        Map<String, dynamic>.from(json['master'] as Map? ?? const {}),
      ),
      services: (json['services'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                AdminServiceInfo.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  final String id;
  final String displayName;
  final String phone;
  final String email;
  final String photo;
  final String bio;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final bool hasActiveDevice;
  final bool pushNotificationsEnabled;
  final bool isGuest;
  final bool registrationComplete;
  final String clientCity;
  final bool masterStarted;
  final bool masterComplete;
  final AdminMasterInfo master;
  final List<AdminServiceInfo> services;

  bool get hasClientCity => clientCity.trim().isNotEmpty;
  bool get hasMasterCity => master.city.trim().isNotEmpty;
  bool get hasServices => services.isNotEmpty;
  String get searchableText => [
    displayName,
    phone,
    email,
    clientCity,
    master.title,
    master.city,
  ].join(' ').toLowerCase();
}

class AdminMasterInfo {
  const AdminMasterInfo({
    required this.title,
    required this.description,
    required this.categoryKey,
    required this.photo,
    required this.city,
    required this.onboardingComplete,
    required this.profileCompleteFlag,
  });

  factory AdminMasterInfo.fromJson(Map<String, dynamic> json) =>
      AdminMasterInfo(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        categoryKey: json['categoryKey'] as String? ?? '',
        photo: json['photo'] as String? ?? '',
        city: json['city'] as String? ?? '',
        onboardingComplete: json['onboardingComplete'] == true,
        profileCompleteFlag: json['profileCompleteFlag'] == true,
      );

  final String title;
  final String description;
  final String categoryKey;
  final String photo;
  final String city;
  final bool onboardingComplete;
  final bool profileCompleteFlag;
}

class AdminServiceInfo {
  const AdminServiceInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.durationUnit,
    required this.categoryKey,
    required this.city,
    required this.status,
    required this.image,
    required this.moderationReason,
  });

  factory AdminServiceInfo.fromJson(Map<String, dynamic> json) =>
      AdminServiceInfo(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Без названия',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        durationUnit: json['durationUnit'] as String? ?? 'min',
        categoryKey: json['categoryKey'] as String? ?? '',
        city: json['city'] as String? ?? '',
        status: json['status'] as String? ?? 'unknown',
        image: json['image'] as String? ?? '',
        moderationReason: json['moderationReason'] as String? ?? '',
      );

  final String id;
  final String title;
  final String description;
  final int price;
  final int duration;
  final String durationUnit;
  final String categoryKey;
  final String city;
  final String status;
  final String image;
  final String moderationReason;
}
