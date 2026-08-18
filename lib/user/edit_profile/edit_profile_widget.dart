import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/chat/chat_profile_sync.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/upload_media/upload_media_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'edit_profile_model.dart';
export 'edit_profile_model.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget>
    with TickerProviderStateMixin {
  late EditProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};
  Future<Map<String, dynamic>>? _adminStatsFuture;
  bool _isSaving = false;
  bool _isDeletingAccount = false;
  bool _isSigningOut = false;

  bool get _canViewAdminStats => currentPhoneNumber == '+79183633636';

  Future<NavigatorState> _showBlockingProgress({
    required String title,
    required String message,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    unawaited(
      showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: Row(
              children: [
                CircularProgressIndicator(
                  color: FlutterFlowTheme.of(dialogContext).primary,
                ),
                Expanded(child: Text(message)),
              ].divide(const SizedBox(width: 20.0)),
            ),
          ),
        ),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    return navigator;
  }

  Future<NavigatorState>
  _showAccountDeletionProgress() => _showBlockingProgress(
    title: 'Удаляем аккаунт',
    message:
        'Пожалуйста, подождите. Не закрывайте приложение, пока удаление не завершится.',
  );

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text(
          'Профиль, услуги, записи, чаты и загруженные файлы будут удалены без возможности восстановления.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
            child: const Text('Удалить навсегда'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    safeSetState(() => _isDeletingAccount = true);
    final deletionProgressNavigator = await _showAccountDeletionProgress();
    var accountDeleted = false;
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (token == null || token.isEmpty) {
        throw Exception('Нет токена авторизации');
      }
      final response = await http
          .post(
            Uri.parse(
              'https://us-central1-trusty-kzh1sb.cloudfunctions.net/deleteAccount',
            ),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(data['details'] ?? data['error'] ?? 'Ошибка удаления');
      }
      accountDeleted = true;
    } catch (error) {
      debugPrint('Account deletion failed: $error');
    } finally {
      if (deletionProgressNavigator.mounted &&
          deletionProgressNavigator.canPop()) {
        deletionProgressNavigator.pop();
      }
      if (mounted) safeSetState(() => _isDeletingAccount = false);
    }

    if (!mounted) return;
    if (!accountDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось удалить аккаунт. Попробуйте ещё раз.'),
        ),
      );
      return;
    }

    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    if (!mounted) return;
    GoRouter.of(context).clearRedirectLocation();
    context.goNamedAuth(LoginWidget.routeName, mounted);
  }

  Future<Map<String, dynamic>> _loadAdminStats() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Нет токена авторизации');
    }

    final response = await http
        .get(
          Uri.parse(
            'https://us-central1-trusty-kzh1sb.cloudfunctions.net/getAdminStats',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['details'] ?? data['error'] ?? 'Ошибка статистики');
    }

    return data;
  }

  Future<void> _saveProfile() async {
    final name = normalizeUserText(_model.nameTextController.text);
    if (name.isEmpty || _isSaving) return;

    final userReference = currentUserReference;
    if (userReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось определить пользователя')),
      );
      return;
    }

    safeSetState(() => _isSaving = true);
    try {
      final bio = normalizeUserText(_model.bioTextController.text);
      if (kIsWeb) {
        await _saveWebProfile(name: name, bio: bio);
      } else {
        await userReference.update(
          createUserRecordData(displayName: name, bio: bio),
        );
        await syncCurrentUserChatProfile(displayName: name);
      }

      if (mounted) context.goNamed(UserProfileWidget.routeName);
    } catch (error) {
      if (!mounted) return;
      debugPrint('Failed to save client profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить профиль. Попробуйте ещё раз'),
        ),
      );
    } finally {
      if (mounted) safeSetState(() => _isSaving = false);
    }
  }

  Future<void> _saveWebProfile({
    required String name,
    required String bio,
  }) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userReference = currentUserReference;
    final token = await firebaseUser?.getIdToken();
    if (firebaseUser == null || userReference == null || token == null) {
      throw Exception('Пользователь не авторизован');
    }

    final documentUrl = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/trusty-kzh1sb/'
      'databases/(default)/documents/user/${firebaseUser.uid}'
      '?updateMask.fieldPaths=display_name&updateMask.fieldPaths=bio',
    );
    final response = await http.patch(
      documentUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fields': {
          'display_name': {'stringValue': name},
          'bio': {'stringValue': bio},
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Firestore REST ${response.statusCode}: ${response.body}',
      );
    }

    final cachedUser = currentUserDocument;
    if (cachedUser != null) {
      final updatedData = Map<String, dynamic>.from(cachedUser.snapshotData)
        ..['display_name'] = name
        ..['bio'] = bio;
      currentUserDocument = UserRecord.getDocumentFromData(
        updatedData,
        userReference,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileModel());

    _model.nameTextController ??= TextEditingController(
      text: currentUserDisplayName,
    );
    _model.nameFocusNode ??= FocusNode();

    _model.bioTextController ??= TextEditingController(
      text: valueOrDefault(currentUserDocument?.bio, ''),
    );
    _model.bioFocusNode ??= FocusNode();

    if (_canViewAdminStats) {
      _adminStatsFuture = _loadAdminStats();
    }

    animationsMap.addAll({});
    setupAnimations(
      animationsMap.values.where(
        (anim) =>
            anim.trigger == AnimationTrigger.onActionTrigger ||
            !anim.applyInitialState,
      ),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildAdminStatsCard() {
    if (!_canViewAdminStats || _adminStatsFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _adminStatsFuture,
      builder: (context, snapshot) {
        String usersTotal = '...';
        String usersOnline = '...';
        String servicesTotal = '...';

        if (snapshot.hasData) {
          usersTotal = '${snapshot.data?['usersTotal'] ?? 0}';
          usersOnline = '${snapshot.data?['usersOnline'] ?? 0}';
          servicesTotal = '${snapshot.data?['servicesTotal'] ?? 0}';
        }

        return Container(
          width: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Статистика',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w700,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (snapshot.hasError)
                  Text(
                    'Не удалось загрузить статистику',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.jetBrainsMono(),
                      color: FlutterFlowTheme.of(context).error,
                      letterSpacing: 0.0,
                    ),
                  )
                else ...[
                  Text(
                    'Всего пользователей: $usersTotal',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.jetBrainsMono(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                  Text(
                    'Онлайн сейчас: $usersOnline',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.jetBrainsMono(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                  Text(
                    'Всего объявлений: $servicesTotal',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.jetBrainsMono(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ].divide(SizedBox(height: 8.0)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Container(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
            child: SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        wrapWithModel(
                          model: _model.navBackModel,
                          updateCallback: () => safeSetState(() {}),
                          child: NavBackWidget(),
                        ),
                        Expanded(
                          child: Text(
                            FFLocalizations.of(
                              context,
                            ).getText('pf0e32i2' /* Редактировать */),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).headlineMedium
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
                        FlutterFlowIconButton(
                          borderColor: FlutterFlowTheme.of(
                            context,
                          ).secondaryText,
                          borderRadius: 12.0,
                          buttonSize: 40.0,
                          disabledIconColor: FlutterFlowTheme.of(
                            context,
                          ).secondaryText,
                          icon: Icon(
                            Icons.save,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed:
                              _model.nameTextController.text.trim().isEmpty ||
                                  _isSaving
                              ? null
                              : _saveProfile,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 120.0,
                    height: 120.0,
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Container(
                        height: 120.0,
                        child: Stack(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          children: [
                            ClipOval(
                              child: Container(
                                width: 120.0,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(0.0, 2.0),
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    width: 4.0,
                                  ),
                                ),
                                child: AuthUserStreamWidget(
                                  builder: (context) => Container(
                                    width: 200.0,
                                    height: 200.0,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        _model
                                                .uploadedLocalFile_uploadDataWg9
                                                .bytes
                                                ?.isNotEmpty ==
                                            true
                                        ? Image.memory(
                                            _model
                                                .uploadedLocalFile_uploadDataWg9
                                                .bytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            currentUserPhoto,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              child: Container(
                                width: 36.0,
                                height: 36.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(0.0, 1.0),
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(9999.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    width: 3.0,
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: MediaQuery.viewInsetsOf(
                                            context,
                                          ),
                                          child: UploadMediaWidget(
                                            maxOutputSize: 640,
                                          ),
                                        );
                                      },
                                    ).then(
                                      (value) => safeSetState(
                                        () => _model.setPhpto = value,
                                      ),
                                    );

                                    final pickedPhoto = _model.setPhpto;
                                    if (pickedPhoto?.bytes == null ||
                                        pickedPhoto!.bytes!.isEmpty) {
                                      return;
                                    }

                                    final previousPhotoUrl =
                                        currentUserDocument?.photoUrl ?? '';

                                    {
                                      safeSetState(
                                        () =>
                                            _model.isDataUploading_uploadDataWg9 =
                                                true,
                                      );
                                      var selectedUploadedFiles =
                                          <FFUploadedFile>[];
                                      var selectedMedia = <SelectedFile>[];
                                      var downloadUrls = <String>[];
                                      try {
                                        selectedUploadedFiles = [pickedPhoto];
                                        selectedMedia =
                                            selectedFilesFromUploadedFiles(
                                              selectedUploadedFiles,
                                            );
                                        downloadUrls =
                                            (await Future.wait(
                                                  selectedMedia.map(
                                                    (m) async =>
                                                        await uploadData(
                                                          m.storagePath,
                                                          m.bytes,
                                                        ),
                                                  ),
                                                ))
                                                .where((u) => u != null)
                                                .map((u) => u!)
                                                .toList();
                                      } finally {
                                        _model.isDataUploading_uploadDataWg9 =
                                            false;
                                      }
                                      if (selectedUploadedFiles.length ==
                                              selectedMedia.length &&
                                          downloadUrls.length ==
                                              selectedMedia.length) {
                                        safeSetState(() {
                                          _model.uploadedLocalFile_uploadDataWg9 =
                                              selectedUploadedFiles.first;
                                          _model.uploadedFileUrl_uploadDataWg9 =
                                              downloadUrls.first;
                                        });
                                      } else {
                                        safeSetState(() {});
                                        return;
                                      }
                                    }

                                    await currentUserReference!.update(
                                      createUserRecordData(
                                        photoUrl: _model
                                            .uploadedFileUrl_uploadDataWg9,
                                      ),
                                    );
                                    await syncCurrentUserChatProfile(
                                      photoUrl:
                                          _model.uploadedFileUrl_uploadDataWg9,
                                    );

                                    if (previousPhotoUrl.isNotEmpty &&
                                        previousPhotoUrl !=
                                            _model
                                                .uploadedFileUrl_uploadDataWg9) {
                                      try {
                                        await FirebaseStorage.instance
                                            .refFromURL(previousPhotoUrl)
                                            .delete();
                                      } catch (_) {}
                                    }

                                    safeSetState(() {});
                                  },
                                  child: Icon(
                                    Icons.photo_camera_rounded,
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    size: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AuthUserStreamWidget(
                    builder: (context) => Text(
                      currentPhoneNumber,
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
                  ),
                  AuthUserStreamWidget(
                    builder: (context) => Container(
                      width: 400.0,
                      child: TextFormField(
                        controller: _model.nameTextController,
                        textCapitalization: TextCapitalization.words,
                        focusNode: _model.nameFocusNode,
                        onChanged: (_) => EasyDebounce.debounce(
                          '_model.nameTextController',
                          Duration(milliseconds: 100),
                          () => safeSetState(() {}),
                        ),
                        autofocus: false,
                        enabled: true,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: false,
                          labelText: FFLocalizations.of(
                            context,
                          ).getText('8dhm9ity' /* Имя */),
                          labelStyle: FlutterFlowTheme.of(context).labelMedium
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
                          hintStyle: FlutterFlowTheme.of(context).labelMedium
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
                          fillColor: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                        maxLength: 50,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                        enableInteractiveSelection: true,
                        validator: _model.nameTextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                  ),
                  AuthUserStreamWidget(
                    builder: (context) => Container(
                      width: 400.0,
                      child: TextFormField(
                        controller: _model.bioTextController,
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: _model.bioFocusNode,
                        onChanged: (_) => EasyDebounce.debounce(
                          '_model.bioTextController',
                          Duration(milliseconds: 100),
                          () => safeSetState(() {}),
                        ),
                        autofocus: false,
                        enabled: true,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: false,
                          labelText: FFLocalizations.of(
                            context,
                          ).getText('hdt8ivaj' /* О себе */),
                          labelStyle: FlutterFlowTheme.of(context).labelMedium
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
                          hintStyle: FlutterFlowTheme.of(context).labelMedium
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
                          fillColor: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          prefixIcon: Icon(Icons.text_snippet),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: null,
                        maxLength: 200,
                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                        enableInteractiveSelection: true,
                        validator: _model.bioTextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          16.0,
                        ),
                        child: Text(
                          FFLocalizations.of(
                            context,
                          ).getText('2xjjlkj0' /* Управление аккаунтом */),
                          style: FlutterFlowTheme.of(context).labelLarge
                              .override(
                                font: GoogleFonts.jetBrainsMono(
                                  fontWeight: FlutterFlowTheme.of(
                                    context,
                                  ).labelLarge.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).labelLarge.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(
                                  context,
                                ).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(
                                  context,
                                ).labelLarge.fontWeight,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).labelLarge.fontStyle,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          8.0,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          onTap: () {
                            context.pushNamed(VisitHistoryWidget.routeName);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).divider,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    size: 22.0,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('z5v9zc0a' /* Visit History */),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            font: GoogleFonts.jetBrainsMono(
                                              fontWeight: FlutterFlowTheme.of(
                                                context,
                                              ).bodyLarge.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyLarge.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).bodyLarge.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyLarge.fontStyle,
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
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          8.0,
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(16.0),
                          onTap: _isSigningOut || _isDeletingAccount
                              ? null
                              : () async {
                                  final confirmSignOut =
                                      await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) {
                                          return AlertDialog(
                                            backgroundColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            title: Text(
                                              'Выйти из аккаунта?',
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).titleLarge.override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .titleLarge
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryText,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).titleLarge.fontStyle,
                                                  ),
                                            ),
                                            content: Text(
                                              'Вы уверены, что хотите выйти из аккаунта?',
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodyMedium.override(
                                                    font: GoogleFonts.jetBrainsMono(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).secondaryText,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).bodyMedium.fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).bodyMedium.fontStyle,
                                                  ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  false,
                                                ),
                                                child: Text(
                                                  'Отмена',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelLarge.override(
                                                        font: GoogleFonts.jetBrainsMono(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).secondaryText,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).error,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.0,
                                                        ),
                                                  ),
                                                  padding:
                                                      EdgeInsetsDirectional.fromSTEB(
                                                        20.0,
                                                        10.0,
                                                        20.0,
                                                        10.0,
                                                      ),
                                                ),
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  true,
                                                ),
                                                child: Text(
                                                  'Выйти',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelLarge.override(
                                                        font: GoogleFonts.jetBrainsMono(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).info,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                      false;

                                  if (!confirmSignOut) {
                                    return;
                                  }
                                  if (!context.mounted) {
                                    return;
                                  }

                                  safeSetState(() => _isSigningOut = true);
                                  GoRouter.of(context).prepareAuthEvent();
                                  final signOutProgressNavigator =
                                      await _showBlockingProgress(
                                        title: 'Выходим из аккаунта',
                                        message:
                                            'Пожалуйста, подождите. Выход из аккаунта выполняется.',
                                      );
                                  var signedOut = false;
                                  try {
                                    await authManager.signOut();
                                    signedOut = true;
                                  } catch (error) {
                                    debugPrint('Sign out failed: $error');
                                  } finally {
                                    if (signOutProgressNavigator.mounted &&
                                        signOutProgressNavigator.canPop()) {
                                      signOutProgressNavigator.pop();
                                    }
                                    if (mounted) {
                                      safeSetState(() => _isSigningOut = false);
                                    }
                                  }

                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (!signedOut) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Не удалось выйти из аккаунта. Попробуйте ещё раз.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  GoRouter.of(context).clearRedirectLocation();
                                  context.goNamedAuth('Login', context.mounted);
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).divider,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    size: 22.0,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('1yguwjbh' /* Выйти */),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            font: GoogleFonts.jetBrainsMono(
                                              fontWeight: FlutterFlowTheme.of(
                                                context,
                                              ).bodyLarge.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyLarge.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).bodyLarge.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyLarge.fontStyle,
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
                      ),
                      Container(height: 24.0),
                      _buildAdminStatsCard(),
                      if (_canViewAdminStats) Container(height: 24.0),
                      InkWell(
                        onTap: _isDeletingAccount ? null : _deleteAccount,
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Color(0xFFFEE2E2),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: FlutterFlowTheme.of(context).error,
                                  size: 22.0,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'z7rso59u' /* Удалить аккаунт */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              font: GoogleFonts.jetBrainsMono(
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).bodyLarge.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyLarge.fontStyle,
                                            ),
                                      ),
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'hiy7hqd5' /* Это действие нельзя отменить */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
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
                                              ).error,
                                              letterSpacing: 0.0,
                                              fontWeight: FlutterFlowTheme.of(
                                                context,
                                              ).bodySmall.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodySmall.fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isDeletingAccount)
                                  SizedBox(
                                    width: 18.0,
                                    height: 18.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: FlutterFlowTheme.of(context).error,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: FlutterFlowTheme.of(context).error,
                                    size: 14.0,
                                  ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ].divide(SizedBox(height: 32.0)).addToStart(SizedBox(height: 24.0)).addToEnd(SizedBox(height: 120.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
