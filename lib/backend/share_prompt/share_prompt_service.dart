import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/master/client_invite_guide_dialog.dart';

const String sharePromptLandingUrl = 'https://trusty-kzh1sb.web.app/';
const Duration _sharePromptInterval = Duration(days: 4);

bool _sharePromptCheckInProgress = false;
bool _sharePromptDialogVisible = false;
final Set<String> _sharePromptHandledUsers = <String>{};
const String _clientInviteGuideAnnouncementVersion = '1.4.2';

Future<bool> showClientInviteGuideAnnouncementIfNeeded() async {
  if (currentUserIsAnonymous) return false;
  final userRef = currentUserReference;
  final userId = currentUserUid;
  if (userRef == null ||
      userId.isEmpty ||
      _sharePromptCheckInProgress ||
      _sharePromptDialogVisible) {
    return false;
  }

  _sharePromptCheckInProgress = true;
  try {
    final shouldShow = await FirebaseFirestore.instance.runTransaction<bool>((
      transaction,
    ) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return false;
      final data = snapshot.data() as Map<String, dynamic>? ?? const {};
      if (data['clientInviteGuideAnnouncementVersion'] ==
          _clientInviteGuideAnnouncementVersion) {
        return false;
      }
      transaction.set(userRef, {
        'clientInviteGuideAnnouncementVersion':
            _clientInviteGuideAnnouncementVersion,
        'clientInviteGuideAnnouncementShownAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    });
    if (!shouldShow) return false;

    BuildContext? context;
    for (var attempt = 0; attempt < 20; attempt++) {
      context = appNavigatorKey.currentContext;
      if (context != null && context.mounted) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (context == null || !context.mounted) return false;

    _sharePromptDialogVisible = true;
    final showGuide = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = FlutterFlowTheme.of(dialogContext);
        return AlertDialog(
          icon: Icon(
            Icons.auto_awesome_rounded,
            color: theme.primary,
            size: 40,
          ),
          title: const Text(
            'Нововведение — как мастерам быстро собрать рекомендации от старых клиентов',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Мы подготовили короткую инструкцию — покажем весь процесс по шагам.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Покажите как!'),
            ),
          ],
        );
      },
    );
    _sharePromptDialogVisible = false;
    if (showGuide == true && context.mounted) {
      await showClientInviteGuideDialog(context);
    }
    return true;
  } catch (error) {
    if (kDebugMode) {
      print('Client invite guide announcement error: $error');
    }
    return false;
  } finally {
    _sharePromptCheckInProgress = false;
    _sharePromptDialogVisible = false;
  }
}

DateTime? _dateFromFirestore(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

Future<void> showSharePromptIfEligible({bool force = false}) async {
  if (currentUserIsAnonymous) return;
  if (!force && await showClientInviteGuideAnnouncementIfNeeded()) return;
  final userRef = currentUserReference;
  final userId = currentUserUid;
  if (userRef == null ||
      userId.isEmpty ||
      _sharePromptCheckInProgress ||
      _sharePromptDialogVisible ||
      _sharePromptHandledUsers.contains(userId)) {
    return;
  }

  _sharePromptCheckInProgress = true;
  try {
    final snapshot = await userRef.get();
    if (!snapshot.exists) return;
    final data = snapshot.data() as Map<String, dynamic>? ?? const {};
    final createdAt = _dateFromFirestore(data['created_time']);
    final shownAt = _dateFromFirestore(data['sharePromptShownAt']);
    final sharedAt = _dateFromFirestore(data['sharePromptSharedAt']);
    final lastInteraction = [shownAt, sharedAt]
        .whereType<DateTime>()
        .fold<DateTime?>(null, (latest, value) {
          if (latest == null || value.isAfter(latest)) return value;
          return latest;
        });
    final intervalElapsed =
        lastInteraction != null &&
        DateTime.now().difference(lastInteraction) >= _sharePromptInterval;
    final registrationDelayElapsed =
        createdAt != null &&
        lastInteraction == null &&
        DateTime.now().difference(createdAt) >= _sharePromptInterval;
    final eligibleAt = _dateFromFirestore(data['sharePromptEligibleAt']);
    final milestonePending =
        eligibleAt != null &&
        (lastInteraction == null || eligibleAt.isAfter(lastInteraction));
    final eligible =
        force ||
        milestonePending ||
        registrationDelayElapsed ||
        intervalElapsed;
    if (!eligible) return;

    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    _sharePromptHandledUsers.add(userId);
    _sharePromptDialogVisible = true;
    await userRef.set({
      'sharePromptShownAt': FieldValue.serverTimestamp(),
      'sharePromptReason':
          data['sharePromptReason'] ??
          (force ? 'push_opened' : 'registration_four_days'),
    }, SetOptions(merge: true));

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SharePromptDialog(userRef: userRef),
    );
  } catch (error) {
    _sharePromptHandledUsers.remove(userId);
    if (kDebugMode) {
      print('Share prompt error: $error');
    }
  } finally {
    _sharePromptCheckInProgress = false;
    _sharePromptDialogVisible = false;
  }
}

Future<void> showProjectShareDialog(BuildContext context) async {
  final userRef = currentUserReference;
  final userId = currentUserUid;
  if (userRef == null ||
      userId.isEmpty ||
      !context.mounted ||
      _sharePromptDialogVisible) {
    return;
  }

  _sharePromptDialogVisible = true;
  _sharePromptHandledUsers.add(userId);
  try {
    try {
      await userRef.set({
        'sharePromptShownAt': FieldValue.serverTimestamp(),
        'sharePromptReason': 'profile_help_project',
      }, SetOptions(merge: true));
    } catch (error) {
      if (kDebugMode) {
        print('Could not save manual share prompt state: $error');
      }
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SharePromptDialog(userRef: userRef),
    );
  } finally {
    _sharePromptDialogVisible = false;
  }
}

Future<void> showFirstServiceInviteDialog() async {
  final userRef = currentUserReference;
  final userId = currentUserUid;
  if (userRef == null || userId.isEmpty || _sharePromptDialogVisible) return;

  _sharePromptDialogVisible = true;
  try {
    final shouldShow = await FirebaseFirestore.instance.runTransaction<bool>((
      transaction,
    ) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return false;
      final data = snapshot.data() as Map<String, dynamic>? ?? const {};
      if (data['firstServiceInviteShownAt'] != null) return false;
      transaction.set(userRef, {
        'firstServiceInviteShownAt': FieldValue.serverTimestamp(),
        'sharePromptShownAt': FieldValue.serverTimestamp(),
        'sharePromptReason': 'first_service_invite',
      }, SetOptions(merge: true));
      return true;
    });
    if (!shouldShow) return;

    _sharePromptHandledUsers.add(userId);
    BuildContext? context;
    for (var attempt = 0; attempt < 10; attempt++) {
      context = appNavigatorKey.currentContext;
      if (context != null && context.mounted) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (context == null || !context.mounted) return;

    await showClientInviteGuideDialog(context);
  } catch (error) {
    if (kDebugMode) print('First service invite error: $error');
  } finally {
    _sharePromptDialogVisible = false;
  }
}

void resetSharePromptState() {
  _sharePromptCheckInProgress = false;
  _sharePromptDialogVisible = false;
  _sharePromptHandledUsers.clear();
}

class _SharePromptDialog extends StatefulWidget {
  const _SharePromptDialog({
    required this.userRef,
    this.title = 'Помогите Сарафану расти',
    this.body =
        'Спасибо, что пользуетесь Сарафаном! Мы очень стараемся, чтобы приложение было удобным и полезным. Поделитесь им с друзьями и в социальных сетях — так клиенты смогут находить проверенных мастеров, а мастера — расширять свой сарафан связей.',
    this.shareText =
        'Попробуйте Сарафан — здесь находят проверенных мастеров по рекомендациям знакомых.\n\n$sharePromptLandingUrl',
    this.icon = Icons.volunteer_activism_rounded,
  });

  final DocumentReference userRef;
  final String title;
  final String body;
  final String shareText;
  final IconData icon;

  @override
  State<_SharePromptDialog> createState() => _SharePromptDialogState();
}

class _SharePromptDialogState extends State<_SharePromptDialog> {
  bool _sharing = false;

  Future<void> _share(BuildContext buttonContext) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final renderBox = buttonContext.findRenderObject() as RenderBox?;
      final origin = renderBox == null
          ? null
          : renderBox.localToGlobal(Offset.zero) & renderBox.size;
      final result = await Share.share(
        widget.shareText,
        subject: 'Сарафан — проверенные мастера рядом',
        sharePositionOrigin: origin,
      );
      if (result.status == ShareResultStatus.success) {
        await widget.userRef.set({
          'sharePromptSharedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (error) {
      if (kDebugMode) {
        print('Sharing failed: $error');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть меню «Поделиться»')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight:
              MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).vertical -
              48,
        ),
        child: Material(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                  child: Icon(widget.icon, color: theme.primary, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.headlineSmall.copyWith(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.body,
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.copyWith(
                    color: theme.secondaryText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Builder(
                  builder: (buttonContext) => FilledButton.icon(
                    onPressed: _sharing ? null : () => _share(buttonContext),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _sharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.ios_share_rounded),
                    label: Text(
                      _sharing ? 'Открываем...' : 'Поделиться',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _sharing ? null : () => Navigator.pop(context),
                  child: const Text('Не сейчас'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
