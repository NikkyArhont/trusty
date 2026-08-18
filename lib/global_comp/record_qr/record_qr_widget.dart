import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'record_qr_scanner_widget.dart';

class RecordQrWidget extends StatelessWidget {
  const RecordQrWidget({super.key, required this.recordReference});

  final DocumentReference recordReference;

  String get qrValue => 'trusty://record/${recordReference.id}';

  Future<void> _completeRecord() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(recordReference);
      final data = snapshot.data() as Map<String, dynamic>? ?? const {};
      if (data['completed_time'] != null) {
        return;
      }

      transaction.update(recordReference, {
        'status': 'complite',
        'completed_time': FieldValue.serverTimestamp(),
        'completed_by': currentUserReference,
        'completion_method': 'qr',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 184,
          height: 184,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FlutterFlowTheme.of(context).divider),
          ),
          child: QrImageView(
            data: qrValue,
            version: QrVersions.auto,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () async {
              final matched = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => RecordQrScannerWidget(expectedValue: qrValue),
                ),
              );
              if (matched == true && context.mounted) {
                try {
                  await _completeRecord();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Услуга отмечена как оказанная'),
                      ),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Не удалось подтвердить оказание услуги'),
                      ),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Сканировать'),
            style: FilledButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: FlutterFlowTheme.of(context).primaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
