import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'togle_mode_model.dart';
export 'togle_mode_model.dart';

class TogleModeWidget extends StatefulWidget {
  const TogleModeWidget({super.key});

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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      decoration: BoxDecoration(
        color: FFAppState().specialistMode
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Color(0xFFDBEAFE),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: FFAppState().specialistMode
                    ? FlutterFlowTheme.of(context).primaryBackground
                    : FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(9999.0),
              ),
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Stack(
                children: [
                  if (FFAppState().specialistMode)
                    Icon(
                      Icons.business_center_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24.0,
                    ),
                  if (!FFAppState().specialistMode)
                    Icon(
                      Icons.person,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      size: 24.0,
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFAppState().specialistMode ? 'Специалист' : 'Клиент',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontStyle,
                          ),
                          color: FFAppState().specialistMode
                              ? FlutterFlowTheme.of(context).primaryBackground
                              : FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                  ),
                  Text(
                    FFAppState().specialistMode
                        ? 'Создавайте свои услуги и привлекайте больше клиентов'
                        : 'Находите нужные услгуи по рекомендациям Ваших знакомых',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.normal,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                          color: FFAppState().specialistMode
                              ? FlutterFlowTheme.of(context).hint
                              : FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          lineHeight: 1.4,
                        ),
                  ),
                ].divide(SizedBox(height: 2.0)),
              ),
            ),
          ].divide(SizedBox(width: 16.0)),
        ),
      ),
    );
  }
}
