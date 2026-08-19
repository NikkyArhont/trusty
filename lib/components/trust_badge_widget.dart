import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'trust_badge_model.dart';
export 'trust_badge_model.dart';

class TrustBadgeWidget extends StatefulWidget {
  const TrustBadgeWidget({
    super.key,
    this.score,
  });

  final String? score;

  @override
  State<TrustBadgeWidget> createState() => _TrustBadgeWidgetState();
}

class _TrustBadgeWidgetState extends State<TrustBadgeWidget> {
  late TrustBadgeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrustBadgeModel());

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
      padding: EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8.0,
            sigmaY: 8.0,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: AlignmentDirectional(1.0, -1.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 14.0,
                  ),
                  Text(
                    'Доверие ${widget!.score}%',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.jetBrainsMono(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelSmall
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        ),
                  ),
                ].divide(SizedBox(width: 4.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
