import 'dart:convert';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ReferralOnboardingWidget extends StatefulWidget {
  const ReferralOnboardingWidget({
    super.key,
    this.previewMode = false,
    this.profileMode = false,
  });

  final bool previewMode;
  final bool profileMode;

  static String routeName = 'ReferralOnboarding';
  static String routePath = '/referralOnboarding';

  @override
  State<ReferralOnboardingWidget> createState() =>
      _ReferralOnboardingWidgetState();
}

class _ReferralOnboardingWidgetState extends State<ReferralOnboardingWidget> {
  final _phoneController = TextEditingController(text: '+7');
  Map<String, dynamic>? _master;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _request(String action, {String? phone}) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) throw Exception('Нет авторизации');
    final response = await http
        .post(
          Uri.parse(
            'https://us-central1-trusty-kzh1sb.cloudfunctions.net/referralOnboarding',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'action': action,
            if (phone != null) 'phone': phone,
          }),
        )
        .timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Не удалось выполнить запрос');
    }
    return data;
  }

  Future<void> _lookup() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _master = null;
    });
    try {
      final result = await _request('lookup', phone: _phoneController.text);
      if (!mounted) return;
      if (result['found'] == true && result['master'] is Map) {
        setState(() => _master = Map<String, dynamic>.from(result['master']));
      } else {
        setState(() => _error = 'Мастер с таким номером не найден');
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finish(String action) async {
    if (_loading) return;
    if (widget.previewMode) {
      if (action == 'skip') {
        context.safePop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Это предпросмотр — связь не была установлена'),
          ),
        );
      }
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _request(
        action,
        phone: action == 'accept' ? _phoneController.text : null,
      );
      if (!mounted) return;
      final reference = currentUserReference;
      if (reference != null) {
        currentUserDocument = await UserRecord.getDocumentOnce(reference);
      }
      if (mounted) {
        if (widget.profileMode) {
          context.safePop();
        } else {
          context.goNamed(MainWidget.routeName);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 52,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : widget.profileMode
                          ? () => context.safePop()
                          : () => _finish('skip'),
                      child: Text(
                        widget.profileMode ? 'Закрыть' : 'Пропустить',
                      ),
                    ),
                  ),
                  if (widget.previewMode)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Режим предпросмотра — данные не изменяются',
                        textAlign: TextAlign.center,
                        style: theme.bodySmall.override(
                          color: theme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group_add_rounded,
                      size: 50,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Вас пригласил мастер?',
                    textAlign: TextAlign.center,
                    style: theme.headlineMedium.override(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Укажите его номер телефона — мы найдём профиль и сохраним, кто пригласил вас в Сарафан.',
                    textAlign: TextAlign.center,
                    style: theme.bodyLarge.override(
                      color: theme.secondaryText,
                      lineHeight: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d+\s()\-]')),
                      LengthLimitingTextInputFormatter(18),
                    ],
                    onChanged: (_) => setState(() {
                      _master = null;
                      _error = null;
                    }),
                    onSubmitted: (_) => _lookup(),
                    decoration: InputDecoration(
                      labelText: 'Номер телефона мастера',
                      hintText: '+7 999 000-00-00',
                      filled: true,
                      fillColor: theme.secondaryBackground,
                      prefixIcon: const Icon(Icons.phone_rounded),
                      suffixIcon: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search_rounded),
                              onPressed: _lookup,
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: theme.bodyMedium.override(color: theme.error),
                    ),
                  ],
                  if (_master != null) ...[
                    const SizedBox(height: 18),
                    _MasterCard(master: _master!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading ? null : () => _finish('accept'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: theme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Да, меня пригласил этот мастер'),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _loading ? null : _lookup,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Найти мастера'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MasterCard extends StatelessWidget {
  const _MasterCard({required this.master});

  final Map<String, dynamic> master;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final photo = '${master['photoUrl'] ?? ''}';
    final name = '${master['displayName'] ?? ''}'.trim();
    final title = '${master['masterTitle'] ?? ''}'.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.primary.withValues(alpha: 0.12),
            backgroundImage: photo.isNotEmpty
                ? CachedNetworkImageProvider(photo)
                : null,
            child: photo.isEmpty
                ? Icon(Icons.person_rounded, color: theme.primary, size: 34)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : 'Мастер',
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (name.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: theme.bodyMedium.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.check_circle_outline_rounded, color: theme.primary),
        ],
      ),
    );
  }
}
