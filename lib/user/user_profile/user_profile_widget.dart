import '/auth/firebase_auth/auth_util.dart';
import '/admin/system_communications_preview_dialog.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/share_prompt/share_prompt_service.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import '/global_comp/togle_mode/togle_mode_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import '/init/sync_contacts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  static String routeName = 'UserProfile';
  static String routePath = '/userProfile';

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget>
    with TickerProviderStateMixin {
  late UserProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};
  DateTime? _lastContactsSyncDate;
  bool _contactsPermissionGranted = false;
  bool _contactsStatusLoading = true;
  bool _contactsSyncing = false;
  bool _modeSwitching = false;
  late final Future<PackageInfo> _packageInfo;
  late final AnimationController _contactsSyncController;

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());
    _packageInfo = PackageInfo.fromPlatform();
    _contactsSyncController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    animationsMap.addAll({
      'stackOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: 1.0,
            end: 0.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.0, 1.0),
            end: Offset(0.92, 0.92),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where(
        (anim) =>
            anim.trigger == AnimationTrigger.onActionTrigger ||
            !anim.applyInitialState,
      ),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshContactsSyncStatus();
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      await currentUserReference!.update(
        createUserRecordData(masterMode: FFAppState().specialistMode),
      );
    }();

    _model.dispose();
    _contactsSyncController.dispose();

    super.dispose();
  }

  Future<void> _refreshContactsSyncStatus() async {
    final permissionGranted = await hasContactsPermission();
    final lastSyncDate = await getLastContactsSyncDate();
    if (!mounted) {
      return;
    }
    safeSetState(() {
      _contactsPermissionGranted = permissionGranted;
      _lastContactsSyncDate = lastSyncDate;
      _contactsStatusLoading = false;
    });
  }

  Future<void> _refreshProfile() async {
    try {
      final userRef = currentUserReference;
      if (userRef != null) {
        final snapshot = await userRef.get(
          const GetOptions(source: Source.server),
        );
        if (snapshot.exists) {
          currentUserDocument = UserRecord.fromSnapshot(snapshot);
        }
      }
      await _refreshContactsSyncStatus();
      if (mounted) safeSetState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить профиль. Проверьте интернет.'),
        ),
      );
    }
  }

  Future<void> _selectMode(bool specialistMode) async {
    if (_modeSwitching || FFAppState().specialistMode == specialistMode) {
      return;
    }
    _modeSwitching = true;

    FFAppState().specialistMode = specialistMode;
    FFAppState().update(() {});

    try {
      await currentUserReference?.update(
        createUserRecordData(masterMode: specialistMode),
      );
    } catch (error) {
      debugPrint('Failed to persist selected mode: $error');
    } finally {
      _modeSwitching = false;
    }
  }

  bool get _contactsSyncIsStale {
    final lastSyncDate = _lastContactsSyncDate;
    if (lastSyncDate == null) {
      return false;
    }
    return isContactsSyncOlderThanThreeMonths(lastSyncDate);
  }

  String _formatContactsSyncDate(DateTime date) {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildContactsSyncStatus(BuildContext context) {
    if (_contactsStatusLoading) {
      return const SizedBox(
        height: 36.0,
        child: Center(
          child: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      );
    }

    final hasCompletedSync =
        _contactsPermissionGranted && _lastContactsSyncDate != null;
    final isStale = hasCompletedSync && _contactsSyncIsStale;
    final accentColor = !hasCompletedSync || isStale
        ? const Color(0xFFF59E0B)
        : FlutterFlowTheme.of(context).success;
    final title = !hasCompletedSync
        ? 'Контакты не синхронизированы'
        : isStale
        ? 'Контакты давно не обновлялись'
        : 'Контакты синхронизированы';
    final description = !hasCompletedSync
        ? 'Вы не сможете видеть рекомендации ваших знакомых. Нажмите кнопку синхронизации выше.'
        : isStale
        ? 'Последняя синхронизация: ${_formatContactsSyncDate(_lastContactsSyncDate!)}. Обновите контакты, чтобы рекомендации оставались актуальными.'
        : 'Последняя синхронизация: ${_formatContactsSyncDate(_lastContactsSyncDate!)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasCompletedSync && !isStale
                ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            color: accentColor,
            size: 20.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: GoogleFonts.jetBrainsMono(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 11.0,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).divider,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(
                          context,
                        ).getText('5fm06avj' /* Переключить тему */),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.jetBrainsMono(
                            fontWeight: FlutterFlowTheme.of(
                              context,
                            ).bodyLarge.fontWeight,
                            fontStyle: FlutterFlowTheme.of(
                              context,
                            ).bodyLarge.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(
                            context,
                          ).bodyLarge.fontWeight,
                          fontStyle: FlutterFlowTheme.of(
                            context,
                          ).bodyLarge.fontStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _model.switchValue ??=
                      !(Theme.of(context).brightness == Brightness.dark),
                  onChanged: (newValue) async {
                    safeSetState(() => _model.switchValue = newValue);
                    if (newValue) {
                      setDarkModeSetting(context, ThemeMode.light);
                    } else {
                      setDarkModeSetting(context, ThemeMode.dark);
                    }
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: FlutterFlowTheme.of(context).primary,
                  inactiveTrackColor: FlutterFlowTheme.of(context).alternate,
                  inactiveThumbColor: FlutterFlowTheme.of(context).primaryText,
                ),
              ].divide(SizedBox(width: 16.0)),
            ),
            Divider(color: FlutterFlowTheme.of(context).divider),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(
                          context,
                        ).getText('dhpmn30l' /* Синхронизировать контакты */),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.jetBrainsMono(
                            fontWeight: FlutterFlowTheme.of(
                              context,
                            ).bodyLarge.fontWeight,
                            fontStyle: FlutterFlowTheme.of(
                              context,
                            ).bodyLarge.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(
                            context,
                          ).bodyLarge.fontWeight,
                          fontStyle: FlutterFlowTheme.of(
                            context,
                          ).bodyLarge.fontStyle,
                        ),
                      ),
                      Text(
                        FFLocalizations.of(context).getText(
                          'tyy0ss41' /* Find friends to see their reco... */,
                        ),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.jetBrainsMono(
                            fontWeight: FlutterFlowTheme.of(
                              context,
                            ).bodySmall.fontWeight,
                            fontStyle: FlutterFlowTheme.of(
                              context,
                            ).bodySmall.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(
                            context,
                          ).bodySmall.fontWeight,
                          fontStyle: FlutterFlowTheme.of(
                            context,
                          ).bodySmall.fontStyle,
                        ),
                      ),
                    ].divide(SizedBox(height: 4.0)),
                  ),
                ),
                FlutterFlowIconButton(
                  borderRadius: 100.0,
                  buttonSize: 40.0,
                  fillColor: FlutterFlowTheme.of(context).primary,
                  icon: RotationTransition(
                    turns: _contactsSyncController,
                    child: Icon(
                      Icons.sync,
                      color: FlutterFlowTheme.of(context).info,
                      size: 24.0,
                    ),
                  ),
                  onPressed: _contactsSyncing
                      ? null
                      : () async {
                          safeSetState(() => _contactsSyncing = true);
                          _contactsSyncController.repeat();
                          var synchronized = false;
                          try {
                            final results = await Future.wait<dynamic>([
                              syncContacts(requestPermission: true),
                              Future<void>.delayed(
                                const Duration(milliseconds: 800),
                              ),
                            ]);
                            synchronized = results.first as bool;
                            await _refreshContactsSyncStatus();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    synchronized
                                        ? 'Контакты успешно синхронизированы!'
                                        : 'Не удалось синхронизировать контакты. Проверьте разрешение в настройках.',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).primaryText,
                                    ),
                                  ),
                                  backgroundColor: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                ),
                              );
                            }
                          } finally {
                            _contactsSyncController
                              ..stop()
                              ..reset();
                            if (mounted) {
                              safeSetState(() => _contactsSyncing = false);
                            }
                          }
                        },
                ),
              ].divide(SizedBox(width: 16.0)),
            ),
            _buildContactsSyncStatus(context),
          ].divide(SizedBox(height: 16.0)),
        ),
      ),
    );
  }

  Widget _buildProjectSupportCard(BuildContext context) {
    return Material(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () => showProjectShareDialog(context),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(
                    context,
                  ).primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volunteer_activism_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Помочь проекту',
                      style: FlutterFlowTheme.of(
                        context,
                      ).titleSmall.override(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      'Расскажите друзьям о Сарафане',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.chevron_right_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isAdminAccount {
    final phone = currentPhoneNumber.isNotEmpty
        ? currentPhoneNumber
        : (currentUserDocument?.phoneNumber ?? '');
    return normalizePhone(phone) == '79183633636';
  }

  Widget _buildAdminDialogsCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () => showSystemCommunicationsPreview(context),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.view_carousel_rounded,
                  color: theme.primary,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Диалоги',
                      style: theme.titleSmall.override(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      'Системные диалоги и push-сценарии',
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshProfile,
              color: FlutterFlowTheme.of(context).primary,
              child: SingleChildScrollView(
                primary: false,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          24.0,
                          32.0,
                          24.0,
                          24.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    FFAppState().specialistMode
                                        ? 'Профиль мастера'
                                        : 'Профиль клиента',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).headlineMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).headlineMedium.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).headlineMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).headlineMedium.fontStyle,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FlutterFlowIconButton(
                                      buttonSize: 40.0,
                                      icon: Icon(
                                        Icons.help_outline_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        context.pushNamed(
                                          FFAppState().specialistMode
                                              ? MasterOnboardingWidget.routeName
                                              : AppOnboardingWidget.routeName,
                                          queryParameters: {
                                            'returnToProfile': serializeParam(
                                              true,
                                              ParamType.bool,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                    ),
                                    FlutterFlowIconButton(
                                      buttonSize: 40.0,
                                      icon: FaIcon(
                                        FontAwesomeIcons.pen,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        if (FFAppState().specialistMode &&
                                            _masterProfileCompleted(
                                              currentUserDocument?.masterData,
                                            )) {
                                          context.pushNamed(
                                            EditProfileMasterWidget.routeName,
                                          );
                                        } else {
                                          context.pushNamed(
                                            EditProfileWidget.routeName,
                                          );
                                        }
                                      },
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Container(
                                    width: 80.0,
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).primary,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: AuthUserStreamWidget(
                                      builder: (context) => ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: FFAppState().specialistMode
                                              ? currentUserDocument!
                                                    .masterData
                                                    .mainPhoto
                                              : currentUserPhoto,
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 400,
                                          memCacheHeight: 400,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                            ),
                                          ),
                                          errorWidget:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Image.asset(
                                                'assets/images/error_image.png',
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AuthUserStreamWidget(
                                        builder: (context) => Text(
                                          valueOrDefault<String>(
                                            FFAppState().specialistMode
                                                ? currentUserDocument
                                                      ?.masterData
                                                      ?.title
                                                : currentUserDisplayName,
                                            'Пользователь',
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleLarge.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                fontSize: 20.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleLarge.fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                      ),
                                      AuthUserStreamWidget(
                                        builder: (context) => Text(
                                          valueOrDefault<String>(
                                            FFAppState().specialistMode
                                                ? currentUserDocument
                                                      ?.masterData
                                                      ?.descrip
                                                : valueOrDefault(
                                                    currentUserDocument?.bio,
                                                    '',
                                                  ),
                                            'Информация',
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
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
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ].divide(SizedBox(width: 24.0)),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                    ),
                    if (!_masterProfileCompleted(
                      currentUserDocument?.masterData,
                    ))
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          24.0,
                          0.0,
                          24.0,
                          0.0,
                        ),
                        child: AuthUserStreamWidget(
                          builder: (context) => InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (currentUserDocument
                                      ?.masterData
                                      .onboardingCompleted ??
                                  false) {
                                context.pushNamed(
                                  EditProfileMasterWidget.routeName,
                                  queryParameters: {
                                    'setupMode': serializeParam(
                                      true,
                                      ParamType.bool,
                                    ),
                                  }.withoutNulls,
                                );
                              } else {
                                context.pushNamed(
                                  MasterOnboardingWidget.routeName,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: FFAppState().specialistMode
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(
                                        context,
                                      ).primaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Color(0xFFDBEAFE),
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 48.0,
                                      decoration: BoxDecoration(
                                        color: FFAppState().specialistMode
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                        borderRadius: BorderRadius.circular(
                                          9999.0,
                                        ),
                                      ),
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.business_center_rounded,
                                        color: FFAppState().specialistMode
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primary
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).primaryBackground,
                                        size: 24.0,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              '1qf95kwx' /* Создать профиль мастера */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).titleSmall.fontStyle,
                                                  ),
                                                  color:
                                                      FFAppState()
                                                          .specialistMode
                                                      ? FlutterFlowTheme.of(
                                                          context,
                                                        ).primaryBackground
                                                      : FlutterFlowTheme.of(
                                                          context,
                                                        ).primary,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                          ),
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              '1inecjjt' /* Создавайте свой услуги и получ... */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font:
                                                      GoogleFonts.jetBrainsMono(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                  color:
                                                      FFAppState()
                                                          .specialistMode
                                                      ? FlutterFlowTheme.of(
                                                          context,
                                                        ).hint
                                                      : FlutterFlowTheme.of(
                                                          context,
                                                        ).secondaryText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodySmall.fontStyle,
                                                  lineHeight: 1.4,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 2.0)),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 16.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_masterProfileCompleted(
                      currentUserDocument?.masterData,
                    ))
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: AuthUserStreamWidget(
                          builder: (context) => wrapWithModel(
                            model: _model.togleModeModel,
                            updateCallback: () => safeSetState(() {}),
                            child: TogleModeWidget(onModeSelected: _selectMode),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        24.0,
                        _masterProfileCompleted(currentUserDocument?.masterData)
                            ? 0.0
                            : 24.0,
                        24.0,
                        0.0,
                      ),
                      child: _buildProjectSupportCard(context),
                    ),
                    if (_isAdminAccount)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: _buildAdminDialogsCard(context),
                      ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        0.0,
                        24.0,
                        0.0,
                        24.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24.0,
                              0.0,
                              24.0,
                              16.0,
                            ),
                            child: _buildPreferencesCard(context),
                          ),
                          if (false)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                0.0,
                                0.0,
                                2.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications_none_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 22.0,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'xeegqtsd' /* Notifications */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).bodyMedium.fontStyle,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        size: 20.0,
                                      ),
                                    ].divide(SizedBox(width: 16.0)),
                                  ),
                                ),
                              ),
                            ),
                          if (false)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                0.0,
                                0.0,
                                2.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite_border_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 22.0,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'mm6k5bsd' /* Saved Specialists */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).bodyMedium.fontStyle,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        size: 20.0,
                                      ),
                                    ].divide(SizedBox(width: 16.0)),
                                  ),
                                ),
                              ),
                            ),
                          if (false)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                0.0,
                                0.0,
                                2.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.share_outlined,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 22.0,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'qw0xsmd4' /* Invite Friends */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).bodyMedium.fontStyle,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        size: 20.0,
                                      ),
                                    ].divide(SizedBox(width: 16.0)),
                                  ),
                                ),
                              ),
                            ),
                          if (false)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                0.0,
                                0.0,
                                2.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.help_outline_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 22.0,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'm5jp3ix0' /* Support & Help */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).bodyMedium.fontStyle,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        size: 20.0,
                                      ),
                                    ].divide(SizedBox(width: 16.0)),
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: FutureBuilder<PackageInfo>(
                              future: _packageInfo,
                              builder: (context, snapshot) {
                                final packageInfo = snapshot.data;
                                return Text(
                                  packageInfo == null
                                      ? 'Версия 1.4.1, сборка 19'
                                      : 'Версия ${packageInfo.version}, сборка ${packageInfo.buildNumber}',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context).bodySmall
                                      .override(
                                        font: GoogleFonts.jetBrainsMono(
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodySmall.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodySmall.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(
                                          context,
                                        ).bodySmall.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).bodySmall.fontStyle,
                                      ),
                                );
                              },
                            ),
                          ),
                          Container(height: 24.0),
                        ],
                      ),
                    ),
                    Container(height: 32.0),
                  ].addToEnd(SizedBox(height: 100.0)),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.menuModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuWidget(currentPage: Menu.profile),
              ),
            ),
          ],
        ).animateOnActionTrigger(animationsMap['stackOnActionTriggerAnimation']!),
      ),
    );
  }
}
