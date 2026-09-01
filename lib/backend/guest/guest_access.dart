import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/init/login/login_widget.dart';

Future<bool> requireRegisteredUser(
  BuildContext context, {
  String reason = 'Чтобы продолжить, подтвердите номер телефона.',
}) async {
  if (currentUserIsRegistered) return true;
  if (!context.mounted) return false;

  final shouldRegister = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _GuestRegistrationSheet(reason: reason),
  );
  if (shouldRegister == true && context.mounted) {
    context.pushNamed(LoginWidget.routeName);
  }
  return false;
}

class RegisteredUserGate extends StatelessWidget {
  const RegisteredUserGate({
    required this.child,
    required this.reason,
    super.key,
  });

  final Widget child;
  final String reason;

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAnonymous) return child;
    return GuestRegistrationPage(reason: reason);
  }
}

class GuestRegistrationPage extends StatelessWidget {
  const GuestRegistrationPage({required this.reason, super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/main'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: theme.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Завершите регистрацию',
                    textAlign: TextAlign.center,
                    style: theme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reason,
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium.override(
                      color: theme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.pushNamed(LoginWidget.routeName),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Подтвердить номер'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/main'),
                    child: const Text('Продолжить смотреть услуги'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestRegistrationSheet extends StatelessWidget {
  const _GuestRegistrationSheet({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(Icons.lock_open_rounded, color: theme.primary, size: 40),
          const SizedBox(height: 12),
          Text(
            'Нужна регистрация',
            textAlign: TextAlign.center,
            style: theme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Подтвердить номер'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Пока не сейчас'),
          ),
        ],
      ),
    );
  }
}
