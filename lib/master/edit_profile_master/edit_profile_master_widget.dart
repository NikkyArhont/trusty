import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/chat/chat_profile_sync.dart';
import '/backend/schema/structs/index.dart';
import '/components/form_label_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/upload_media/upload_media_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'edit_profile_master_model.dart';
export 'edit_profile_master_model.dart';

class EditProfileMasterWidget extends StatefulWidget {
  const EditProfileMasterWidget({super.key, this.setupMode = false});

  final bool setupMode;

  static String routeName = 'EditProfileMaster';
  static String routePath = '/editProfileMaster';

  @override
  State<EditProfileMasterWidget> createState() =>
      _EditProfileMasterWidgetState();
}

class _EditProfileMasterWidgetState extends State<EditProfileMasterWidget> {
  late EditProfileMasterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaving = false;
  bool _showValidationErrors = false;

  String _categorySortKey(CategoriesStruct category) =>
      category.titleRU.trim().toLowerCase().replaceAll('ё', 'е');

  PlaceStruct? get _selectedPlace {
    final selectedPlace = _model.initPlace;
    if (selectedPlace != null && selectedPlace.title.trim().isNotEmpty) {
      return selectedPlace;
    }

    final masterPlace = currentUserDocument?.masterData.mainAdres;
    if (masterPlace != null && masterPlace.title.trim().isNotEmpty) {
      return masterPlace;
    }

    final registrationCity = FFAppState().globalFilter.place;
    return registrationCity.title.trim().isNotEmpty ? registrationCity : null;
  }

  String get _selectedCategoryKey {
    final selectedKey = _model.initCat?.key.trim() ?? '';
    if (selectedKey.isNotEmpty) return selectedKey;
    return currentUserDocument?.masterData.initCat.trim() ?? '';
  }

  bool get _hasMasterPhoto =>
      _model.uploadedFileUrl_uploadDataPhotoMaster.isNotEmpty ||
      (currentUserDocument?.masterData.mainPhoto.trim().isNotEmpty ?? false);

  bool get _isNameMissing =>
      normalizeUserText(_model.nameTextController.text).isEmpty;
  bool get _isBioMissing =>
      normalizeUserText(_model.bioTextController.text).isEmpty;
  bool get _isPlaceMissing => _selectedPlace?.title.trim().isEmpty ?? true;
  bool get _isCategoryMissing => _selectedCategoryKey.isEmpty;

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final userReference = currentUserReference;
    final place = _selectedPlace;
    final name = normalizeUserText(_model.nameTextController.text);
    final bio = normalizeUserText(_model.bioTextController.text);
    final categoryKey = _selectedCategoryKey;

    if (userReference == null ||
        name.isEmpty ||
        bio.isEmpty ||
        (place?.title.trim().isEmpty ?? true) ||
        categoryKey.isEmpty ||
        !_hasMasterPhoto) {
      safeSetState(() => _showValidationErrors = true);
      if (categoryKey.isEmpty) {
        _model.expandableExpandableController.expanded = true;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все обязательные поля')),
      );
      return;
    }

    safeSetState(() => _isSaving = true);
    try {
      await userReference.update(
        createUserRecordData(
          masterMode: widget.setupMode ? true : null,
          masterData: createMasterDataStruct(
            title: name,
            descrip: bio,
            initCat: categoryKey,
            mainAdres: updatePlaceStruct(place, clearUnsetFields: false),
            onboardingCompleted: true,
            profileCompleted: true,
            clearUnsetFields: false,
          ),
        ),
      );
      await syncCurrentUserChatProfile(masterName: name);

      if (!mounted) return;
      if (widget.setupMode) {
        FFAppState().specialistMode = true;
        FFAppState().update(() {});
        context.goNamed(SpecialistDashboardWidget.routeName);
      } else {
        context.goNamed(UserProfileWidget.routeName);
      }
    } catch (error) {
      if (!mounted) return;
      debugPrint('Failed to save master profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить профиль. Попробуйте ещё раз'),
        ),
      );
    } finally {
      if (mounted) safeSetState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileMasterModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.initPlace = _selectedPlace;
      _model.initCat = FFAppState().presetCategory
          .where((e) => e.key == currentUserDocument?.masterData?.initCat)
          .toList()
          .firstOrNull;
      safeSetState(() {});
    });

    _model.nameTextController ??= TextEditingController(
      text: currentUserDocument?.masterData?.title,
    );
    _model.nameFocusNode ??= FocusNode();

    _model.bioTextController ??= TextEditingController(
      text: currentUserDocument?.masterData?.descrip,
    );
    _model.bioFocusNode ??= FocusNode();

    _model.expandableExpandableController = ExpandableController(
      initialExpanded: false,
    )..addListener(() => safeSetState(() {}));
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            ).getText('0xrybang' /* Профиль мастера */),
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
                        const SizedBox(width: 40.0, height: 40.0),
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
                                    color:
                                        _showValidationErrors &&
                                            !_hasMasterPhoto
                                        ? FlutterFlowTheme.of(context).error
                                        : FlutterFlowTheme.of(
                                            context,
                                          ).primaryBackground,
                                    width: 4.0,
                                  ),
                                ),
                                child: AuthUserStreamWidget(
                                  builder: (context) {
                                    final localBytes = _model.setPhpto?.bytes;
                                    final masterPhoto =
                                        currentUserDocument
                                            ?.masterData
                                            .mainPhoto
                                            .trim() ??
                                        '';

                                    return Container(
                                      width: 200.0,
                                      height: 200.0,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child:
                                          localBytes != null &&
                                              localBytes.isNotEmpty
                                          ? Image.memory(
                                              localBytes,
                                              fit: BoxFit.cover,
                                            )
                                          : masterPhoto.isNotEmpty
                                          ? Image.network(
                                              masterPhoto,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.person_rounded,
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).secondaryText,
                                                    size: 48.0,
                                                  ),
                                            )
                                          : Icon(
                                              Icons.person_rounded,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondaryText,
                                              size: 48.0,
                                            ),
                                    );
                                  },
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

                                    {
                                      safeSetState(
                                        () =>
                                            _model.isDataUploading_uploadDataPhotoMaster =
                                                true,
                                      );
                                      var selectedUploadedFiles =
                                          <FFUploadedFile>[];
                                      var selectedMedia = <SelectedFile>[];
                                      var downloadUrls = <String>[];
                                      try {
                                        selectedUploadedFiles =
                                            _model.setPhpto!.bytes!.isNotEmpty
                                            ? [_model.setPhpto!]
                                            : <FFUploadedFile>[];
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
                                        _model.isDataUploading_uploadDataPhotoMaster =
                                            false;
                                      }
                                      if (selectedUploadedFiles.length ==
                                              selectedMedia.length &&
                                          downloadUrls.length ==
                                              selectedMedia.length) {
                                        safeSetState(() {
                                          _model.uploadedLocalFile_uploadDataPhotoMaster =
                                              selectedUploadedFiles.first;
                                          _model.uploadedFileUrl_uploadDataPhotoMaster =
                                              downloadUrls.first;
                                        });
                                      } else {
                                        safeSetState(() {});
                                        return;
                                      }
                                    }

                                    await currentUserReference!.update(
                                      createUserRecordData(
                                        masterData: createMasterDataStruct(
                                          mainPhoto: _model
                                              .uploadedFileUrl_uploadDataPhotoMaster,
                                          clearUnsetFields: false,
                                        ),
                                      ),
                                    );
                                    await syncCurrentUserChatProfile(
                                      masterPhoto: _model
                                          .uploadedFileUrl_uploadDataPhotoMaster,
                                    );

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
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: _model.nameFocusNode,
                        onChanged: (_) => EasyDebounce.debounce(
                          '_model.nameTextController',
                          Duration(milliseconds: 100),
                          () => safeSetState(() {}),
                        ),
                        autofocus: false,
                        enabled: true,
                        keyboardType: TextInputType.multiline,
                        obscureText: false,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          isDense: false,
                          labelText:
                              FFLocalizations.of(
                                context,
                              ).getText('usmerrp4' /* Название */) +
                              ' *',
                          errorText: _showValidationErrors && _isNameMissing
                              ? 'Обязательное поле'
                              : null,
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
                          labelText:
                              FFLocalizations.of(
                                context,
                              ).getText('x6pqju0g' /* Описание */) +
                              ' *',
                          errorText: _showValidationErrors && _isBioMissing
                              ? 'Обязательное поле'
                              : null,
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
                  Flexible(
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'jvo3hc0r' /* Выбранный адрес и категория бу... */,
                      ),
                      maxLines: 4,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.jetBrainsMono(
                          fontWeight: FlutterFlowTheme.of(
                            context,
                          ).bodyMedium.fontWeight,
                          fontStyle: FlutterFlowTheme.of(
                            context,
                          ).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FlutterFlowTheme.of(
                          context,
                        ).bodyMedium.fontWeight,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).bodyMedium.fontStyle,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: _showValidationErrors && _isPlaceMissing
                        ? const EdgeInsets.all(8.0)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: _showValidationErrors && _isPlaceMissing
                          ? Border.all(
                              color: FlutterFlowTheme.of(context).error,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: wrapWithModel(
                              model: _model.formLabelModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: FormLabelWidget(
                                label:
                                    'Город оказания услуг *: '
                                    '${_selectedPlace?.title ?? 'не выбран'}',
                              ),
                            ),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            await context.pushNamed(
                              ChooseLocationCityWidget.routeName,
                              queryParameters: {
                                'edit': serializeParam(true, ParamType.bool),
                                'addressMode': serializeParam(
                                  false,
                                  ParamType.bool,
                                ),
                                'initialPlace': serializeParam(
                                  _selectedPlace,
                                  ParamType.DataStruct,
                                ),
                              }.withoutNulls,
                            );

                            _model.initPlace = FFAppState().globalFilter.place;
                            safeSetState(() {});
                          },
                          text: FFLocalizations.of(
                            context,
                          ).getText('v5prgqlh' /* Изменить */),
                          icon: Icon(Icons.map, size: 15.0),
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              0.0,
                              16.0,
                              0.0,
                            ),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0,
                              0.0,
                              0.0,
                              0.0,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).titleSmall.fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).titleSmall.fontStyle,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: _showValidationErrors && _isCategoryMissing
                              ? FlutterFlowTheme.of(context).error
                              : FlutterFlowTheme.of(context).divider,
                        ),
                      ),
                      child: ExpandableNotifier(
                        controller: _model.expandableExpandableController,
                        child: ExpandablePanel(
                          header: wrapWithModel(
                            model: _model.formLabelModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: FormLabelWidget(label: 'Категория *'),
                          ),
                          collapsed: Visibility(
                            visible: _model.initCat != null,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.radio_button_checked,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 24.0,
                                ),
                                Flexible(
                                  child: Text(
                                    valueOrDefault<String>(
                                      _model.initCat?.titleRU,
                                      'Без названия',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
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
                                          ).primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                          ),
                          expanded: Builder(
                            builder: (context) {
                              final presetCat =
                                  FFAppState().presetCategory.toList()..sort(
                                    (first, second) => _categorySortKey(
                                      first,
                                    ).compareTo(_categorySortKey(second)),
                                  );

                              return Column(
                                children: List.generate(presetCat.length, (
                                  presetCatIndex,
                                ) {
                                  final presetCatItem =
                                      presetCat[presetCatIndex];
                                  final isSelectedCategory =
                                      presetCatItem.key == _model.initCat?.key;
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      _model.initCat = presetCatItem;
                                      safeSetState(() {});
                                      _model.expandableExpandableController
                                          .toggle();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        if (!isSelectedCategory)
                                          Icon(
                                            Icons.circle_outlined,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                            size: 24.0,
                                          ),
                                        if (isSelectedCategory)
                                          Icon(
                                            Icons.radio_button_checked,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                            size: 24.0,
                                          ),
                                        Flexible(
                                          child: Text(
                                            presetCatItem.titleRU,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font:
                                                      GoogleFonts.jetBrainsMono(
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
                                                  ).primaryText,
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  );
                                }).divide(SizedBox(height: 8.0)),
                              );
                            },
                          ),
                          theme: ExpandableThemeData(
                            tapHeaderToExpand: true,
                            tapBodyToExpand: false,
                            tapBodyToCollapse: false,
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            hasIcon: true,
                            iconColor: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AuthUserStreamWidget(
                    builder: (context) => FFButtonWidget(
                      onPressed: _isSaving ? null : _saveProfile,
                      text: FFLocalizations.of(
                        context,
                      ).getText('4fyt8tg9' /* Сохранить */),
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                          16.0,
                          0.0,
                          16.0,
                          0.0,
                        ),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          0.0,
                        ),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleSmall
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FlutterFlowTheme.of(
                                  context,
                                ).titleSmall.fontWeight,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleSmall.fontStyle,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(
                                context,
                              ).titleSmall.fontWeight,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).titleSmall.fontStyle,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
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
