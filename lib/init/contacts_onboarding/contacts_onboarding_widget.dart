import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/init/sync_contacts.dart';

class ContactsOnboardingWidget extends StatefulWidget {
  const ContactsOnboardingWidget({super.key});

  @override
  State<ContactsOnboardingWidget> createState() =>
      _ContactsOnboardingWidgetState();
}

class _ContactsOnboardingWidgetState extends State<ContactsOnboardingWidget> {
  bool _saving = false;

  Future<void> _finish(bool enableContacts) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (enableContacts) {
        await syncContacts(requestPermission: true);
      }

      if (mounted) {
        context.goNamed(
          ChooseLocationCityWidget.routeName,
          queryParameters: {
            'edit': serializeParam(false, ParamType.bool),
          }.withoutNulls,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _saving ? null : () => _finish(false),
                          child: const Text('Не сейчас'),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.group_rounded,
                                size: 64,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Рекомендации от своих',
                              textAlign: TextAlign.center,
                              style: theme.headlineMedium.copyWith(
                                color: theme.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Включите синхронизацию контактов, чтобы видеть, каких специалистов рекомендуют ваши друзья и знакомые.',
                              textAlign: TextAlign.center,
                              style: theme.bodyLarge.copyWith(
                                color: theme.secondaryText,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 54),
                        child: FilledButton(
                          onPressed: _saving ? null : () => _finish(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: theme.info,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Продолжить',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
