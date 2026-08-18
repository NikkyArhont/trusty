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
import 'package:flutter_native_splash/flutter_native_splash.dart';
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

  bool _masterProfileCompleted(MasterDataStruct? masterData) {
    if (masterData == null) {
      return false;
    }
    return masterData.title.trim().isNotEmpty &&
        masterData.descrip.trim().isNotEmpty &&
        masterData.initCat.trim().isNotEmpty &&
        masterData.mainPhoto.trim().isNotEmpty &&
        masterData.hasMainAdres() &&
        masterData.mainAdres.title.trim().isNotEmpty;
  }

  void _goNamedAndRemoveSplash(
    String routeName, {
    Map<String, String> queryParameters = const {},
  }) {
    context.goNamed(routeName, queryParameters: queryParameters);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FlutterNativeSplash.remove(),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InitpageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().listRUCities.isEmpty) {
        FFAppState().listRUCities = functions
            .createCityList(FFAppState().listCityVocab)!
            .toList()
            .cast<PlaceStruct>();
        safeSetState(() {});
      }
      if (loggedIn) {
        if (currentUserDocument == null) {
          await authenticatedUserStream
              .firstWhere((user) => user != null)
              .timeout(
                const Duration(milliseconds: 2500),
                onTimeout: () => null,
              );
        }
        if (!mounted) {
          return;
        }
        if (currentUserDocument != null) {
          FFAppState().specialistMode = valueOrDefault<bool>(
            currentUserDocument?.masterMode,
            FFAppState().specialistMode,
          );
          safeSetState(() {});
        }
        final userDocument = currentUserDocument;
        if (userDocument != null &&
            !userDocument.clientProfileCompleted &&
            userDocument.displayName.trim().isEmpty) {
          _goNamedAndRemoveSplash(ClientProfileSetupWidget.routeName);
          return;
        }
        if (FFAppState().specialistMode) {
          if (_masterProfileCompleted(currentUserDocument?.masterData)) {
            _goNamedAndRemoveSplash(SpecialistDashboardWidget.routeName);
          } else if (currentUserDocument?.masterData.onboardingCompleted ??
              false) {
            _goNamedAndRemoveSplash(
              EditProfileMasterWidget.routeName,
              queryParameters: {
                'setupMode': serializeParam(true, ParamType.bool),
              }.withoutNulls,
            );
          } else {
            _goNamedAndRemoveSplash(MasterOnboardingWidget.routeName);
          }
        } else {
          _goNamedAndRemoveSplash(MainWidget.routeName);
        }
      } else {
        _goNamedAndRemoveSplash(LoginWidget.routeName);
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
      body: const SizedBox.expand(),
    );
  }
}
