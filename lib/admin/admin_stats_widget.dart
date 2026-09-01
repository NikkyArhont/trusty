import 'dart:convert';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminStatsWidget extends StatefulWidget {
  const AdminStatsWidget({super.key});

  static String routeName = 'AdminStats';
  static String routePath = '/adminStats';

  @override
  State<AdminStatsWidget> createState() => _AdminStatsWidgetState();
}

class _AdminStatsWidgetState extends State<AdminStatsWidget> {
  late Future<Map<String, dynamic>> _statsFuture;

  bool get _isAdmin {
    final phone = currentPhoneNumber.isNotEmpty
        ? currentPhoneNumber
        : (currentUserDocument?.phoneNumber ?? '');
    return phone.replaceAll(RegExp(r'\D'), '') == '79183633636';
  }

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<Map<String, dynamic>> _loadStats() async {
    if (!_isAdmin) throw Exception('Доступ запрещён');
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) throw Exception('Нет авторизации');

    final response = await http
        .get(
          Uri.parse(
            'https://us-central1-trusty-kzh1sb.cloudfunctions.net/getAdminStats',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['details'] ?? data['error'] ?? 'Ошибка загрузки');
    }
    return data;
  }

  Future<void> _refresh() async {
    final future = _loadStats();
    setState(() => _statsFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
              child: Row(
                children: [
                  const NavBackWidget(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Статистика',
                      style: theme.headlineSmall.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: theme.primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return _ErrorState(onRetry: _refresh);
                  }
                  final data = snapshot.data ?? const <String, dynamic>{};
                  final cities = (data['cities'] as List? ?? const [])
                      .whereType<Map>()
                      .map((row) => Map<String, dynamic>.from(row))
                      .toList();
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: theme.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _TotalCard(
                                icon: Icons.people_alt_rounded,
                                label: 'Пользователи',
                                value: data['usersTotal'] ?? 0,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TotalCard(
                                icon: Icons.badge_rounded,
                                label: 'Мастера',
                                value: data['mastersTotal'] ?? 0,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TotalCard(
                                icon: Icons.design_services_rounded,
                                label: 'Услуги',
                                value: data['servicesTotal'] ?? 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'По городам',
                          style: theme.titleLarge.override(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (cities.isEmpty)
                          const _EmptyState()
                        else
                          ...cities.map(
                            (row) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CityCard(data: row),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Object value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.headlineSmall.override(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: theme.bodySmall.override(color: theme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data['city'] ?? 'Город не указан'}',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CityMetric(label: 'Пользователи', value: data['users']),
              ),
              Expanded(
                child: _CityMetric(label: 'Мастера', value: data['masters']),
              ),
              Expanded(
                child: _CityMetric(label: 'Услуги', value: data['services']),
              ),
            ],
          ),
          if (data['city'] == 'Город не указан') ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: theme.divider),
            const SizedBox(height: 12),
            _CityDetailMetric(
              label: 'Не завершили регистрацию',
              value: data['incompleteProfiles'],
            ),
            const SizedBox(height: 8),
            _CityDetailMetric(
              label: 'Завершили профиль, но не указали город',
              value: data['completedProfilesWithoutCity'],
            ),
            const SizedBox(height: 8),
            _CityDetailMetric(
              label: 'Есть активное устройство',
              value: data['activeUsersWithoutCity'],
            ),
          ],
        ],
      ),
    );
  }
}

class _CityDetailMetric extends StatelessWidget {
  const _CityDetailMetric({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${value ?? 0}',
          style: theme.bodyMedium.override(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CityMetric extends StatelessWidget {
  const _CityMetric({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        Text(
          '${value ?? 0}',
          style: theme.titleLarge.override(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: theme.secondaryText),
            const SizedBox(height: 12),
            const Text('Не удалось загрузить статистику'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: Text('Данных по городам пока нет')),
  );
}
