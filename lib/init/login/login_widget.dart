import '/auth/firebase_auth/auth_util.dart';
import '/auth/temporary_phone_auth.dart';
import '/backend/analytics/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'dart:async';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with WidgetsBindingObserver {
  static const String _phonePrefix = '+7';
  static const int _phonePrefixLength = 2;

  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isRequestingCode = false;
  bool _isRequestingTelegram = false;
  String? _activeTelegramChallengeId;
  TelegramAuthChallenge? _activeTelegramChallenge;
  bool _telegramStatusCheckInProgress = false;
  bool _telegramDialogVisible = false;
  bool _termsAccepted = false;

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

  void _toggleTermsAcceptance() {
    safeSetState(() => _termsAccepted = !_termsAccepted);
  }

  Future<void> _requestSms(String phone) async {
    if (_isRequestingCode) return;
    safeSetState(() => _isRequestingCode = true);
    try {
      final challenge = await requestPhoneAuthCode(phone: phone);
      if (!mounted) return;
      context.pushNamedAuth(
        SmsWidget.routeName,
        mounted,
        queryParameters: {
          'phone': serializeParam(phone, ParamType.String),
          'verificationId': serializeParam(
            challenge.verificationId,
            ParamType.String,
          ),
        }.withoutNulls,
        ignoreRedirect: true,
      );
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
      if (mounted) safeSetState(() => _isRequestingCode = false);
    }
  }

  Future<void> _startTelegramLogin(String phone) async {
    if (_isRequestingTelegram) return;
    safeSetState(() => _isRequestingTelegram = true);
    try {
      final challenge = await createTelegramPhoneAuth(phone: phone);
      if (!mounted) return;
      _activeTelegramChallengeId = challenge.challengeId;
      _activeTelegramChallenge = challenge;
      unawaited(_showTelegramWaitingDialog(phone, challenge));
      unawaited(_pollTelegramLogin(challenge));
      final opened = await launchUrl(
        Uri.parse(challenge.botUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw const PhoneAuthApiException(
          'telegram_unavailable',
          'Не удалось открыть Telegram.',
        );
      }
    } on PhoneAuthApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
      _activeTelegramChallengeId = null;
      _activeTelegramChallenge = null;
      _dismissTelegramDialog();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось начать вход через Telegram.'),
          ),
        );
      }
      _activeTelegramChallengeId = null;
      _activeTelegramChallenge = null;
      _dismissTelegramDialog();
    } finally {
      if (mounted) safeSetState(() => _isRequestingTelegram = false);
    }
  }

  Future<void> _showTelegramWaitingDialog(
    String phone,
    TelegramAuthChallenge challenge,
  ) async {
    _telegramDialogVisible = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            icon: const Icon(Icons.telegram, size: 42.0),
            title: const Text('Ожидаем подтверждение'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text(
                  'В боте нажмите «Поделиться номером телефона», затем вернитесь в приложение. Вход завершится автоматически.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  _activeTelegramChallengeId = null;
                  _activeTelegramChallenge = null;
                  Navigator.pop(dialogContext);
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  _activeTelegramChallengeId = null;
                  _activeTelegramChallenge = null;
                  Navigator.pop(dialogContext);
                  _requestSms(phone);
                },
                child: const Text('Получить СМС'),
              ),
              FilledButton(
                onPressed: () => launchUrl(
                  Uri.parse(challenge.botUrl),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Открыть Telegram'),
              ),
            ],
          ),
        ),
      );
    } finally {
      _telegramDialogVisible = false;
    }
  }

  Future<void> _pollTelegramLogin(TelegramAuthChallenge challenge) async {
    final deadline = DateTime.now().add(Duration(seconds: challenge.expiresIn));
    while (mounted &&
        _activeTelegramChallengeId == challenge.challengeId &&
        DateTime.now().isBefore(deadline)) {
      if (await _checkTelegramChallenge(challenge)) return;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    if (!mounted || _activeTelegramChallengeId != challenge.challengeId) return;
    _activeTelegramChallengeId = null;
    _activeTelegramChallenge = null;
    _dismissTelegramDialog();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Время подтверждения истекло. Попробуйте ещё раз.'),
      ),
    );
  }

  Future<bool> _checkTelegramChallenge(TelegramAuthChallenge challenge) async {
    if (_telegramStatusCheckInProgress ||
        !mounted ||
        _activeTelegramChallengeId != challenge.challengeId) {
      return false;
    }
    _telegramStatusCheckInProgress = true;
    try {
      final status = await checkTelegramPhoneAuth(
        challengeId: challenge.challengeId,
      );
      if (!mounted || _activeTelegramChallengeId != challenge.challengeId) {
        return false;
      }
      if (status.confirmed) {
        _activeTelegramChallengeId = null;
        _activeTelegramChallenge = null;
        _dismissTelegramDialog();
        await _completeTelegramLogin(status.token!);
        return true;
      }
      if (status.expired) {
        _activeTelegramChallengeId = null;
        _activeTelegramChallenge = null;
        _dismissTelegramDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Время подтверждения истекло. Попробуйте ещё раз.'),
          ),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _telegramStatusCheckInProgress = false;
    }
  }

  void _dismissTelegramDialog() {
    if (!_telegramDialogVisible || !mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }

  Future<void> _completeTelegramLogin(String customToken) async {
    GoRouter.of(context).prepareAuthEvent();
    // Always apply the token returned for the confirmed phone number. Reusing
    // an existing Firebase session can otherwise open a different account and
    // make the app ask for that account's missing profile data.
    final verifiedUser = await authManager.signInWithJwtToken(
      context,
      customToken,
    );
    if (!mounted || verifiedUser == null) return;
    AnalyticsService.instance.logLogin('telegram');
    final userDocument = currentUserDocument;
    if (userDocument != null &&
        !userDocument.clientProfileCompleted &&
        userDocument.displayName.trim().isEmpty) {
      context.goNamedAuth(ClientProfileSetupWidget.routeName, mounted);
    } else {
      context.goNamedAuth(InitpageWidget.routeName, mounted);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _model = createModel(context, () => LoginModel());

    _model.textController ??= TextEditingController(text: _phonePrefix);
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldFocusNode?.addListener(() {
      if (_model.textFieldFocusNode?.hasFocus ?? false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensurePhonePrefix();
        });
      }
    });

    _model.textFieldMask = MaskTextInputFormatter(
      mask: '+#############',
      initialText: _phonePrefix,
    );
    authManager.handlePhoneAuthStateChanges(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensurePhonePrefix();
    });
  }

  void _ensurePhonePrefix() {
    if (!mounted) {
      return;
    }

    final controller = _model.textController;
    if (controller == null ||
        (controller.text.isNotEmpty && controller.text != '+')) {
      return;
    }

    final value = _model.textFieldMask.updateMask(
      mask: '+#############',
      newValue: const TextEditingValue(
        text: _phonePrefix,
        selection: TextSelection.collapsed(offset: _phonePrefixLength),
      ),
    );
    controller.value = value.copyWith(
      selection: const TextSelection.collapsed(offset: _phonePrefixLength),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activeTelegramChallengeId = null;
    _activeTelegramChallenge = null;
    _model.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final challenge = _activeTelegramChallenge;
      if (challenge != null) {
        unawaited(_checkTelegramChallenge(challenge));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compactHeight = screenHeight < 760.0;
    final tightHeight = screenHeight < 680.0;
    final phoneText = _model.textController.text;
    final phoneDigits = phoneText.replaceAll(RegExp(r'\D'), '');
    final isPhoneComplete =
        phoneText.startsWith(_phonePrefix) && phoneDigits.length == 11;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  compactHeight ? 24.0 : 32.0,
                  tightHeight ? 12.0 : 24.0,
                  compactHeight ? 24.0 : 32.0,
                  0.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentUserIsAnonymous)
                          IconButton(
                            tooltip: 'Продолжить без регистрации',
                            onPressed: () =>
                                context.goNamed(MainWidget.routeName),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: tightHeight
                                ? 44.0
                                : compactHeight
                                ? 52.0
                                : 65.0,
                            height: tightHeight
                                ? 44.0
                                : compactHeight
                                ? 52.0
                                : 65.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText(
                                'rhoo2u3p' /* Welcome to TrustCircle */,
                              ),
                              style: FlutterFlowTheme.of(context).headlineMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).headlineMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    fontSize: compactHeight ? 22.0 : 26.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).headlineMedium.fontStyle,
                                    lineHeight: 1.25,
                                  ),
                            ),
                            Text(
                              FFLocalizations.of(context).getText(
                                'i120lxs3' /* Discover services through the ... */,
                              ),
                              maxLines: compactHeight ? 2 : null,
                              overflow: compactHeight
                                  ? TextOverflow.ellipsis
                                  : null,
                              style: FlutterFlowTheme.of(context).bodyLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).bodyLarge.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).secondaryText,
                                    fontSize: compactHeight ? 14.0 : 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodyLarge.fontStyle,
                                    lineHeight: 1.5,
                                  ),
                            ),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                      ].divide(SizedBox(height: compactHeight ? 10.0 : 16.0)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          child: TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            onChanged: (_) {
                              _ensurePhonePrefix();
                              EasyDebounce.debounce(
                                '_model.textController',
                                Duration(milliseconds: 100),
                                () => safeSetState(() {}),
                              );
                            },
                            onTap: () {
                              _ensurePhonePrefix();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _ensurePhonePrefix();
                              });
                            },
                            autofocus: false,
                            enabled: true,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: false,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.jetBrainsMono(
                                      fontWeight: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(
                                      context,
                                    ).labelMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).labelMedium.fontStyle,
                                  ),
                              hintText: FFLocalizations.of(
                                context,
                              ).getText('uredhshz' /* Номер телефона */),
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.jetBrainsMono(
                                      fontWeight: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(
                                      context,
                                    ).labelMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).labelMedium.fontStyle,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).secondary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : FlutterFlowTheme.of(
                                      context,
                                    ).secondaryBackground,
                            ),
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
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(
                                    context,
                                  ).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).bodyMedium.fontStyle,
                                ),
                            keyboardType: TextInputType.phone,
                            cursorColor: FlutterFlowTheme.of(
                              context,
                            ).primaryText,
                            enableInteractiveSelection: true,
                            validator: _model.textControllerValidator
                                .asValidator(context),
                            inputFormatters: [_model.textFieldMask],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    color: FlutterFlowTheme.of(context).success,
                                    size: 16.0,
                                  ),
                                  Flexible(
                                    child: Text(
                                      FFLocalizations.of(context).getText(
                                        '3dm94sj1' /* Мы пришлем вам код для авториз... */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.jetBrainsMono(
                                              fontWeight: FontWeight.normal,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodySmall.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodySmall.fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(width: 4.0)),
                              ),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ].divide(SizedBox(height: compactHeight ? 12.0 : 24.0)),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'llyucx8t' /* By continuing, you agree to ou... */,
                            ),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodySmall
                                .override(
                                  font: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodySmall.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).bodySmall.fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.center,
                              runSpacing: 2.0,
                              spacing: 4.0,
                              children: [
                                InkWell(
                                  onTap: () => _openLegalDocument(_termsUri),
                                  child: Text(
                                    'Пользовательское соглашение',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.jetBrainsMono(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primary,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                                ),
                                Text(
                                  FFLocalizations.of(
                                    context,
                                  ).getText('8ufg79q1' /* & */),
                                  style: FlutterFlowTheme.of(context).bodySmall
                                      .override(
                                        font: GoogleFonts.jetBrainsMono(
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodySmall.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).bodySmall.fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                InkWell(
                                  onTap: () => _openLegalDocument(_privacyUri),
                                  child: Text(
                                    'Политика конфиденциальности',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.jetBrainsMono(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primary,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CheckboxListTile(
                            value: _termsAccepted,
                            onChanged: (value) => safeSetState(
                              () => _termsAccepted = value ?? false,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _toggleTermsAcceptance,
                              child: const Text(
                                'Я принимаю Пользовательское соглашение и Политику конфиденциальности, включая запрет оскорбительного контента и недопустимого поведения.',
                                style: TextStyle(fontSize: 12.0, height: 1.35),
                              ),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed:
                                !isPhoneComplete ||
                                    !_termsAccepted ||
                                    _isRequestingTelegram ||
                                    _activeTelegramChallengeId != null
                                ? null
                                : () => _startTelegramLogin(
                                    _model.textController.text,
                                  ),
                            text: _isRequestingTelegram
                                ? 'Открываем Telegram...'
                                : 'Продолжить через Telegram',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                24.0,
                                0.0,
                                24.0,
                                0.0,
                              ),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                0.0,
                                0.0,
                                0.0,
                              ),
                              color:
                                  isPhoneComplete &&
                                      _termsAccepted &&
                                      !_isRequestingCode
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
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed:
                                !isPhoneComplete ||
                                    !_termsAccepted ||
                                    _isRequestingCode ||
                                    _activeTelegramChallengeId != null
                                ? null
                                : () => _requestSms(_model.textController.text),
                            text: _isRequestingCode
                                ? 'Отправляем код...'
                                : 'Получить код по СМС',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 48.0,
                              color: Colors.transparent,
                              textStyle: GoogleFonts.jetBrainsMono(
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                          ),
                        ].divide(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 36.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
