import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'serv_status_model.dart';
export 'serv_status_model.dart';

class ServStatusWidget extends StatefulWidget {
  const ServStatusWidget({
    super.key,
    required this.status,
  });

  final ServiceStatus? status;

  @override
  State<ServStatusWidget> createState() => _ServStatusWidgetState();
}

class _ServStatusWidgetState extends State<ServStatusWidget> {
  late ServStatusModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServStatusModel());

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
        color: () {
          if (widget!.status == ServiceStatus.onModerate) {
            return FlutterFlowTheme.of(context).warning;
          } else if (widget!.status == ServiceStatus.show) {
            return FlutterFlowTheme.of(context).accent1;
          } else if (widget!.status == ServiceStatus.arhive) {
            return FlutterFlowTheme.of(context).secondaryText;
          } else if (widget!.status == ServiceStatus.denied) {
            return FlutterFlowTheme.of(context).error;
          } else {
            return FlutterFlowTheme.of(context).secondary;
          }
        }(),
        borderRadius: BorderRadius.circular(9999.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
        child: Text(
          () {
            if (widget!.status == ServiceStatus.onModerate) {
              return 'На модерации';
            } else if (widget!.status == ServiceStatus.show) {
              return 'Активна';
            } else if (widget!.status == ServiceStatus.arhive) {
              return 'В архиве';
            } else if (widget!.status == ServiceStatus.denied) {
              return 'Отклонена';
            } else {
              return '';
            }
          }(),
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.jetBrainsMono(
                  fontWeight:
                      FlutterFlowTheme.of(context).labelSmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryBackground,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
              ),
        ),
      ),
    );
  }
}
