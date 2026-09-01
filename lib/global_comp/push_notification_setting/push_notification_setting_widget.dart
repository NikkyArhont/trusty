import '/auth/firebase_auth/auth_util.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationSettingWidget extends StatefulWidget {
  const PushNotificationSettingWidget({super.key, this.compact = false});

  final bool compact;

  @override
  State<PushNotificationSettingWidget> createState() =>
      _PushNotificationSettingWidgetState();
}

class _PushNotificationSettingWidgetState
    extends State<PushNotificationSettingWidget> {
  PushPreferenceStatus? _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final status = await getPushPreferenceStatus();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _change(bool enabled) async {
    if (_saving || kIsWeb) return;
    setState(() => _saving = true);
    try {
      final status = await setPushPreferenceEnabled(enabled);
      if (!mounted) return;
      setState(() => _status = status);
      if (enabled && status == PushPreferenceStatus.systemDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Разрешите уведомления для Сарафана в настройках телефона.',
            ),
            action: SnackBarAction(
              label: 'Настройки',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось изменить настройку push')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _description {
    if (kIsWeb) return 'Настройка доступна в мобильном приложении';
    return switch (_status) {
      PushPreferenceStatus.enabled => 'Push-уведомления включены',
      PushPreferenceStatus.disabledByUser => 'Push-уведомления выключены',
      PushPreferenceStatus.systemDenied =>
        'Уведомления заблокированы в настройках телефона',
      PushPreferenceStatus.unavailable =>
        'Устройство пока не зарегистрировано для push',
      null => 'Проверяем состояние уведомлений…',
    };
  }

  bool get _enabled {
    if (_status == PushPreferenceStatus.disabledByUser) return false;
    if (!kIsWeb && _status != null) return true;
    return currentUserDocument?.pushNotificationsEnabled ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.all(widget.compact ? 14 : 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(widget.compact ? 12 : 16),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: theme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Push-уведомления',
                  style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  _description,
                  style: theme.bodySmall.override(
                    color: _status == PushPreferenceStatus.systemDenied
                        ? theme.error
                        : theme.secondaryText,
                  ),
                ),
                if (_status == PushPreferenceStatus.systemDenied)
                  TextButton(
                    onPressed: openAppSettings,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Открыть настройки телефона'),
                  ),
              ],
            ),
          ),
          if (_saving)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.primary,
              ),
            )
          else
            Switch.adaptive(
              value: _enabled,
              onChanged: kIsWeb ? null : _change,
              activeTrackColor: theme.primary,
            ),
        ],
      ),
    );
  }
}
