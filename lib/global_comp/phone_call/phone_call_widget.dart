import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'phone_call_model.dart';
export 'phone_call_model.dart';

class PhoneCallWidget extends StatefulWidget {
  const PhoneCallWidget({
    super.key,
    required this.phone,
  });

  final String? phone;

  @override
  State<PhoneCallWidget> createState() => _PhoneCallWidgetState();
}

class _PhoneCallWidgetState extends State<PhoneCallWidget> {
  late PhoneCallModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneCallModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 2.0,
                color: Color(0x1A000000),
                offset: Offset(
                  0.0,
                  1.0,
                ),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 16.0,
                      buttonSize: 56.0,
                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                      icon: Icon(
                        Icons.phone,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 32.0,
                      ),
                      onPressed: () async {
                        await launchUrl(Uri(
                          scheme: 'tel',
                          path: widget!.phone!,
                        ));
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'kqzi00sa' /* Позвонить */,
                      ),
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                            lineHeight: 1.3,
                          ),
                    ),
                  ].divide(SizedBox(height: 12.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 16.0,
                      buttonSize: 56.0,
                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                      icon: Icon(
                        Icons.content_copy,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 32.0,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget!.phone!));
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        't84giho8' /* Скопировать */,
                      ),
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                            lineHeight: 1.3,
                          ),
                    ),
                  ].divide(SizedBox(height: 12.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
