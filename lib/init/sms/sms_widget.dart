import '/auth/firebase_auth/auth_util.dart';
import '/auth/temporary_phone_auth.dart';
import '/backend/analytics/analytics_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import '/index.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sms_model.dart';
export 'sms_model.dart';

class SmsWidget extends StatefulWidget {
  const SmsWidget({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  final String? phone;
  final String? verificationId;

  static String routeName = 'sms';
  static String routePath = '/sms';

  @override
  State<SmsWidget> createState() => _SmsWidgetState();
}

class _SmsWidgetState extends State<SmsWidget> {
  static const int _resendDelaySeconds = 60;

  late SmsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _resendTimer;
  int _remainingSeconds = _resendDelaySeconds;
  late String? _verificationId;
  String? _verifiedCustomToken;
  bool _isRequestingCode = false;
  bool _isVerifying = false;
  bool _rulesAccepted = false;

  static final Uri _termsUri = Uri.parse(
    'https://docs.google.com/document/d/18EWi-jwZxtkkj4ZfGHXc9HAw8y6UDKzY3FpGfX23FZ4/edit?usp=drive_link',
  );
  static final Uri _privacyUri = Uri.parse(
    'https://docs.google.com/document/d/1Kh1Td-DSFuDpx2n0ofGkjI2ZvRNP2mmiFxhi-nDZ0vk/edit?usp=drive_link',
  );

  Future<void> _openLegalDocument(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть документ')),
      );
    }
  }

  void _toggleRulesAcceptance() {
    safeSetState(() => _rulesAccepted = !_rulesAccepted);
  }

  String get _formattedRemainingTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _startResendTimer({
    int seconds = _resendDelaySeconds,
    bool notify = true,
  }) {
    _resendTimer?.cancel();
    final deadline = DateTime.now().add(Duration(seconds: seconds));

    if (notify) {
      safeSetState(() => _remainingSeconds = seconds);
    } else {
      _remainingSeconds = seconds;
    }

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final millisecondsLeft = deadline
          .difference(DateTime.now())
          .inMilliseconds;
      final secondsLeft = millisecondsLeft <= 0
          ? 0
          : (millisecondsLeft + 999) ~/ 1000;

      safeSetState(() => _remainingSeconds = secondsLeft);
      if (secondsLeft == 0) {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SmsModel());
    _verificationId = widget.verificationId;

    _model.pinCodeFocusNode ??= FocusNode();
    _startResendTimer(notify: false);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _resendCode() async {
    if (_isRequestingCode || _remainingSeconds > 0) {
      return;
    }
    safeSetState(() => _isRequestingCode = true);
    try {
      final challenge = await requestPhoneAuthCode(phone: widget.phone ?? '');
      if (!mounted) {
        return;
      }
      _verificationId = challenge.verificationId;
      _verifiedCustomToken = null;
      _model.pinCodeController?.clear();
      _startResendTimer(seconds: challenge.resendAfter);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Новый код отправлен.')));
    } on PhoneAuthApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сервер авторизации временно недоступен.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isRequestingCode = false);
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
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
        child: LayoutBuilder(
          builder: (context, viewportConstraints) {
            final horizontalPadding = viewportConstraints.maxWidth < 360.0
                ? 16.0
                : 24.0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16.0,
                horizontalPadding,
                24.0,
              ),
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
                        fillColor: FlutterFlowTheme.of(
                          context,
                        ).secondaryBackground,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 28.0,
                        ),
                        onPressed: () async {
                          context.safePop();
                        },
                      ),
                      Container(height: 8.0),
                      Text(
                        FFLocalizations.of(
                          context,
                        ).getText('2ytlj0wi' /* СМС-код */),
                        style: FlutterFlowTheme.of(context).headlineLarge
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FlutterFlowTheme.of(
                                  context,
                                ).headlineLarge.fontWeight,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).headlineLarge.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(
                                context,
                              ).headlineLarge.fontWeight,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).headlineLarge.fontStyle,
                            ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${FFLocalizations.of(context).getText('z7s2r5z2' /* Мы отправили код на */)} ',
                              style: FlutterFlowTheme.of(context).bodyLarge
                                  .override(
                                    font: GoogleFonts.jetBrainsMono(),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            TextSpan(
                              text: valueOrDefault<String>(
                                widget.phone,
                                'Номер не указан',
                              ),
                              style: FlutterFlowTheme.of(context).bodyLarge
                                  .override(
                                    font: GoogleFonts.jetBrainsMono(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        softWrap: true,
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  ),
                  LayoutBuilder(
                    builder: (context, codeConstraints) {
                      final availablePerField =
                          (codeConstraints.maxWidth -
                              (phoneAuthCodeLength - 1) * 12.0) /
                          phoneAuthCodeLength;
                      final fieldSize = availablePerField.clamp(36.0, 44.0);

                      return PinCodeTextField(
                        autoDisposeControllers: false,
                        appContext: context,
                        length: phoneAuthCodeLength,
                        textStyle: FlutterFlowTheme.of(context).bodyLarge
                            .override(
                              font: GoogleFonts.jetBrainsMono(
                                fontWeight: FlutterFlowTheme.of(
                                  context,
                                ).bodyLarge.fontWeight,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).bodyLarge.fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(
                                context,
                              ).bodyLarge.fontWeight,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).bodyLarge.fontStyle,
                            ),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        pinTheme: PinTheme(
                          fieldHeight: fieldSize,
                          fieldWidth: fieldSize,
                          borderWidth: 2.0,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                          shape: PinCodeFieldShape.box,
                          activeColor: FlutterFlowTheme.of(context).primaryText,
                          inactiveColor: FlutterFlowTheme.of(context).alternate,
                          selectedColor: FlutterFlowTheme.of(context).primary,
                        ),
                        controller: _model.pinCodeController,
                        onChanged: (_) {},
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _model.pinCodeControllerValidator
                            .asValidator(context),
                      );
                    },
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: _remainingSeconds > 0
                        ? Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4.0,
                            runSpacing: 2.0,
                            children: [
                              Text(
                                FFLocalizations.of(context).getText(
                                  'h58pggii' /* Отправить повторно через */,
                                ),
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodyMedium
                                    .override(
                                      font: GoogleFonts.jetBrainsMono(
                                        fontWeight: FlutterFlowTheme.of(
                                          context,
                                        ).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).bodyMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMedium.fontStyle,
                                    ),
                              ),
                              Text(
                                _formattedRemainingTime,
                                style: FlutterFlowTheme.of(context).bodyMedium
                                    .override(
                                      font: GoogleFonts.jetBrainsMono(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).bodyMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMedium.fontStyle,
                                    ),
                              ),
                            ],
                          )
                        : TextButton(
                            onPressed: _isRequestingCode ? null : _resendCode,
                            style: TextButton.styleFrom(
                              foregroundColor: FlutterFlowTheme.of(
                                context,
                              ).primary,
                              minimumSize: const Size(0.0, 44.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                            ),
                            child: Text(
                              _isRequestingCode
                                  ? 'Отправляем...'
                                  : 'Отправить повторно',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FFButtonWidget(
                        onPressed: () async {
                          context.safePop();
                        },
                        text: FFLocalizations.of(
                          context,
                        ).getText('igud3czq' /* Изменить номер телефона */),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 44.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                          ),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                          ),
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
                        onPressed: _isVerifying || !_rulesAccepted
                            ? null
                            : () async {
                                GoRouter.of(context).prepareAuthEvent();
                                final smsCodeVal = _model
                                    .pinCodeController!
                                    .text
                                    .trim();
                                if (smsCodeVal.length != phoneAuthCodeLength) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Введите четырёхзначный код.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final verificationId = _verificationId;
                                if (verificationId == null ||
                                    verificationId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Запросите новый код подтверждения.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                safeSetState(() => _isVerifying = true);
                                dynamic phoneVerifiedUser;
                                try {
                                  _verifiedCustomToken ??=
                                      await verifyPhoneAuthCode(
                                        phone: widget.phone ?? '',
                                        verificationId: verificationId,
                                        code: smsCodeVal,
                                      );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  // The verified token identifies the phone
                                  // number entered on this screen. Apply it even
                                  // when Firebase still has another active user;
                                  // otherwise the app may read the wrong profile.
                                  phoneVerifiedUser = await authManager
                                      .signInWithJwtToken(
                                        context,
                                        _verifiedCustomToken!,
                                      );
                                } on PhoneAuthApiException catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error.userMessage),
                                      ),
                                    );
                                  }
                                  return;
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Сервер авторизации временно недоступен.',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                } finally {
                                  if (mounted) {
                                    safeSetState(() => _isVerifying = false);
                                  }
                                }
                                if (phoneVerifiedUser == null) {
                                  return;
                                }

                                AnalyticsService.instance.logLogin('sms');
                                _verifiedCustomToken = null;
                                final userDocument = currentUserDocument;
                                if (!context.mounted) {
                                  return;
                                }
                                if (userDocument != null &&
                                    !userDocument.clientProfileCompleted &&
                                    userDocument.displayName.trim().isEmpty) {
                                  context.goNamedAuth(
                                    ClientProfileSetupWidget.routeName,
                                    context.mounted,
                                  );
                                } else {
                                  context.goNamedAuth(
                                    InitpageWidget.routeName,
                                    context.mounted,
                                  );
                                }
                              },
                        text: _isVerifying
                            ? 'Проверяем...'
                            : FFLocalizations.of(
                                context,
                              ).getText('q467ct16' /* Продолжить */),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                          ),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                          ),
                          color: _rulesAccepted
                              ? FlutterFlowTheme.of(context).primary
                              : FlutterFlowTheme.of(context).secondary,
                          textStyle: GoogleFonts.jetBrainsMono(
                            color: FlutterFlowTheme.of(
                              context,
                            ).primaryBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _rulesAccepted,
                              onChanged: (value) => safeSetState(
                                () => _rulesAccepted = value ?? false,
                              ),
                              activeColor: FlutterFlowTheme.of(context).primary,
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _toggleRulesAcceptance,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Продолжая использование приложения, вы соглашаетесь с правилами сервиса.',
                                      style: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMedium,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'В приложении запрещены:\n'
                                      '— оскорбления и травля\n'
                                      '— спам и мошенничество\n'
                                      '— публикация неприемлемого контента',
                                      style: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMedium,
                                    ),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      'Мы удаляем такой контент и блокируем нарушителей. Жалобы рассматриваются в течение 24 часов.',
                                      style: FlutterFlowTheme.of(
                                        context,
                                      ).bodySmall,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Wrap(
                                      spacing: 12.0,
                                      runSpacing: 4.0,
                                      children: [
                                        InkWell(
                                          onTap: () =>
                                              _openLegalDocument(_termsUri),
                                          child: Text(
                                            'Пользовательское соглашение',
                                            style: TextStyle(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () =>
                                              _openLegalDocument(_privacyUri),
                                          child: Text(
                                            'Политика конфиденциальности',
                                            style: TextStyle(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  ),
                ].divide(SizedBox(height: 32.0)),
              ),
            );
          },
        ),
      ),
    );
  }
}
