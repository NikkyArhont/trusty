import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'current_location_model.dart';
export 'current_location_model.dart';

class CurrentLocationWidget extends StatefulWidget {
  const CurrentLocationWidget({super.key});

  @override
  State<CurrentLocationWidget> createState() => _CurrentLocationWidgetState();
}

class _CurrentLocationWidgetState extends State<CurrentLocationWidget> {
  late CurrentLocationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CurrentLocationModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FFButtonWidget(
      onPressed: () {
        print('Button pressed ...');
      },
      text: FFLocalizations.of(context).getText(
        'aauulvwl' /* Местоположение */,
      ),
      icon: Icon(
        Icons.my_location_rounded,
        size: 15.0,
      ),
      options: FFButtonOptions(
        height: 44.0,
        padding: EdgeInsets.all(8.0),
        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        iconColor: FlutterFlowTheme.of(context).primary,
        color: Colors.transparent,
        textStyle: TextStyle(
          color: FlutterFlowTheme.of(context).primary,
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
        elevation: 0.0,
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).primary,
        ),
        borderRadius: BorderRadius.circular(22.0),
      ),
    );
  }
}
