import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'nav_back_model.dart';
export 'nav_back_model.dart';

class NavBackWidget extends StatefulWidget {
  const NavBackWidget({super.key});

  @override
  State<NavBackWidget> createState() => _NavBackWidgetState();
}

class _NavBackWidgetState extends State<NavBackWidget> {
  late NavBackModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavBackModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterFlowIconButton(
      borderColor: FlutterFlowTheme.of(context).secondaryText,
      borderRadius: 12.0,
      buttonSize: 40.0,
      fillColor: FlutterFlowTheme.of(context).primaryBackground,
      icon: Icon(
        Icons.arrow_back_rounded,
        color: FlutterFlowTheme.of(context).primaryText,
        size: 24.0,
      ),
      showLoadingIndicator: true,
      onPressed: () async {
        context.safePop();
      },
    );
  }
}
