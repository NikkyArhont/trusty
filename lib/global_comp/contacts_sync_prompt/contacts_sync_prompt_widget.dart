import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/init/sync_contacts.dart';

bool _dismissedForCurrentSession = false;

class ContactsSyncPromptWidget extends StatefulWidget {
  const ContactsSyncPromptWidget({super.key, this.onSynchronized});

  final VoidCallback? onSynchronized;

  @override
  State<ContactsSyncPromptWidget> createState() =>
      _ContactsSyncPromptWidgetState();
}

class _ContactsSyncPromptWidgetState extends State<ContactsSyncPromptWidget> {
  bool _loading = true;
  bool _shouldShow = false;
  bool _synchronizing = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (_dismissedForCurrentSession) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    final permissionGranted = await hasContactsPermission();
    final lastSyncDate = await getLastContactsSyncDate();
    if (!mounted) {
      return;
    }
    setState(() {
      _shouldShow = !permissionGranted || lastSyncDate == null;
      _loading = false;
    });
  }

  Future<void> _synchronize() async {
    if (_synchronizing) {
      return;
    }
    setState(() => _synchronizing = true);

    final synchronized = await syncContacts(requestPermission: true);
    if (!mounted) {
      return;
    }

    if (synchronized) {
      setState(() => _shouldShow = false);
      widget.onSynchronized?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Контакты синхронизированы')),
      );
    } else {
      setState(() => _synchronizing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось синхронизировать контакты. Проверьте разрешение в настройках.',
          ),
        ),
      );
    }
  }

  void _dismiss() {
    _dismissedForCurrentSession = true;
    setState(() => _shouldShow = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_shouldShow) {
      return const SizedBox.shrink();
    }

    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 6.0, 12.0),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.people_outline_rounded,
              size: 20.0,
              color: theme.primary,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Синхронизируйте контакты',
                  style: theme.titleSmall.override(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3.0),
                Text(
                  'Возможно, кто-то из ваших знакомых уже был у этого специалиста.',
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: _synchronizing ? null : _synchronize,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32.0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _synchronizing
                      ? SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: theme.primary,
                          ),
                        )
                      : const Text('Синхронизировать'),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Закрыть',
            onPressed: _dismiss,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.close_rounded,
              size: 18.0,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
