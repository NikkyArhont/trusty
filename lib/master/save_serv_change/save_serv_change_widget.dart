import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/share_prompt/share_prompt_service.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'save_serv_change_model.dart';
export 'save_serv_change_model.dart';

class SaveServChangeWidget extends StatefulWidget {
  const SaveServChangeWidget({
    super.key,
    required this.create,
    this.showFirstServiceInvite = false,
  });

  final bool? create;
  final bool showFirstServiceInvite;

  @override
  State<SaveServChangeWidget> createState() => _SaveServChangeWidgetState();
}

class _SaveServChangeWidgetState extends State<SaveServChangeWidget> {
  late SaveServChangeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SaveServChangeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).vertical -
              48.0,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: FlutterFlowTheme.of(context).primary,
                size: 48.0,
              ),
              if (!widget!.create!)
                Text(
                  FFLocalizations.of(
                    context,
                  ).getText('rxkx5udy' /* Изменения сохранены */),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).bodyMedium.fontStyle,
                  ),
                ),
              if (widget!.create ?? true)
                Text(
                  FFLocalizations.of(
                    context,
                  ).getText('audoqkgm' /* Услуга создана */),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).bodyMedium.fontStyle,
                  ),
                ),
              FFButtonWidget(
                onPressed: () async {
                  Navigator.pop(context);

                  context.goNamed(SpecialistDashboardWidget.routeName);
                  if (widget.showFirstServiceInvite) {
                    Future<void>.delayed(
                      const Duration(milliseconds: 500),
                      showFirstServiceInviteDialog,
                    );
                  }
                },
                text: FFLocalizations.of(
                  context,
                ).getText('7iln8vsd' /* Хорошо */),
                options: FFButtonOptions(
                  height: 40.0,
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                  ),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(
                        context,
                      ).titleSmall.fontWeight,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).titleSmall.fontStyle,
                    ),
                    color: Colors.white,
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(
                      context,
                    ).titleSmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).titleSmall.fontStyle,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ].divide(SizedBox(height: 12.0)),
          ),
        ),
      ),
    );
  }
}
