import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'contact_avatars_model.dart';
export 'contact_avatars_model.dart';

class ContactAvatarsWidget extends StatefulWidget {
  const ContactAvatarsWidget({super.key});

  @override
  State<ContactAvatarsWidget> createState() => _ContactAvatarsWidgetState();
}

class _ContactAvatarsWidgetState extends State<ContactAvatarsWidget> {
  late ContactAvatarsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ContactAvatarsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: Color(0xFFE0E7FF),
            shape: BoxShape.circle,
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Text(
            FFLocalizations.of(context).getText(
              'z2ppj88b' /* JD */,
            ),
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primary,
              fontWeight: FontWeight.w600,
              fontSize: 9.6,
            ),
          ),
        ),
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Text(
            FFLocalizations.of(context).getText(
              '6n40evke' /* AS */,
            ),
            style: TextStyle(
              color: FlutterFlowTheme.of(context).success,
              fontWeight: FontWeight.w600,
              fontSize: 9.6,
            ),
          ),
        ),
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Text(
            FFLocalizations.of(context).getText(
              '6j66kmhj' /* MK */,
            ),
            style: TextStyle(
              color: Color(0xFFD97706),
              fontWeight: FontWeight.w600,
              fontSize: 9.6,
            ),
          ),
        ),
      ],
    );
  }
}
