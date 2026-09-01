import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/chat/chat_profile_sync.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/app_page_header/app_page_header.dart';
import '/global_comp/chat_message_status_indicator/chat_message_status_indicator.dart';
import '/global_comp/menu/menu_widget.dart';
import '/user/chat/chat_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'master_chats_model.dart';
export 'master_chats_model.dart';

class MasterChatsWidget extends StatefulWidget {
  const MasterChatsWidget({super.key});

  static String routeName = 'MasterChats';
  static String routePath = '/masterChats';

  @override
  State<MasterChatsWidget> createState() => _MasterChatsWidgetState();
}

class _MasterChatsWidgetState extends State<MasterChatsWidget> {
  late MasterChatsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _selectionMode = false;
  Set<String> _selectedChatIds = <String>{};

  void _startSelection() {
    safeSetState(() => _selectionMode = true);
  }

  void _cancelSelection() {
    safeSetState(() {
      _selectionMode = false;
      _selectedChatIds = <String>{};
    });
  }

  void _toggleChat(String chatId) {
    safeSetState(() {
      final updated = Set<String>.from(_selectedChatIds);
      updated.contains(chatId) ? updated.remove(chatId) : updated.add(chatId);
      _selectedChatIds = updated;
    });
  }

  Future<void> _confirmHideSelectedChats() async {
    if (_selectedChatIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить выбранные чаты?'),
        content: const Text(
          'Чаты исчезнут из списка. Если в них появится новое сообщение, они восстановятся автоматически.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отменить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: FlutterFlowTheme.of(context).error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final chatId in _selectedChatIds) {
        batch.update(
          FirebaseFirestore.instance.collection('chats').doc(chatId),
          {'hiddenForMasterAt': FieldValue.serverTimestamp()},
        );
      }
      await batch.commit();
      if (mounted) _cancelSelection();
    } catch (error) {
      debugPrint('Master chats hide failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось скрыть выбранные чаты')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MasterChatsModel());
    syncCurrentUserChatProfile();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 120.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: 'Чаты',
                    padding: EdgeInsets.zero,
                    actions: [
                      if (_selectionMode) ...[
                        TextButton.icon(
                          onPressed: _selectedChatIds.isEmpty
                              ? null
                              : _confirmHideSelectedChats,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: Text(
                            _selectedChatIds.isEmpty
                                ? 'Удалить'
                                : 'Удалить (${_selectedChatIds.length})',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: FlutterFlowTheme.of(context).error,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Отменить выбор',
                          onPressed: _cancelSelection,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ] else
                        IconButton(
                          tooltip: 'Выбрать чаты',
                          onPressed: _startSelection,
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                    ],
                  ),
                  Expanded(
                    child: _ChatList(
                      roleField: 'master',
                      selectionMode: _selectionMode,
                      selectedChatIds: _selectedChatIds,
                      onToggleChat: _toggleChat,
                    ),
                  ),
                ].divide(SizedBox(height: 16.0)),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.menuModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuWidget(currentPage: Menu.masterChats),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatList extends StatefulWidget {
  const _ChatList({
    required this.roleField,
    required this.selectionMode,
    required this.selectedChatIds,
    required this.onToggleChat,
  });

  final String roleField;
  final bool selectionMode;
  final Set<String> selectedChatIds;
  final ValueChanged<String> onToggleChat;

  @override
  State<_ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<_ChatList> {
  Query<Map<String, dynamic>> _query(DocumentReference userRef) =>
      FirebaseFirestore.instance
          .collection('chats')
          .where(widget.roleField, isEqualTo: userRef);

  Future<void> _refresh() async {
    final userRef = currentUserReference;
    if (userRef == null) {
      return;
    }
    try {
      await _query(userRef).get(GetOptions(source: Source.server));
    } catch (error) {
      debugPrint('Master chat list refresh failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRef = currentUserReference;
    if (userRef == null) {
      return const _ChatListStatus(child: _EmptyChats());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _query(userRef).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Master chat list failed to load: ${snapshot.error}');
            return const _ChatListStatus(
              child: _EmptyChats(
                message:
                    'Не удалось загрузить чаты. Потяните вниз, чтобы повторить.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return _ChatListStatus(
              child: Center(
                child: SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            );
          }

          final chats =
              snapshot.data!.docs.where((chat) {
                final data = chat.data();
                final otherField = widget.roleField == 'client'
                    ? 'master'
                    : 'client';
                final otherUser = data[otherField] as DocumentReference?;
                final hiddenAt = data['hiddenForMasterAt'];
                final isHidden =
                    hiddenAt != null &&
                    _chatTimeMillis(data['updated_time']) <=
                        _chatTimeMillis(hiddenAt);
                return !(List<String>.from(
                      data['blockedByIds'] as List? ?? const [],
                    )).contains(currentUserUid) &&
                    !isHidden &&
                    (otherUser == null ||
                        !(currentUserDocument?.blockedUserIds ?? const [])
                            .contains(otherUser.id)) &&
                    data['context'] != 'support';
              }).toList()..sort((a, b) {
                final aTime = a.data()['updated_time'];
                final bTime = b.data()['updated_time'];
                final aMillis = _chatTimeMillis(aTime);
                final bMillis = _chatTimeMillis(bTime);
                return bMillis.compareTo(aMillis);
              });
          if (chats.isEmpty) {
            return const _ChatListStatus(child: _EmptyChats());
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
            itemCount: chats.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.0),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListTile(
                chat: chat,
                selectionMode: widget.selectionMode,
                selected: widget.selectedChatIds.contains(chat.id),
                onToggle: () => widget.onToggleChat(chat.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListStatus extends StatelessWidget {
  const _ChatListStatus({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: constraints.maxHeight, child: child)],
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.chat,
    required this.selectionMode,
    required this.selected,
    required this.onToggle,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> chat;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final data = chat.data();
    final currentRef = currentUserReference;
    final isClient = data['client'] == currentRef;
    final name = isClient
        ? (data['masterName'] as String? ?? '')
        : (data['clientName'] as String? ?? '');
    final photo = isClient
        ? (data['masterPhoto'] as String? ?? '')
        : (data['clientPhoto'] as String? ?? '');
    final lastMessage = data['last_message'] as String? ?? '';
    final lastMessageLabel = lastMessage.trim().isNotEmpty
        ? lastMessage.trim()
        : ((data['last_message_type'] as String?) == 'image'
              ? 'Фото'
              : 'Нет сообщений');
    final messageStatus = outgoingLastMessageStatus(data, currentRef);
    final updatedTimeLabel = _formatChatTimestamp(
      context,
      data['updated_time'],
    );

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (selectionMode) {
          onToggle();
          return;
        }
        context.pushNamed(
          ChatWidget.routeName,
          queryParameters: {
            'chatId': serializeParam(chat.id, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: FlutterFlowTheme.of(context).divider),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (selectionMode)
                Checkbox(
                  value: selected,
                  onChanged: (_) => onToggle(),
                  visualDensity: VisualDensity.compact,
                ),
              Container(
                width: 52.0,
                height: 52.0,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  shape: BoxShape.circle,
                ),
                child: photo.trim().isNotEmpty
                    ? CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 0),
                        fadeOutDuration: Duration(milliseconds: 0),
                        imageUrl: photo.trim(),
                        fit: BoxFit.cover,
                        memCacheWidth: 156,
                        memCacheHeight: 156,
                        errorWidget: (context, url, error) => Icon(
                          Icons.person_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 24.0,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 24.0,
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.trim().isNotEmpty ? name.trim() : 'Собеседник',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        if (messageStatus != null)
                          ChatMessageStatusIndicator(status: messageStatus),
                        Expanded(
                          child: Text(
                            lastMessageLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ].divide(const SizedBox(width: 4.0)),
                    ),
                    if (updatedTimeLabel.isNotEmpty)
                      Text(
                        updatedTimeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 11.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                  ].divide(SizedBox(height: 4.0)),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('chat', isEqualTo: chat.reference)
                    .where('user', isEqualTo: currentUserReference)
                    .where('read', isEqualTo: false)
                    .where('type', isEqualTo: 'chat_message')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox.shrink();
                  }
                  final count = snapshot.data!.docs.length;
                  return Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).error,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20.0,
                      minHeight: 20.0,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 22.0,
              ),
            ].divide(SizedBox(width: 12.0)),
          ),
        ),
      ),
    );
  }
}

int _chatTimeMillis(dynamic value) {
  if (value is Timestamp) {
    return value.millisecondsSinceEpoch;
  }
  if (value is DateTime) {
    return value.millisecondsSinceEpoch;
  }
  return 0;
}

String _formatChatTimestamp(BuildContext context, dynamic value) {
  final DateTime? date = value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : null;
  if (date == null) return '';
  return dateTimeFormat(
    'dd.MM.yyyy, HH:mm',
    date.toLocal(),
    locale: FFLocalizations.of(context).languageCode,
  );
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats({this.message = 'Чатов пока нет'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 40.0,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).titleMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ].divide(SizedBox(height: 12.0)),
      ),
    );
  }
}
