import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sms_model.dart';
export 'sms_model.dart';

class SmsWidget extends StatefulWidget {
  const SmsWidget({
    super.key,
    required this.phone,
  });

  final String? phone;

  static String routeName = 'sms';
  static String routePath = '/sms';

  @override
  State<SmsWidget> createState() => _SmsWidgetState();
}

class _SmsWidgetState extends State<SmsWidget> {
  late SmsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SmsModel());

    _model.pinCodeFocusNode ??= FocusNode();

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
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 44.0,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 28.0,
                      ),
                      onPressed: () {
                        print('IconButton pressed ...');
                      },
                    ),
                    Container(
                      height: 8.0,
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        '2ytlj0wi' /* СМС-код */,
                      ),
                      style:
                          FlutterFlowTheme.of(context).headlineLarge.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineLarge
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineLarge
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .fontStyle,
                              ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          FFLocalizations.of(context).getText(
                            'z7s2r5z2' /* Мы отправили код на */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                font: GoogleFonts.jetBrainsMono(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .fontStyle,
                              ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            widget!.phone,
                            'noPhone',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                font: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .fontStyle,
                              ),
                        ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                  ].divide(SizedBox(height: 16.0)),
                ),
                PinCodeTextField(
                  autoDisposeControllers: false,
                  appContext: context,
                  length: 6,
                  textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.jetBrainsMono(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                      ),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  enableActiveFill: false,
                  autoFocus: true,
                  focusNode: _model.pinCodeFocusNode,
                  enablePinAutofill: true,
                  errorTextSpace: 16.0,
                  showCursor: true,
                  cursorColor: FlutterFlowTheme.of(context).primary,
                  obscureText: false,
                  hintCharacter: '*',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  pinTheme: PinTheme(
                    fieldHeight: 44.0,
                    fieldWidth: 44.0,
                    borderWidth: 2.0,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    shape: PinCodeFieldShape.box,
                    activeColor: FlutterFlowTheme.of(context).primaryText,
                    inactiveColor: FlutterFlowTheme.of(context).alternate,
                    selectedColor: FlutterFlowTheme.of(context).primary,
                  ),
                  controller: _model.pinCodeController,
                  onChanged: (_) {},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator:
                      _model.pinCodeControllerValidator.asValidator(context),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'h58pggii' /* Отправить повторно через */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.jetBrainsMono(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      Text(
                        FFLocalizations.of(context).getText(
                          'bfhhunv5' /* 00:48 */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ].divide(SizedBox(width: 4.0)),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FFButtonWidget(
                        onPressed: () {
                          print('Button pressed ...');
                        },
                        text: FFLocalizations.of(context).getText(
                          'igud3czq' /* Изменить номер телефона */,
                        ),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 44.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: Colors.transparent,
                          textStyle: TextStyle(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          GoRouter.of(context).prepareAuthEvent();
                          final smsCodeVal = _model.pinCodeController!.text;
                          if (smsCodeVal == null || smsCodeVal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Enter SMS verification code.'),
                              ),
                            );
                            return;
                          }
                          final phoneVerifiedUser =
                              await authManager.verifySmsCode(
                            context: context,
                            smsCode: smsCodeVal,
                          );
                          if (phoneVerifiedUser == null) {
                            return;
                          }

                          if (FFAppState().firstTime) {
                            await currentUserReference!
                                .update(createUserRecordData(
                              masterMode: false,
                            ));

                            context.goNamedAuth(
                              ChooseLocationCityWidget.routeName,
                              context.mounted,
                              queryParameters: {
                                'edit': serializeParam(
                                  false,
                                  ParamType.bool,
                                ),
                              }.withoutNulls,
                            );
                          } else {
                            context.goNamedAuth(
                                MainWidget.routeName, context.mounted);
                          }
                        },
                        text: FFLocalizations.of(context).getText(
                          'q467ct16' /* Продолжить */,
                        ),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: GoogleFonts.jetBrainsMono(
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  ),
                ),
              ].divide(SizedBox(height: 32.0)),
            ),
          ),
        ),
      ),
    );
  }
}
