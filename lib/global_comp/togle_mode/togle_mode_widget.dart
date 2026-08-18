import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'togle_mode_model.dart';
export 'togle_mode_model.dart';

class TogleModeWidget extends StatefulWidget {
  const TogleModeWidget({super.key, this.onModeSelected});

  final ValueChanged<bool>? onModeSelected;

  @override
  State<TogleModeWidget> createState() => _TogleModeWidgetState();
}

class _TogleModeWidgetState extends State<TogleModeWidget> {
  late TogleModeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TogleModeModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Widget _buildModeRow(
    BuildContext context, {
    required bool specialistMode,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final selected = FFAppState().specialistMode == specialistMode;

    return InkWell(
      onTap: selected
          ? null
          : () => widget.onModeSelected?.call(specialistMode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(
                  context,
                ).primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9999.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: FlutterFlowTheme.of(context).primary,
                size: 23.0,
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    description,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.normal,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.0,
                      lineHeight: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            SizedBox(
              width: 24.0,
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Material(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(14.0),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: FlutterFlowTheme.of(context).divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeRow(
              context,
              specialistMode: false,
              icon: Icons.person,
              title: 'Клиент',
              description:
                  'Находите нужные услуги по рекомендациям Ваших знакомых',
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).divider,
            ),
            _buildModeRow(
              context,
              specialistMode: true,
              icon: Icons.business_center_rounded,
              title: 'Специалист',
              description:
                  'Создавайте свои услуги и привлекайте больше клиентов',
            ),
          ],
        ),
      ),
    );
  }
}
