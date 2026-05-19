import '/auth/base_auth_user_provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'initpage_model.dart';
export 'initpage_model.dart';

class InitpageWidget extends StatefulWidget {
  const InitpageWidget({super.key});

  static String routeName = 'Initpage';
  static String routePath = '/initpage';

  @override
  State<InitpageWidget> createState() => _InitpageWidgetState();
}

class _InitpageWidgetState extends State<InitpageWidget> {
  late InitpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InitpageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if ((FFAppState().listRUCities.isNotEmpty) != false) {
        FFAppState().listRUCities = functions
            .createCityList(FFAppState().listCityVocab)!
            .toList()
            .cast<PlaceStruct>();
        safeSetState(() {});
      }
      if (loggedIn) {
        FFAppState().specialistMode =
            valueOrDefault<bool>(currentUserDocument?.masterMode, false);
        safeSetState(() {});
        if (FFAppState().specialistMode) {
          context.goNamed(SpecialistDashboardWidget.routeName);
        } else {
          context.goNamed(MainWidget.routeName);
        }
      } else {
        context.goNamed(LoginWidget.routeName);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/ChatGPT_Image_20_._2026_.,_13_28_15_(1)_(2).png',
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
