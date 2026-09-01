import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final Map<String, Stream<bool>> _highlightStreams = {};

Stream<bool> _hasCompletedVisitWithInviter(
  DocumentReference client,
  DocumentReference inviter,
) {
  final key = '${client.path}|${inviter.path}';
  return _highlightStreams.putIfAbsent(
    key,
    () => RecordsRecord.collection
        .where('client', isEqualTo: client)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(RecordsRecord.fromSnapshot)
              .any(
                (record) =>
                    record.master == inviter &&
                    record.status == RecordStatus.complite,
              ),
        )
        .distinct()
        .asBroadcastStream(),
  );
}

class YourMasterServiceFrame extends StatelessWidget {
  const YourMasterServiceFrame({
    super.key,
    required this.service,
    required this.child,
    required this.borderRadius,
  });

  final ServiceRecord service;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final client = currentUserReference;
    final inviter = currentUserDocument?.invitedBy;
    if (client == null || inviter == null || service.owner != inviter) {
      return child;
    }

    return StreamBuilder<bool>(
      stream: _hasCompletedVisitWithInviter(client, inviter),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == true) return child;
        final success = FlutterFlowTheme.of(context).success;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: success, width: 2.0),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: success,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Ваш мастер',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class YourMasterServiceBadge extends StatelessWidget {
  const YourMasterServiceBadge({super.key, required this.service});

  final ServiceRecord service;

  @override
  Widget build(BuildContext context) {
    final client = currentUserReference;
    final inviter = currentUserDocument?.invitedBy;
    if (client == null || inviter == null || service.owner != inviter) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<bool>(
      stream: _hasCompletedVisitWithInviter(client, inviter),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == true) {
          return const SizedBox.shrink();
        }
        final success = FlutterFlowTheme.of(context).success;
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: success.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: success, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Ваш мастер',
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                    color: success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
