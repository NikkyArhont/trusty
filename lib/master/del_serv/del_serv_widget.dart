import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'del_serv_model.dart';
export 'del_serv_model.dart';

class DelServWidget extends StatefulWidget {
  const DelServWidget({super.key, required this.servTodel});

  final ServiceRecord? servTodel;

  @override
  State<DelServWidget> createState() => _DelServWidgetState();
}

class _DelServWidgetState extends State<DelServWidget> {
  late DelServModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DelServModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> _deleteService() async {
    final service = widget.servTodel;
    if (service == null || _model.isDeleting) {
      return;
    }

    _model.isDeleting = true;
    safeSetState(() {});

    try {
      for (final imageUrl in service.image) {
        if (imageUrl.trim().isEmpty) {
          continue;
        }
        try {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        } catch (_) {
          // The file may already be deleted or may not belong to Firebase Storage.
        }
      }

      await service.reference.delete();

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      context.goNamed(SpecialistDashboardWidget.routeName);
    } catch (error) {
      _model.isDeleting = false;
      if (!mounted) {
        return;
      }
      safeSetState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось удалить услугу: $error')),
      );
    }
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
                Icons.warning_rounded,
                color: FlutterFlowTheme.of(context).error,
                size: 48.0,
              ),
              Text(
                FFLocalizations.of(
                  context,
                ).getText('r9urwors' /* Уверены что хотите удалить усл... */),
                textAlign: TextAlign.center,
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
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
              ),
              Text(
                FFLocalizations.of(
                  context,
                ).getText('3e8ao5bu' /* Это дейстие нельзя отменить */),
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.jetBrainsMono(
                    fontWeight: FlutterFlowTheme.of(
                      context,
                    ).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FFButtonWidget(
                    onPressed: _model.isDeleting
                        ? null
                        : () async {
                            Navigator.pop(context);
                          },
                    text: FFLocalizations.of(
                      context,
                    ).getText('4gjsf3pk' /* Отмена */),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 44.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                      ),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall
                          .override(
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
                  FFButtonWidget(
                    onPressed: _model.isDeleting ? null : _deleteService,
                    text: _model.isDeleting ? 'Удаляем...' : 'Удалить',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 44.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle: FlutterFlowTheme.of(context).titleSmall
                          .override(
                            font: GoogleFonts.interTight(
                              fontWeight: FlutterFlowTheme.of(
                                context,
                              ).titleSmall.fontWeight,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).titleSmall.fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).error,
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
                ].divide(SizedBox(height: 8.0)),
              ),
            ].divide(SizedBox(height: 12.0)),
          ),
        ),
      ),
    );
  }
}
