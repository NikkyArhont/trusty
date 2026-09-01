import '/flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ChatMessageDeliveryStatus { sent, delivered, read }

ChatMessageDeliveryStatus resolveChatMessageDeliveryStatus({
  required bool delivered,
  required bool read,
}) {
  if (read) return ChatMessageDeliveryStatus.read;
  if (delivered) return ChatMessageDeliveryStatus.delivered;
  return ChatMessageDeliveryStatus.sent;
}

ChatMessageDeliveryStatus? outgoingLastMessageStatus(
  Map<String, dynamic> chat,
  DocumentReference? currentUser,
) {
  if (currentUser == null || chat['last_message_sender'] != currentUser) {
    return null;
  }
  return resolveChatMessageDeliveryStatus(
    read:
        chat['last_message_read'] == true ||
        chat['last_message_status'] == 'read',
    delivered:
        chat['last_message_delivered'] == true ||
        chat['last_message_status'] == 'delivered',
  );
}

class ChatMessageStatusIndicator extends StatelessWidget {
  const ChatMessageStatusIndicator({
    super.key,
    required this.status,
    this.size = 16.0,
  });

  final ChatMessageDeliveryStatus? status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final value = status;
    if (value == null) return const SizedBox.shrink();

    final read = value == ChatMessageDeliveryStatus.read;
    final delivered = value == ChatMessageDeliveryStatus.delivered;
    final label = switch (value) {
      ChatMessageDeliveryStatus.sent => 'Отправлено',
      ChatMessageDeliveryStatus.delivered => 'Доставлено',
      ChatMessageDeliveryStatus.read => 'Прочитано',
    };

    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: Icon(
          delivered || read ? Icons.done_all_rounded : Icons.done_rounded,
          size: size,
          color: read
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryText,
        ),
      ),
    );
  }
}
