import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'no_favorite_model.dart';
export 'no_favorite_model.dart';

class NoFavoriteWidget extends StatefulWidget {
  const NoFavoriteWidget({super.key});

  @override
  State<NoFavoriteWidget> createState() => _NoFavoriteWidgetState();
}

class _NoFavoriteWidgetState extends State<NoFavoriteWidget> {
  late NoFavoriteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NoFavoriteModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite_border,
          color: FlutterFlowTheme.of(context).primary,
          size: 48.0,
        ),
        Text(
          FFLocalizations.of(context).getText(
            'uc2ocjhr' /* Здесь пока пусто =( */,
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
        ),
        Text(
          FFLocalizations.of(context).getText(
            '68s46vss' /* Сохраните первую услугу себе в... */,
          ),
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.jetBrainsMono(
                  fontWeight:
                      FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
        ),
      ].divide(SizedBox(height: 12.0)),
    );
  }
}
