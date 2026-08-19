import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/master/edit_service/edit_service_widget.dart';
import '/master/record_page_master/record_page_master_widget.dart';
import '/user/chat/chat_widget.dart';
import 'package:flutter/material.dart';

class MasterNotificationsWidget extends StatelessWidget {
  const MasterNotificationsWidget({super.key});

  static String routeName = 'MasterNotifications';
  static String routePath = '/masterNotifications';

  Future<void> _markAllRead(List<NotificationRecord> notifications) async {
    final unread = notifications.where((item) => !item.read).toList();
    for (var offset = 0; offset < unread.length; offset += 450) {
      final batch = FirebaseFirestore.instance.batch();
      for (final notification in unread.skip(offset).take(450)) {
        batch.update(notification.reference, {'read': true});
      }
      await batch.commit();
    }
  }

  Future<void> _openNotification(
    BuildContext context,
    NotificationRecord notification,
  ) async {
    if (!notification.read) {
      await notification.reference.update({'read': true});
    }
    if (!context.mounted) {
      return;
    }

    if (notification.service != null) {
      final snapshot = await notification.service!.get();
      if (snapshot.exists && context.mounted) {
        final service = ServiceRecord.fromSnapshot(snapshot);
        if (notification.type == 'service_moderation' &&
            service.status == ServiceStatus.show) {
          return;
        }
        context.pushNamed(
          EditServiceWidget.routeName,
          queryParameters: {
            'servDoc': serializeParam(service, ParamType.Document),
          }.withoutNulls,
          extra: <String, dynamic>{'servDoc': service},
        );
      }
      return;
    }

    if (notification.record != null) {
      final snapshot = await notification.record!.get();
      if (snapshot.exists && context.mounted) {
        final record = RecordsRecord.fromSnapshot(snapshot);
        context.pushNamed(
          RecordPageMasterWidget.routeName,
          queryParameters: {
            'recordDoc': serializeParam(record, ParamType.Document),
          }.withoutNulls,
          extra: <String, dynamic>{'recordDoc': record},
        );
      }
      return;
    }

    if (notification.chat != null) {
      context.pushNamed(
        ChatWidget.routeName,
        queryParameters: {
          'chatId': serializeParam(notification.chat!.id, ParamType.String),
        }.withoutNulls,
      );
    }
  }

  IconData _iconFor(NotificationRecord notification) {
    if (notification.type == 'service_moderation') {
      return notification.title.toLowerCase().contains('отклон')
          ? Icons.error_outline_rounded
          : Icons.verified_rounded;
    }
    if (notification.chat != null) {
      return Icons.chat_bubble_outline_rounded;
    }
    if (notification.record != null) {
      return Icons.event_available_rounded;
    }
    return Icons.notifications_none_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final userRef = currentUserReference;
    final useCompactHeaderAction =
        MediaQuery.textScalerOf(context).scale(1.0) > 1.3;
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Назад',
                    onPressed: context.safePop,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Уведомления',
                      style: FlutterFlowTheme.of(context).titleLarge,
                    ),
                  ),
                  if (userRef != null)
                    StreamBuilder<List<NotificationRecord>>(
                      stream: queryNotificationRecord(
                        queryBuilder: (query) =>
                            query.where('user', isEqualTo: userRef),
                      ),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? const [];
                        final hasUnread = items.any((item) => !item.read);
                        final onPressed = hasUnread
                            ? () => _markAllRead(items)
                            : null;
                        if (useCompactHeaderAction) {
                          return IconButton(
                            tooltip: 'Прочитать все',
                            onPressed: onPressed,
                            icon: const Icon(Icons.done_all_rounded),
                          );
                        }
                        return TextButton(
                          onPressed: onPressed,
                          child: const Text('Прочитать все'),
                        );
                      },
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: FlutterFlowTheme.of(context).divider),
            Expanded(
              child: userRef == null
                  ? const _NotificationsEmpty()
                  : StreamBuilder<List<NotificationRecord>>(
                      stream: queryNotificationRecord(
                        queryBuilder: (query) =>
                            query.where('user', isEqualTo: userRef),
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final notifications = [...snapshot.data!]
                          ..sort((a, b) {
                            final aDate =
                                a.createdAt ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            final bDate =
                                b.createdAt ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            return bDate.compareTo(aDate);
                          });
                        if (notifications.isEmpty) {
                          return const _NotificationsEmpty();
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            final isRejection = notification.title
                                .toLowerCase()
                                .contains('отклон');
                            final accent = isRejection
                                ? FlutterFlowTheme.of(context).error
                                : FlutterFlowTheme.of(context).primary;
                            return Material(
                              color: notification.read
                                  ? FlutterFlowTheme.of(
                                      context,
                                    ).secondaryBackground
                                  : accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () =>
                                    _openNotification(context, notification),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: notification.read
                                          ? FlutterFlowTheme.of(context).divider
                                          : accent.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _iconFor(notification),
                                          color: accent,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notification.title.isEmpty
                                                        ? 'Уведомление'
                                                        : notification.title,
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).titleSmall,
                                                  ),
                                                ),
                                                if (!notification.read)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: accent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (notification.body.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 5,
                                                ),
                                                child: Text(
                                                  notification.body,
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).secondaryText,
                                                      ),
                                                ),
                                              ),
                                            if (notification.createdAt != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  dateTimeFormat(
                                                    'd MMMM, HH:mm',
                                                    notification.createdAt,
                                                    locale: 'ru',
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.override(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).secondaryText,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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

class MasterNotificationsBell extends StatelessWidget {
  const MasterNotificationsBell({super.key});

  @override
  Widget build(BuildContext context) {
    final userRef = currentUserReference;
    if (userRef == null) {
      return const SizedBox(width: 44, height: 44);
    }

    return StreamBuilder<List<NotificationRecord>>(
      stream: queryNotificationRecord(
        queryBuilder: (query) => query.where('user', isEqualTo: userRef),
      ),
      builder: (context, snapshot) {
        final unreadCount =
            snapshot.data?.where((item) => !item.read).length ?? 0;
        return SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IconButton(
                  tooltip: 'Уведомления',
                  onPressed: () =>
                      context.pushNamed(MasterNotificationsWidget.routeName),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'Уведомлений пока нет',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Здесь появятся решения по модерации и другие события мастера.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
