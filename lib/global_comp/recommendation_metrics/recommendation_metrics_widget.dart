import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationMetricsWidget extends StatelessWidget {
  const RecommendationMetricsWidget({
    super.key,
    required this.totalCount,
    required this.contactsCount,
    required this.scopeDescription,
  });

  final int totalCount;
  final int contactsCount;
  final String scopeDescription;

  Future<void> _showExplanation(BuildContext context) async {
    final theme = FlutterFlowTheme.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: theme.secondaryBackground,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Что означают эти цифры?',
                        style: theme.titleLarge.override(
                          font: GoogleFonts.interTight(),
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Закрыть',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _ExplanationRow(
                  color: theme.primary,
                  icon: Icons.thumb_up_alt_rounded,
                  title: 'Синий блок — $totalCount',
                  description:
                      'Общее количество пользователей, которые рекомендовали $scopeDescription.',
                ),
                const SizedBox(height: 14.0),
                _ExplanationRow(
                  color: theme.accent3,
                  icon: Icons.people_rounded,
                  title: 'Фиолетовый блок — $contactsCount',
                  description:
                      'Сколько из этих пользователей есть в ваших синхронизированных контактах.',
                ),
                const SizedBox(height: 20.0),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.primaryBackground,
                    minimumSize: const Size.fromHeight(48.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: const Text('Понятно'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Semantics(
      button: true,
      label: 'Пояснение показателей рекомендаций',
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _showExplanation(context),
        child: Row(
          children: [
            Expanded(
              child: _MetricBlock(
                color: theme.primary,
                icon: Icons.thumb_up_alt_rounded,
                value: totalCount,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _MetricBlock(
                color: theme.accent3,
                icon: Icons.people_rounded,
                value: contactsCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.color,
    required this.icon,
    required this.value,
  });

  final Color color;
  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44.0),
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 18.0),
        const SizedBox(width: 7.0),
        Text(
          '$value',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ExplanationRow extends StatelessWidget {
  const _ExplanationRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.0,
          height: 38.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(icon, color: Colors.white, size: 19.0),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.labelLarge.override(
                  font: GoogleFonts.jetBrainsMono(),
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                description,
                style: theme.bodySmall.override(
                  font: GoogleFonts.jetBrainsMono(),
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  lineHeight: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
