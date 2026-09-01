import 'dart:async';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/chat/chat_profile_sync.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/support/support_chat_service.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_model.dart';
export 'chat_model.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key, this.chatId});

  final String? chatId;

  static String routeName = 'Chat';
  static String routePath = '/chat';

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatModel _model;
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _syncClientPhone() async {
    final chatId = widget.chatId;
    final userRef = currentUserReference;
    if (chatId == null || userRef == null || currentPhoneNumber.isEmpty) {
      return;
    }

    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId);
      final snapshot = await chatRef.get();
      if (snapshot.data()?['client'] == userRef) {
        await chatRef.update({'clientPhone': currentPhoneNumber});
      }
    } catch (error) {
      debugPrint('Chat phone sync failed: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    unawaited(clearChatNotification(widget.chatId));
    _syncClientPhone();
    syncCurrentUserChatProfile(chatId: widget.chatId);

    final chatId = widget.chatId;
    final userRef = currentUserReference;
    if (chatId != null && userRef != null) {
      _notificationsSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .where(
            'chat',
            isEqualTo: FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId),
          )
          .where('user', isEqualTo: userRef)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isNotEmpty) {
                final batch = FirebaseFirestore.instance.batch();
                for (var doc in snapshot.docs) {
                  batch.update(doc.reference, {'read': true});
                }
                batch.commit().catchError((e) {
                  debugPrint('Error marking notifications as read: $e');
                });
              }
            },
            onError: (Object error) {
              debugPrint('Chat notification listener failed: $error');
            },
          );
    }
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
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
        child: Column(
          children: [
            _ChatHeader(chatId: widget.chatId),
            _ChatServiceContext(chatId: widget.chatId),
            Expanded(child: _MessageList(chatId: widget.chatId)),
            _MessageInput(model: _model, chatId: widget.chatId),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({this.chatId});

  final String? chatId;

  @override
  Widget build(BuildContext context) {
    if (chatId == null) {
      return _ChatHeaderContent(name: 'Чат', photo: '');
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final currentRef = currentUserReference;
        final isSupport = data?['context'] == 'support';
        final clientRef = data?['client'] as DocumentReference?;
        final masterRef = data?['master'] as DocumentReference?;
        final isClient = currentRef != null && clientRef == currentRef;
        final name = isClient
            ? (data?['masterName'] as String? ?? '')
            : (data?['clientName'] as String? ?? '');
        final photo = isClient
            ? (data?['masterPhoto'] as String? ?? '')
            : (data?['clientPhoto'] as String? ?? '');

        return _ChatHeaderContent(
          name: isSupport && isClient
              ? supportAccountName
              : (name.trim().isNotEmpty ? name.trim() : 'Собеседник'),
          photo: photo.trim(),
          chatRef: FirebaseFirestore.instance.collection('chats').doc(chatId),
          reportedUser: isClient ? masterRef : clientRef,
          isSupport: isSupport,
          showSupportIdentity: isSupport && isClient,
        );
      },
    );
  }
}

class _ChatHeaderContent extends StatelessWidget {
  const _ChatHeaderContent({
    required this.name,
    required this.photo,
    this.chatRef,
    this.reportedUser,
    this.isSupport = false,
    this.showSupportIdentity = false,
  });

  final String name;
  final String photo;
  final DocumentReference? chatRef;
  final DocumentReference? reportedUser;
  final bool isSupport;
  final bool showSupportIdentity;

  Future<void> _showReportDialog(BuildContext context) async {
    final reporter = currentUserReference;
    if (reporter == null || chatRef == null || reportedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось определить участника чата')),
      );
      return;
    }

    final detailsController = TextEditingController();
    String? selectedReason;
    final submitted = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        const reasons = [
          'Спам или реклама',
          'Оскорбления или угрозы',
          'Мошенничество',
          'Неподходящий контент',
        ];

        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(
                            context,
                          ).error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag_rounded,
                          color: FlutterFlowTheme.of(context).error,
                          size: 22.0,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Пожаловаться',
                          style: FlutterFlowTheme.of(context).titleMedium
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ].divide(SizedBox(width: 12.0)),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      16.0,
                      0.0,
                      0.0,
                    ),
                    child: Text(
                      'Выберите причину жалобы',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      12.0,
                      0.0,
                      0.0,
                    ),
                    child: Column(
                      children: reasons
                          .map(
                            (reason) => InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                setDialogState(() => selectedReason = reason);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0,
                                  12.0,
                                  12.0,
                                  12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: selectedReason == reason
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context).divider,
                                    width: selectedReason == reason ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selectedReason == reason
                                          ? Icons.radio_button_checked_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      color: selectedReason == reason
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                      size: 20.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 10.0)),
                                ),
                              ),
                            ),
                          )
                          .toList()
                          .divide(SizedBox(height: 8.0)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      12.0,
                      0.0,
                      0.0,
                    ),
                    child: TextFormField(
                      controller: detailsController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Другое',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium
                            .override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(
                          context,
                        ).secondaryBackground,
                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                          12.0,
                          12.0,
                          12.0,
                          12.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).divider,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      20.0,
                      0.0,
                      0.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                            },
                            text: 'Закрыть',
                            options: FFButtonOptions(
                              height: 48.0,
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context).titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).divider,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              final hasReason =
                                  selectedReason != null ||
                                  detailsController.text.trim().isNotEmpty;
                              if (!hasReason) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Выберите или укажите причину',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(dialogContext, 'report');
                            },
                            text: 'Отправить',
                            options: FFButtonOptions(
                              height: 48.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: FlutterFlowTheme.of(context).info,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(width: 10.0)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      10.0,
                      0.0,
                      0.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FFButtonWidget(
                        onPressed: () async {
                          final hasReason =
                              selectedReason != null ||
                              detailsController.text.trim().isNotEmpty;
                          if (!hasReason) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Выберите или укажите причину'),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(dialogContext, 'block');
                        },
                        text: 'Заблокировать и пожаловаться',
                        options: FFButtonOptions(
                          height: 48.0,
                          color: FlutterFlowTheme.of(context).error,
                          textStyle: FlutterFlowTheme.of(context).titleSmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w700,
                              ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final details = normalizeUserText(detailsController.text);
    detailsController.dispose();
    if (submitted == null) {
      return;
    }

    try {
      final reportRef = FirebaseFirestore.instance.collection('reports').doc();
      final batch = FirebaseFirestore.instance.batch();
      batch.set(reportRef, {
        'reporter': reporter,
        'reportedUser': reportedUser,
        'chat': chatRef,
        'reason': selectedReason ?? 'Другое',
        'details': details,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (submitted == 'block') {
        batch.update(reporter, {
          'blockedUserIds': FieldValue.arrayUnion([reportedUser!.id]),
        });
        batch.update(chatRef!, {
          'blockedByIds': FieldValue.arrayUnion([reporter.id]),
        });
      }
      await batch.commit();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              submitted == 'block'
                  ? 'Пользователь заблокирован, жалоба отправлена'
                  : 'Жалоба отправлена на рассмотрение',
            ),
          ),
        );
        if (submitted == 'block') {
          context.safePop();
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Не удалось отправить жалобу')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        border: Border(
          bottom: BorderSide(
            color: FlutterFlowTheme.of(context).divider,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 16.0, 12.0),
        child: Row(
          children: [
            FlutterFlowIconButton(
              borderRadius: 12.0,
              buttonSize: 44.0,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 20.0,
              ),
              onPressed: () async {
                context.safePop();
              },
            ),
            Container(
              width: 44.0,
              height: 44.0,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.circle,
              ),
              child: showSupportIdentity
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipOval(
                        child: Image.asset(supportLogoAsset, fit: BoxFit.cover),
                      ),
                    )
                  : photo.isNotEmpty
                  ? CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 0),
                      fadeOutDuration: Duration(milliseconds: 0),
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      memCacheWidth: 132,
                      memCacheHeight: 132,
                      errorWidget: (context, url, error) => Icon(
                        Icons.person_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 22.0,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 22.0,
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!isSupport)
              FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 44.0,
                icon: Icon(
                  Icons.flag_outlined,
                  color: FlutterFlowTheme.of(context).error,
                  size: 23.0,
                ),
                onPressed: () async {
                  await _showReportDialog(context);
                },
              ),
            if (chatRef != null && !isSupport)
              FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 44.0,
                icon: Icon(
                  Icons.history_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
                onPressed: () async {
                  context.pushNamed(
                    VisitHistoryWidget.routeName,
                    queryParameters: {
                      'chatId': serializeParam(chatRef!.id, ParamType.String),
                    }.withoutNulls,
                  );
                },
              ),
          ].divide(SizedBox(width: 10.0)),
        ),
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  const _MessageInput({required this.model, this.chatId});

  final ChatModel model;
  final String? chatId;

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  ChatModel get model => widget.model;
  String? get chatId => widget.chatId;
  bool _isSendingText = false;
  bool _isSendingImage = false;
  bool get _isSending => _isSendingText || _isSendingImage;

  static const _prohibitedFragments = <String>{
    'порно',
    'порнограф',
    'нацист',
    'убью',
    'убить тебя',
    'суицид',
    'наркотик',
  };

  bool _containsProhibitedContent(String text) {
    final normalized = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return _prohibitedFragments.any(normalized.contains);
  }

  Future<void> _sendTextMessage(BuildContext context) async {
    if (_isSending) {
      return;
    }
    final text = normalizeUserText(model.textController?.text ?? '');
    if (text.isEmpty || chatId == null || currentUserReference == null) {
      return;
    }
    if (_containsProhibitedContent(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Сообщение содержит недопустимый контент и не может быть отправлено.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSendingText = true);
    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId);
      final messageRef = chatRef.collection('messages').doc();
      final batch = FirebaseFirestore.instance.batch();
      batch.set(messageRef, {
        'sender': currentUserReference,
        'type': 'text',
        'text': text,
        'created_time': FieldValue.serverTimestamp(),
        'read': false,
        'delivered': false,
      });
      batch.update(chatRef, {
        'last_message': text,
        'last_message_type': 'text',
        'last_message_id': messageRef.id,
        'last_message_sender': currentUserReference,
        'last_message_status': 'sent',
        'last_message_delivered': false,
        'last_message_read': false,
        'updated_time': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      model.textController?.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Не удалось отправить сообщение. Попробуйте ещё раз.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingText = false);
      }
    }
  }

  Future<void> _selectAndSendImage(MediaSource source) async {
    if (_isSending || chatId == null || currentUserReference == null) {
      return;
    }

    final selectedMedia = await selectMedia(
      storageFolderPath: 'users/$currentUserUid/chat_uploads',
      maxWidth: 1600.0,
      maxHeight: 1600.0,
      imageQuality: 70,
      mediaSource: source,
      multiImage: false,
      includeDimensions: true,
    );
    if (!mounted) return;
    if (selectedMedia == null ||
        selectedMedia.isEmpty ||
        !validateFileFormat(selectedMedia.first.storagePath, context)) {
      return;
    }

    setState(() => _isSendingImage = true);
    try {
      final file = selectedMedia.first;
      final imageUrl = await uploadData(file.storagePath, file.bytes);
      if (imageUrl == null || imageUrl.isEmpty) {
        throw StateError('Image upload returned an empty URL');
      }

      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId);
      final messageRef = chatRef.collection('messages').doc();
      final batch = FirebaseFirestore.instance.batch();
      batch.set(messageRef, {
        'sender': currentUserReference,
        'type': 'image',
        'image': imageUrl,
        'width': file.dimensions?.width,
        'height': file.dimensions?.height,
        'created_time': FieldValue.serverTimestamp(),
        'read': false,
        'delivered': false,
      });
      batch.update(chatRef, {
        'last_message': 'Фото',
        'last_message_type': 'image',
        'last_message_id': messageRef.id,
        'last_message_sender': currentUserReference,
        'last_message_status': 'sent',
        'last_message_delivered': false,
        'last_message_read': false,
        'updated_time': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Не удалось отправить изображение. Попробуйте ещё раз.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingImage = false);
      }
    }
  }

  Future<void> _showMediaSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          top: false,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Container(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MediaAction(
                      icon: Icons.camera_alt_rounded,
                      label: 'Камера',
                      onTap: () async {
                        Navigator.pop(bottomSheetContext);
                        await _selectAndSendImage(MediaSource.camera);
                      },
                    ),
                    _MediaAction(
                      icon: Icons.image_rounded,
                      label: 'Галерея',
                      onTap: () async {
                        Navigator.pop(bottomSheetContext);
                        await _selectAndSendImage(MediaSource.photoGallery);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        border: Border(
          top: BorderSide(
            color: FlutterFlowTheme.of(context).divider,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 16.0),
        child: Row(
          children: [
            FlutterFlowIconButton(
              borderRadius: 12.0,
              buttonSize: 48.0,
              icon: _isSendingImage
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    )
                  : Icon(
                      Icons.photo_library_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 22.0,
                    ),
              onPressed: _isSending
                  ? null
                  : () async {
                      await _showMediaSheet(context);
                    },
            ),
            Expanded(
              child: TextFormField(
                controller: model.textController,
                textCapitalization: TextCapitalization.sentences,
                focusNode: model.textFieldFocusNode,
                autofocus: false,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: 'Сообщение',
                  hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).hint,
                    letterSpacing: 0.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).divider,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  contentPadding: EdgeInsetsDirectional.fromSTEB(
                    14.0,
                    12.0,
                    14.0,
                    12.0,
                  ),
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
                minLines: 1,
                maxLines: 3,
                cursorColor: FlutterFlowTheme.of(context).primary,
              ),
            ),
            FlutterFlowIconButton(
              borderRadius: 12.0,
              buttonSize: 48.0,
              fillColor: FlutterFlowTheme.of(context).primary,
              icon: _isSendingText
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      size: 22.0,
                    ),
              onPressed: _isSending ? null : () => _sendTextMessage(context),
            ),
          ].divide(SizedBox(width: 10.0)),
        ),
      ),
    );
  }
}

class _ChatServiceContext extends StatelessWidget {
  const _ChatServiceContext({this.chatId});

  final String? chatId;

  @override
  Widget build(BuildContext context) {
    if (chatId == null) {
      return SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .snapshots(),
      builder: (context, chatSnapshot) {
        final chatData = chatSnapshot.data?.data();
        final serviceRef = chatData?['service'] as DocumentReference?;
        if (serviceRef == null) {
          return SizedBox.shrink();
        }

        final masterRef = chatData?['master'] as DocumentReference?;
        final clientRef = chatData?['client'] as DocumentReference?;
        final isMaster =
            currentUserReference != null && masterRef == currentUserReference;

        if (masterRef == null || clientRef == null) {
          return SizedBox.shrink();
        }

        return StreamBuilder<List<RecordsRecord>>(
          stream: queryRecordsRecord(
            queryBuilder: (recordsRecord) => recordsRecord
                .where('master', isEqualTo: masterRef)
                .where('client', isEqualTo: clientRef),
          ),
          builder: (context, pairRecordsSnapshot) {
            final pairRecords = pairRecordsSnapshot.data ?? const [];
            final activePairRecords = pairRecords.where((record) {
              final recordDate = record.date;
              final isActiveStatus =
                  record.status == RecordStatus.confirmed ||
                  record.status == RecordStatus.newRec;
              return recordDate != null &&
                  isActiveStatus &&
                  recordDate.isAfter(
                    getCurrentTimestamp.subtract(Duration(minutes: 1)),
                  );
            }).toList()..sort((a, b) => a.date!.compareTo(b.date!));
            final activePairRecord = activePairRecords.firstOrNull;

            // An active appointment takes priority. Otherwise keep the service
            // from which the user most recently opened this shared chat.
            final resolvedServiceRef = activePairRecord?.service ?? serviceRef;

            return StreamBuilder<ServiceRecord>(
              stream: ServiceRecord.getDocument(resolvedServiceRef),
              builder: (context, serviceSnapshot) {
                if (!serviceSnapshot.hasData) {
                  return SizedBox.shrink();
                }

                final service = serviceSnapshot.data!;
                final imageUrl = service.image.firstOrNull ?? '';
                final priceLabel = service.price > 0
                    ? formatPrice(service.price)
                    : 'Цена не указана';

                Future<void> openService() async {
                  context.pushNamed(
                    ServiceDetailWidget.routeName,
                    queryParameters: {
                      'serviceDoc': serializeParam(service, ParamType.Document),
                    }.withoutNulls,
                    extra: <String, dynamic>{'serviceDoc': service},
                  );
                }

                Future<void> showCreateRecordDialog({
                  RecordsRecord? existingRecord,
                }) async {
                  final currentMasterRef = currentUserReference;
                  if (currentMasterRef == null) {
                    return;
                  }

                  late final List<ServiceRecord> ownServices;
                  try {
                    ownServices = await queryServiceRecordOnce(
                      queryBuilder: (serviceRecord) => serviceRecord.where(
                        'owner',
                        isEqualTo: currentMasterRef,
                      ),
                    );
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Не удалось загрузить список услуг'),
                        ),
                      );
                    }
                    return;
                  }
                  if (!context.mounted) {
                    return;
                  }
                  final initialServiceRef =
                      existingRecord?.service ?? service.reference;
                  final selectableServices =
                      ownServices
                          .where(
                            (candidate) =>
                                candidate.status == ServiceStatus.show ||
                                candidate.reference == initialServiceRef,
                          )
                          .toList()
                        ..sort((a, b) {
                          if (a.reference == initialServiceRef) return -1;
                          if (b.reference == initialServiceRef) return 1;
                          return a.title.toLowerCase().compareTo(
                            b.title.toLowerCase(),
                          );
                        });
                  if (!selectableServices.any(
                    (candidate) => candidate.reference == initialServiceRef,
                  )) {
                    selectableServices.insert(0, service);
                  }

                  DateTime? selectedDate = existingRecord?.date;
                  TimeOfDay? selectedTime = existingRecord?.date != null
                      ? TimeOfDay.fromDateTime(existingRecord!.date!)
                      : null;
                  DocumentReference selectedServiceRef = initialServiceRef;
                  bool isSubmitting = false;

                  await showDialog(
                    context: context,
                    builder: (dialogContext) => StatefulBuilder(
                      builder: (dialogContext, setDialogState) {
                        final selectedRecordDate =
                            selectedDate != null && selectedTime != null
                            ? DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                selectedTime!.hour,
                                selectedTime!.minute,
                              )
                            : null;
                        final selectedService = selectableServices
                            .where(
                              (candidate) =>
                                  candidate.reference == selectedServiceRef,
                            )
                            .firstOrNull;
                        final canCreateRecord =
                            (selectedRecordDate?.isAfter(getCurrentTimestamp) ??
                                false) &&
                            selectedService != null &&
                            !isSubmitting;

                        return Dialog(
                          backgroundColor: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          surfaceTintColor: Colors.transparent,
                          insetPadding: EdgeInsets.symmetric(horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  existingRecord == null
                                      ? 'Создать запись'
                                      : 'Изменить запись',
                                  style: FlutterFlowTheme.of(context).titleLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: dialogContext,
                                      initialDate:
                                          selectedDate ?? getCurrentTimestamp,
                                      firstDate: getCurrentTimestamp,
                                      lastDate: getCurrentTimestamp.add(
                                        Duration(days: 365),
                                      ),
                                      builder: (context, child) {
                                        return wrapInMaterialDatePickerTheme(
                                          context,
                                          child!,
                                          headerBackgroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          headerForegroundColor:
                                              FlutterFlowTheme.of(context).info,
                                          headerTextStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).headlineLarge.override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                fontSize: 32.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          pickerBackgroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).secondaryBackground,
                                          pickerForegroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                          selectedDateTimeBackgroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          selectedDateTimeForegroundColor:
                                              FlutterFlowTheme.of(context).info,
                                          actionButtonForegroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                          iconSize: 24.0,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      setDialogState(() {
                                        selectedDate = pickedDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).divider,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                            size: 20.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              selectedDate == null
                                                  ? 'Дата'
                                                  : dateTimeFormat(
                                                      'd MMMM y',
                                                      selectedDate,
                                                      locale:
                                                          FFLocalizations.of(
                                                            context,
                                                          ).languageCode,
                                                    ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodyMedium.override(
                                                    font: GoogleFonts.inter(),
                                                    color: selectedDate == null
                                                        ? FlutterFlowTheme.of(
                                                            context,
                                                          ).secondaryText
                                                        : FlutterFlowTheme.of(
                                                            context,
                                                          ).primaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 10.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField<DocumentReference>(
                                  key: ValueKey(selectedServiceRef.path),
                                  initialValue: selectedServiceRef,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Услуга',
                                    prefixIcon: Icon(
                                      Icons.design_services_rounded,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 20.0,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).divider,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primary,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  items: selectableServices
                                      .map(
                                        (candidate) => DropdownMenuItem(
                                          value: candidate.reference,
                                          child: Text(
                                            candidate.title.isNotEmpty
                                                ? candidate.title
                                                : 'Услуга без названия',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: isSubmitting
                                      ? null
                                      : (newServiceRef) {
                                          if (newServiceRef != null) {
                                            setDialogState(() {
                                              selectedServiceRef =
                                                  newServiceRef;
                                            });
                                          }
                                        },
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    final pickedTime = await showTimePicker(
                                      context: dialogContext,
                                      initialTime:
                                          selectedTime ??
                                          TimeOfDay.fromDateTime(
                                            getCurrentTimestamp,
                                          ),
                                      builder: (context, child) {
                                        return wrapInMaterialTimePickerTheme(
                                          context,
                                          child!,
                                          headerBackgroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          headerForegroundColor:
                                              FlutterFlowTheme.of(context).info,
                                          headerTextStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).headlineLarge.override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                fontSize: 32.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          pickerBackgroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).secondaryBackground,
                                          pickerForegroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                          selectedDateTimeBackgroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          selectedDateTimeForegroundColor:
                                              FlutterFlowTheme.of(context).info,
                                          actionButtonForegroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                          iconSize: 24.0,
                                        );
                                      },
                                    );
                                    if (pickedTime != null) {
                                      final date = selectedDate;
                                      if (date != null) {
                                        final pickedDateTime = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                        if (!pickedDateTime.isAfter(
                                          getCurrentTimestamp,
                                        )) {
                                          if (dialogContext.mounted) {
                                            ScaffoldMessenger.of(
                                              dialogContext,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Выберите время позже текущего',
                                                ),
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                      }
                                      setDialogState(() {
                                        selectedTime = pickedTime;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).divider,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.schedule_rounded,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                            size: 20.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              selectedTime == null
                                                  ? 'Время'
                                                  : selectedTime!.format(
                                                      context,
                                                    ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodyMedium.override(
                                                    font: GoogleFonts.inter(),
                                                    color: selectedTime == null
                                                        ? FlutterFlowTheme.of(
                                                            context,
                                                          ).secondaryText
                                                        : FlutterFlowTheme.of(
                                                            context,
                                                          ).primaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 10.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: canCreateRecord
                                      ? () async {
                                          if (isSubmitting) return;
                                          setDialogState(() {
                                            isSubmitting = true;
                                          });
                                          try {
                                            if (selectedRecordDate == null ||
                                                !selectedRecordDate.isAfter(
                                                  getCurrentTimestamp,
                                                )) {
                                              ScaffoldMessenger.of(
                                                dialogContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Дата и время должны быть в будущем',
                                                  ),
                                                ),
                                              );
                                              setDialogState(() {
                                                isSubmitting = false;
                                              });
                                              return;
                                            }
                                            final clientRef =
                                                chatData?['client']
                                                    as DocumentReference?;
                                            if (clientRef == null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Не удалось создать запись',
                                                  ),
                                                ),
                                              );
                                              setDialogState(() {
                                                isSubmitting = false;
                                              });
                                              return;
                                            }

                                            final recordDate = DateTime(
                                              selectedDate!.year,
                                              selectedDate!.month,
                                              selectedDate!.day,
                                              selectedTime!.hour,
                                              selectedTime!.minute,
                                            );
                                            final chatRef = FirebaseFirestore
                                                .instance
                                                .collection('chats')
                                                .doc(chatId);
                                            final serviceTitle =
                                                selectedService.title.isNotEmpty
                                                ? selectedService.title
                                                : 'услугу';
                                            final selectedPriceLabel =
                                                selectedService.price > 0
                                                ? formatPrice(
                                                    selectedService.price,
                                                  )
                                                : 'Цена не указана';
                                            final recordDateLabel =
                                                dateTimeFormat(
                                                  'd MMMM y, HH:mm',
                                                  recordDate,
                                                  locale: FFLocalizations.of(
                                                    context,
                                                  ).languageCode,
                                                );
                                            final messageText =
                                                existingRecord == null
                                                ? 'Создана запись на $serviceTitle, $selectedPriceLabel, $recordDateLabel'
                                                : 'Изменена запись на $serviceTitle, $selectedPriceLabel, $recordDateLabel';

                                            final recordRef =
                                                existingRecord == null
                                                ? await RecordsRecord.collection.add(
                                                    createRecordsRecordData(
                                                      master: currentMasterRef,
                                                      client: clientRef,
                                                      service: selectedService
                                                          .reference,
                                                      date: recordDate,
                                                      status: RecordStatus
                                                          .confirmed,
                                                      clientName:
                                                          chatData?['clientName']
                                                              as String?,
                                                      clientPhoto:
                                                          chatData?['clientPhoto']
                                                              as String?,
                                                      clientPhone:
                                                          chatData?['clientPhone']
                                                              as String?,
                                                    ),
                                                  )
                                                : existingRecord.reference;

                                            if (existingRecord != null) {
                                              await recordRef.update(
                                                createRecordsRecordData(
                                                  service:
                                                      selectedService.reference,
                                                  date: recordDate,
                                                  status:
                                                      RecordStatus.confirmed,
                                                ),
                                              );
                                            }

                                            final messageRef = chatRef
                                                .collection('messages')
                                                .doc();
                                            final messageBatch =
                                                FirebaseFirestore.instance
                                                    .batch();
                                            messageBatch.set(messageRef, {
                                              ...mapToFirestore(
                                                {
                                                  'sender': currentMasterRef,
                                                  'type': 'text',
                                                  'text': messageText,
                                                  'record': recordRef,
                                                  'created_time':
                                                      FieldValue.serverTimestamp(),
                                                  'read': false,
                                                  'delivered': false,
                                                }.withoutNulls,
                                              ),
                                            });

                                            messageBatch.update(
                                              chatRef,
                                              mapToFirestore({
                                                'last_message': messageText,
                                                'last_message_type': 'text',
                                                'last_message_id':
                                                    messageRef.id,
                                                'last_message_sender':
                                                    currentMasterRef,
                                                'last_message_status': 'sent',
                                                'last_message_delivered': false,
                                                'last_message_read': false,
                                                'service':
                                                    selectedService.reference,
                                                'updated_time':
                                                    FieldValue.serverTimestamp(),
                                              }),
                                            );
                                            await messageBatch.commit();

                                            await FirebaseFirestore.instance
                                                .collection('notifications')
                                                .add(
                                                  mapToFirestore({
                                                    'user': clientRef,
                                                    'chat': chatRef,
                                                    'record': recordRef,
                                                    'title':
                                                        existingRecord == null
                                                        ? 'Создана запись'
                                                        : 'Дата записи изменена',
                                                    'body': messageText,
                                                    'type':
                                                        existingRecord == null
                                                        ? 'record_created'
                                                        : 'record_date_changed',
                                                    'read': false,
                                                    'created_time':
                                                        FieldValue.serverTimestamp(),
                                                  }),
                                                );

                                            Navigator.pop(dialogContext);
                                          } catch (e) {
                                            print('Error creating record: $e');
                                            ScaffoldMessenger.of(
                                              dialogContext,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Ошибка создания записи: $e',
                                                ),
                                              ),
                                            );
                                            setDialogState(() {
                                              isSubmitting = false;
                                            });
                                          }
                                        }
                                      : null,
                                  child: Container(
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      color: canCreateRecord
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(
                                              context,
                                            ).alternate,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      'Подтвердить',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 14.0)),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border(
                      bottom: BorderSide(
                        color: FlutterFlowTheme.of(context).divider,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.0,
                      10.0,
                      16.0,
                      10.0,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: openService,
                          child: Container(
                            width: 52.0,
                            height: 52.0,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    fadeInDuration: Duration(milliseconds: 0),
                                    fadeOutDuration: Duration(milliseconds: 0),
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, progress) => Center(
                                          child: SizedBox(
                                            width: 18.0,
                                            height: 18.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                            ),
                                          ),
                                        ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.image_not_supported_rounded,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 22.0,
                                    ),
                                  )
                                : Icon(
                                    Icons.image_not_supported_rounded,
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).secondaryText,
                                    size: 22.0,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: openService,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title.isNotEmpty
                                      ? service.title
                                      : 'Услуга',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context).bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                Text(
                                  priceLabel,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context).bodySmall
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                          ),
                        ),
                        StreamBuilder<List<RecordsRecord>>(
                          stream: queryRecordsRecord(
                            queryBuilder: (recordsRecord) => recordsRecord
                                .where('master', isEqualTo: masterRef)
                                .where('client', isEqualTo: clientRef)
                                .where(
                                  'service',
                                  isEqualTo: resolvedServiceRef,
                                ),
                          ),
                          builder: (context, recordsSnapshot) {
                            final activeRecords =
                                (recordsSnapshot.data ?? []).where((record) {
                                  final recordDate = record.date;
                                  final isActiveStatus =
                                      record.status == RecordStatus.confirmed ||
                                      record.status == RecordStatus.newRec;
                                  return recordDate != null &&
                                      isActiveStatus &&
                                      recordDate.isAfter(
                                        getCurrentTimestamp.subtract(
                                          Duration(minutes: 1),
                                        ),
                                      );
                                }).toList()..sort(
                                  (a, b) => a.date!.compareTo(b.date!),
                                );
                            final activeRecord = activeRecords.firstOrNull;

                            if (activeRecord != null) {
                              final recordText = isMaster
                                  ? 'Этот клиент записан на ${dateTimeFormat('d MMMM, HH:mm', activeRecord.date, locale: FFLocalizations.of(context).languageCode)}'
                                  : 'Вы записаны на ${dateTimeFormat('d MMMM, HH:mm', activeRecord.date, locale: FFLocalizations.of(context).languageCode)}';

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 132.0,
                                    ),
                                    child: Text(
                                      recordText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  if (isMaster)
                                    FlutterFlowIconButton(
                                      borderRadius: 9.0,
                                      buttonSize: 34.0,
                                      fillColor: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                      borderColor: FlutterFlowTheme.of(
                                        context,
                                      ).divider,
                                      borderWidth: 1.0,
                                      icon: Icon(
                                        Icons.edit_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 18.0,
                                      ),
                                      onPressed: () async {
                                        await showCreateRecordDialog(
                                          existingRecord: activeRecord,
                                        );
                                      },
                                    ),
                                ].divide(SizedBox(width: 8.0)),
                              );
                            }

                            if (!isMaster) {
                              return SizedBox.shrink();
                            }

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: showCreateRecordDialog,
                                  child: Container(
                                    width: 86.0,
                                    height: 34.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).primary,
                                      borderRadius: BorderRadius.circular(9.0),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      'Записать',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 9.0,
                                  buttonSize: 34.0,
                                  fillColor: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                  borderColor: FlutterFlowTheme.of(
                                    context,
                                  ).divider,
                                  borderWidth: 1.0,
                                  icon: Icon(
                                    Icons.help_outline_rounded,
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    size: 20.0,
                                  ),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        backgroundColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        surfaceTintColor: Colors.transparent,
                                        content: Text(
                                          'Если вы договорились о времени можете зафиксировать его в приложении. Мы пришлем напоминание и вам и клиенту о записи',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).primary,
                                            ),
                                            child: Text(
                                              'Понятно',
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodyMedium.override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ].divide(SizedBox(width: 10.0)),
                            );
                          },
                        ),
                      ].divide(SizedBox(width: 10.0)),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

final Set<String> _messageReadSyncsInFlight = <String>{};

Future<void> _markIncomingMessagesAsRead(
  String chatId,
  List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
) async {
  final userRef = currentUserReference;
  if (userRef == null || _messageReadSyncsInFlight.contains(chatId)) {
    return;
  }

  final unreadMessages = messages
      .where((message) {
        final data = message.data();
        return data['sender'] != userRef && data['read'] != true;
      })
      .take(450)
      .toList();
  if (unreadMessages.isEmpty) {
    return;
  }

  _messageReadSyncsInFlight.add(chatId);
  try {
    final batch = FirebaseFirestore.instance.batch();
    for (final message in unreadMessages) {
      batch.update(message.reference, {
        'read': true,
        'read_time': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    final latestIncoming = messages.firstOrNull;
    if (latestIncoming != null &&
        unreadMessages.any((message) => message.id == latestIncoming.id)) {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final chat = await transaction.get(chatRef);
        if (chat.data()?['last_message_id'] != latestIncoming.id) return;
        transaction.update(chatRef, {
          'last_message_status': 'read',
          'last_message_delivered': true,
          'last_message_read': true,
        });
      });
    }
  } catch (error) {
    debugPrint('Failed to mark chat messages as read: $error');
  } finally {
    _messageReadSyncsInFlight.remove(chatId);
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({this.chatId});

  final String? chatId;

  @override
  Widget build(BuildContext context) {
    if (chatId == null) {
      return _ChatLoadError(
        message: 'Не удалось открыть чат: отсутствует идентификатор.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('created_time', descending: true)
          .snapshots(includeMetadataChanges: true),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Chat messages failed to load: ${snapshot.error}');
          return const _ChatLoadError(
            message:
                'Не удалось загрузить сообщения. Проверьте интернет и откройте чат ещё раз.',
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
          );
        }

        final messages = snapshot.data!.docs;
        if (messages.isEmpty) {
          return _EmptyMessages();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_markIncomingMessagesAsRead(chatId!, messages));
        });

        return ListView.separated(
          reverse: true,
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 20.0),
          itemCount: messages.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.0),
          itemBuilder: (context, index) {
            final data = messages[index].data();
            final sender = data['sender'] as DocumentReference?;
            final isMine =
                currentUserReference != null && sender == currentUserReference;
            final sentAt = _messageDateTime(data['created_time']);
            final olderSentAt = index + 1 < messages.length
                ? _messageDateTime(messages[index + 1].data()['created_time'])
                : null;
            final showDateDivider =
                sentAt != null &&
                (olderSentAt == null ||
                    !_isSameMessageDay(sentAt, olderSentAt));
            final bubble = _MessageBubble(
              data: data,
              isMine: isMine,
              sent: !messages[index].metadata.hasPendingWrites,
              delivered: data['delivered'] == true,
              read: data['read'] == true,
            );
            if (!showDateDivider) return bubble;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MessageDateDivider(date: sentAt),
                bubble,
              ].divide(SizedBox(height: 8.0)),
            );
          },
        );
      },
    );
  }
}

class _ChatLoadError extends StatelessWidget {
  const _ChatLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: FlutterFlowTheme.of(context).error,
              size: 40.0,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Сообщений пока нет',
        textAlign: TextAlign.center,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(),
          color: FlutterFlowTheme.of(context).secondaryText,
          letterSpacing: 0.0,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.data,
    required this.isMine,
    required this.sent,
    required this.delivered,
    required this.read,
  });

  final Map<String, dynamic> data;
  final bool isMine;
  final bool sent;
  final bool delivered;
  final bool read;

  @override
  Widget build(BuildContext context) {
    final type = data['type'] as String? ?? 'text';
    final text = data['text'] as String? ?? '';
    final image = data['image'] as String? ?? '';
    final sentAtLabel = _formatMessageTimestamp(context, data['created_time']);

    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isMine
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(isMine ? 16.0 : 4.0),
              bottomRight: Radius.circular(isMine ? 4.0 : 16.0),
            ),
            border: isMine
                ? null
                : Border.all(color: FlutterFlowTheme.of(context).divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (type == 'image' && image.isNotEmpty)
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: FlutterFlowExpandedImageView(
                          image: CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 0),
                            fadeOutDuration: Duration(milliseconds: 0),
                            imageUrl: image,
                            fit: BoxFit.contain,
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                    value: progress.progress,
                                  ),
                                ),
                          ),
                          allowRotation: false,
                          tag: image,
                          useHeroAnimation: true,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: image,
                    transitionOnUserGestures: true,
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 0),
                      fadeOutDuration: Duration(milliseconds: 0),
                      imageUrl: image,
                      fit: BoxFit.cover,
                      width: 220.0,
                      height: 220.0,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Container(
                            width: 220.0,
                            height: 220.0,
                            alignment: AlignmentDirectional(0.0, 0.0),
                            color: isMine
                                ? FlutterFlowTheme.of(
                                    context,
                                  ).primary.withOpacity(0.18)
                                : FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                            child: SizedBox(
                              width: 28.0,
                              height: 28.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: isMine
                                    ? Colors.white
                                    : FlutterFlowTheme.of(context).primary,
                                value: progress.progress,
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) => Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: isMine
                              ? Colors.white
                              : FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    14.0,
                    10.0,
                    14.0,
                    10.0,
                  ),
                  child: Text(
                    text,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: isMine
                          ? Colors.white
                          : FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      lineHeight: 1.35,
                    ),
                  ),
                ),
              if (sentAtLabel.isNotEmpty || isMine)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 8.0, 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sentAtLabel.isNotEmpty)
                        Text(
                          sentAtLabel,
                          style: FlutterFlowTheme.of(context).labelSmall
                              .override(
                                font: GoogleFonts.inter(),
                                color: isMine
                                    ? Colors.white.withValues(alpha: 0.78)
                                    : FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                fontSize: 10.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      if (isMine)
                        Icon(
                          read
                              ? Icons.done_all_rounded
                              : delivered
                              ? Icons.done_all_rounded
                              : sent
                              ? Icons.done_rounded
                              : Icons.schedule_rounded,
                          color: Colors.white.withValues(
                            alpha: read ? 1.0 : 0.78,
                          ),
                          size: 16.0,
                        ),
                    ].divide(SizedBox(width: 4.0)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatMessageTimestamp(BuildContext context, dynamic value) {
  final date = _messageDateTime(value);
  if (date == null) return '';
  return dateTimeFormat(
    'HH:mm',
    date,
    locale: FFLocalizations.of(context).languageCode,
  );
}

DateTime? _messageDateTime(dynamic value) {
  final DateTime? date = value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : null;
  return date?.toLocal();
}

bool _isSameMessageDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _formatMessageDate(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(date.year, date.month, date.day);
  final difference = today.difference(messageDay).inDays;

  if (difference == 0) return 'Сегодня';
  if (difference == 1) return 'Вчера';
  return dateTimeFormat(
    date.year == now.year ? 'd MMMM' : 'd MMMM yyyy',
    date,
    locale: FFLocalizations.of(context).languageCode,
  );
}

class _MessageDateDivider extends StatelessWidget {
  const _MessageDateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: FlutterFlowTheme.of(context).divider),
        ),
        child: Text(
          _formatMessageDate(context, date),
          style: FlutterFlowTheme.of(context).labelSmall.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
            color: FlutterFlowTheme.of(context).secondaryText,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MediaAction extends StatelessWidget {
  const _MediaAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: FlutterFlowTheme.of(context).primary),
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 42.0,
            ),
          ),
          Text(
            label,
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
