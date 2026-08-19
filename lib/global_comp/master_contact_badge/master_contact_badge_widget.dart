import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MasterContactBadgeWidget extends StatelessWidget {
  const MasterContactBadgeWidget({super.key, this.contactName});

  final String? contactName;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final savedName = contactName?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          theme.success.withValues(alpha: 0.10),
          theme.secondaryBackground,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.success.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.contact_phone_rounded, color: theme.success, size: 21.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Мастер есть у вас в контактах',
                  style: theme.labelLarge.override(
                    font: GoogleFonts.jetBrainsMono(),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (savedName.isNotEmpty) ...[
                  const SizedBox(height: 3.0),
                  Text(
                    'В телефонной книге: $savedName',
                    style: theme.bodySmall.override(
                      font: GoogleFonts.jetBrainsMono(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
