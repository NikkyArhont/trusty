import '/auth/base_auth_user_provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/guest/guest_session_service.dart';
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
  String? _profileLoadError;

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

  Future<UserRecord?> _loadCurrentUserDocument() async {
    final reference = currentUserReference;
    if (reference == null) return null;

    final cachedDocument = currentUserDocument;
    if (cachedDocument?.reference.id == reference.id) {
      return cachedDocument;
    }

    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final document = await UserRecord.getDocumentOnce(
          reference,
        ).timeout(const Duration(seconds: 10));
        currentUserDocument = document;
        return document;
      } catch (error) {
        lastError = error;
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
    }

    if (mounted) {
      setState(() {
        _profileLoadError =
            'Не удалось загрузить профиль. Проверьте соединение и повторите.';
      });
      FlutterNativeSplash.remove();
    }
    debugPrint('Failed to load current user document: $lastError');
    return null;
  }

  Future<void> _initializeAndRoute() async {
    if (mounted && _profileLoadError != null) {
      setState(() => _profileLoadError = null);
    }

    if (FFAppState().listRUCities.isEmpty) {
      FFAppState().listRUCities = functions
          .createCityList(FFAppState().listCityVocab)!
          .toList()
          .cast<PlaceStruct>();
      if (mounted) safeSetState(() {});
    }
    if (!loggedIn) {
      final guestReady = await ensureGuestSession(context);
      if (!mounted) return;
      if (!guestReady) {
        setState(() {
          _profileLoadError =
              'Не удалось открыть гостевой режим. Проверьте соединение и повторите.';
        });
        FlutterNativeSplash.remove();
        return;
      }
    }

    if (currentUserIsAnonymous) {
      FFAppState().specialistMode = false;
      _goNamedAndRemoveSplash(MainWidget.routeName);
      return;
    }

    final userDocument = await _loadCurrentUserDocument();
    if (!mounted || userDocument == null) return;

    FFAppState().specialistMode = userDocument.masterMode;
    safeSetState(() {});

    if (!userDocument.clientProfileCompleted &&
        userDocument.displayName.trim().isEmpty) {
      _goNamedAndRemoveSplash(ClientProfileSetupWidget.routeName);
      return;
    }
    if (userDocument.mainLoc.title.trim().isEmpty) {
      final masterCity = userDocument.masterData.mainAdres;
      if (masterCity.title.trim().isNotEmpty) {
        await userDocument.reference.update(
          createUserRecordData(mainLoc: masterCity),
        );
        FFAppState().updateGlobalFilterStruct((e) => e..place = masterCity);
      } else {
        _goNamedAndRemoveSplash(
          ChooseLocationCityWidget.routeName,
          queryParameters: {
            'edit': serializeParam(false, ParamType.bool),
          }.withoutNulls,
        );
        return;
      }
    } else {
      FFAppState().updateGlobalFilterStruct(
        (e) => e..place = userDocument.mainLoc,
      );
    }
    if (userDocument.referralOnboardingRequired &&
        !userDocument.referralOnboardingCompleted) {
      _goNamedAndRemoveSplash(ReferralOnboardingWidget.routeName);
      return;
    }
    if (FFAppState().specialistMode) {
      if (_masterProfileCompleted(userDocument.masterData)) {
        _goNamedAndRemoveSplash(SpecialistDashboardWidget.routeName);
      } else if (userDocument.masterData.onboardingCompleted) {
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
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InitpageModel());

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _initializeAndRoute(),
    );

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
      body: Center(
        child: _profileLoadError == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _profileLoadError!,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    FilledButton(
                      onPressed: _initializeAndRoute,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
