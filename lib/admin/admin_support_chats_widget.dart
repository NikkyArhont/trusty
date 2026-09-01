import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/support/support_chat_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/app_page_header/app_page_header.dart';
import '/global_comp/chat_message_status_indicator/chat_message_status_indicator.dart';
import '/user/chat/chat_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSupportChatsWidget extends StatelessWidget {
  const AdminSupportChatsWidget({super.key});

  static String routeName = 'AdminSupportChats';
  static String routePath = '/adminSupportChats';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppPageHeader(
                title: 'Служба поддержки',
                showBack: true,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: isCurrentSupportAdmin
                    ? const _SupportChatsList()
                    : const _SupportAccessDenied(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportChatsList extends StatelessWidget {
  const _SupportChatsList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('context', isEqualTo: 'support')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Support chats failed to load: ${snapshot.error}');
          return const _SupportListState(
            icon: Icons.cloud_off_rounded,
            title: 'Не удалось загрузить обращения',
            subtitle: 'Проверьте соединение и откройте экран ещё раз.',
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: FlutterFlowTheme.of(context).primary,
            ),
          );
        }

        final chats = snapshot.data!.docs.toList()
          ..sort(
            (a, b) => _timestampMillis(
              b.data()['updated_time'],
            ).compareTo(_timestampMillis(a.data()['updated_time'])),
          );
        if (chats.isEmpty) {
          return const _SupportListState(
            icon: Icons.support_agent_rounded,
            title: 'Обращений пока нет',
            subtitle: 'Здесь появятся пользователи, написавшие в поддержку.',
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10.0),
          itemBuilder: (context, index) => _SupportUserTile(chat: chats[index]),
        );
      },
    );
  }
}

class _SupportUserTile extends StatelessWidget {
  const _SupportUserTile({required this.chat});

  final QueryDocumentSnapshot<Map<String, dynamic>> chat;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final data = chat.data();
    final name = (data['clientName'] as String? ?? '').trim();
    final phone = (data['clientPhone'] as String? ?? '').trim();
    final photo = (data['clientPhoto'] as String? ?? '').trim();
    final lastMessage = (data['last_message'] as String? ?? '').trim();
    final messageStatus = outgoingLastMessageStatus(data, currentUserReference);

    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: () => context.pushNamed(
          ChatWidget.routeName,
          queryParameters: {
            'chatId': serializeParam(chat.id, ParamType.String),
          }.withoutNulls,
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: theme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 52.0,
                height: 52.0,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  shape: BoxShape.circle,
                ),
                child: photo.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photo,
                        fit: BoxFit.cover,
                        memCacheWidth: 156,
                        memCacheHeight: 156,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.person_rounded),
                      )
                    : const Icon(Icons.person_rounded),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.isNotEmpty
                          ? name
                          : (phone.isNotEmpty ? phone : 'Пользователь'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        if (messageStatus != null)
                          ChatMessageStatusIndicator(status: messageStatus),
                        Expanded(
                          child: Text(
                            lastMessage.isNotEmpty
                                ? lastMessage
                                : 'Новое обращение',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: theme.secondaryText,
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(width: 4.0)),
                    ),
                    if (phone.isNotEmpty && name.isNotEmpty)
                      Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelSmall.override(
                          font: GoogleFonts.inter(),
                          color: theme.secondaryText,
                        ),
                      ),
                  ].divide(const SizedBox(height: 4.0)),
                ),
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: chat.reference
                    .collection('messages')
                    .where('read', isEqualTo: false)
                    .snapshots(),
                builder: (context, unreadSnapshot) {
                  final unread =
                      unreadSnapshot.data?.docs
                          .where(
                            (message) =>
                                message.data()['sender'] !=
                                currentUserReference,
                          )
                          .length ??
                      0;
                  if (unread == 0) {
                    return Icon(
                      Icons.chevron_right_rounded,
                      color: theme.secondaryText,
                    );
                  }
                  return Container(
                    constraints: const BoxConstraints(minWidth: 24.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      textAlign: TextAlign.center,
                      style: theme.labelSmall.override(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportListState extends StatelessWidget {
  const _SupportListState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.0, color: theme.primary),
            const SizedBox(height: 14.0),
            Text(title, textAlign: TextAlign.center, style: theme.titleMedium),
            const SizedBox(height: 6.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportAccessDenied extends StatelessWidget {
  const _SupportAccessDenied();

  @override
  Widget build(BuildContext context) => const _SupportListState(
    icon: Icons.lock_outline_rounded,
    title: 'Доступ запрещён',
    subtitle: 'Этот раздел доступен только службе поддержки.',
  );
}

int _timestampMillis(dynamic value) {
  if (value is Timestamp) return value.millisecondsSinceEpoch;
  if (value is DateTime) return value.millisecondsSinceEpoch;
  return 0;
}
