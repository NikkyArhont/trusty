import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/form_label_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/global_comp/upload_media/upload_media_widget.dart';
import '/master/del_serv/del_serv_widget.dart';
import '/master/save_serv_change/save_serv_change_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'edit_service_model.dart';
export 'edit_service_model.dart';

class EditServiceWidget extends StatefulWidget {
  const EditServiceWidget({super.key, this.servDoc});

  final ServiceRecord? servDoc;

  static String routeName = 'editService';
  static String routePath = '/editService';

  @override
  State<EditServiceWidget> createState() => _EditServiceWidgetState();
}

class _EditServiceWidgetState extends State<EditServiceWidget> {
  late EditServiceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _removedImageUrls = <String>{};
  String _durationUnit = 'min';

  List<String> get _remainingExistingImageUrls =>
      (widget.servDoc?.image ?? const <String>[])
          .where((url) => !_removedImageUrls.contains(url))
          .toList();

  bool get _hasImageForSave =>
      _remainingExistingImageUrls.isNotEmpty || _model.uploadPhoto.isNotEmpty;

  String _categorySortKey(CategoriesStruct category) =>
      category.titleRU.trim().toLowerCase().replaceAll('ё', 'е');

  void _stageExistingImageRemoval(String imageUrl) {
    safeSetState(() => _removedImageUrls.add(imageUrl));
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Фото будет удалено после сохранения'),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () {
              if (mounted) {
                safeSetState(() => _removedImageUrls.remove(imageUrl));
              }
            },
          ),
        ),
      );
  }

  Future<void> _pickServiceImage() async {
    final selectedImage = await showModalBottomSheet<FFUploadedFile>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: const UploadMediaWidget(),
        );
      },
    );
    if (!mounted || selectedImage == null) return;

    _model.newImage = selectedImage;
    _model.addToUploadPhoto(selectedImage);
    safeSetState(() {});
  }

  Future<void> _openImagePreview(WidgetBuilder imageBuilder) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 140),
        pageBuilder: (routeContext, animation, secondaryAnimation) => Material(
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: SizedBox.expand(child: imageBuilder(routeContext)),
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.of(routeContext).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 32.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  PlaceStruct? _masterCity() {
    final masterData = currentUserDocument?.masterData;
    if (masterData == null || !masterData.hasMainAdres()) {
      return null;
    }
    final place = masterData.mainAdres;
    if (place.title.trim().isEmpty) {
      return null;
    }
    return place;
  }

  PlaceStruct? _serviceCity() {
    final selectedPlace = FFAppState().globalFilter.place;
    if (selectedPlace.title.trim().isNotEmpty) {
      return selectedPlace;
    }
    return _masterCity();
  }

  Future<void> _openAddressPicker() async {
    FFAppState().tempServiceAddress = null;
    await context.pushNamed(
      ChooseLocationCityWidget.routeName,
      queryParameters: {
        'edit': serializeParam(true, ParamType.bool),
        'addressMode': serializeParam(true, ParamType.bool),
        'initialPlace': serializeParam(_serviceCity(), ParamType.DataStruct),
      }.withoutNulls,
    );
    if (FFAppState().tempServiceAddress != null) {
      _model.adres = FFAppState().tempServiceAddress;
      _model.presetAdres = null;
      _model.textController2?.text =
          FFAppState().tempServiceAddress?.title ?? '';
      FFAppState().tempServiceAddress = null;
      safeSetState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditServiceModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.servDoc != null) {
        _model.adres = widget!.servDoc?.place;
        _model.textController2?.text = _model.adres?.title ?? '';
        safeSetState(() {});
      } else {
        _model.adres = currentUserDocument?.masterData?.mainAdres;
        _model.textController2?.text = _model.adres?.title ?? '';
        final masterCity = _masterCity();
        if (masterCity != null) {
          FFAppState().updateGlobalFilterStruct((e) => e..place = masterCity);
        }
        safeSetState(() {});
      }

      final initialCategoryKey = widget.servDoc?.categoryKey.isNotEmpty == true
          ? widget.servDoc!.categoryKey
          : currentUserDocument?.masterData?.initCat;
      _model.choosenCat = FFAppState().presetCategory
          .where((e) => e.key == initialCategoryKey)
          .toList()
          .firstOrNull;
      safeSetState(() {});
    });

    _model.textController1 ??= TextEditingController(
      text: widget!.servDoc?.title,
    );
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.switchValue1 = !_model.onCity;
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController(
      text: widget!.servDoc?.description,
    );
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.expandableExpandableController = ExpandableController(
      initialExpanded: false,
    )..addListener(() => safeSetState(() {}));
    _model.textController4 ??= TextEditingController(
      text: widget.servDoc?.hasPrice() == true
          ? widget.servDoc!.price.toString()
          : null,
    );
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController(
      text: widget.servDoc?.hasTime() == true
          ? widget.servDoc!.time.toString()
          : null,
    );
    _durationUnit = widget.servDoc?.timeUnit ?? 'min';
    _model.textFieldFocusNode5 ??= FocusNode();

    _model.switchValue2 = true;
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
      body: Stack(
        children: [
          SafeArea(
            top: true,
            child: SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).divider,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        24.0,
                        16.0,
                        24.0,
                        16.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            buttonSize: 40.0,
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.safePop();
                            },
                          ),
                          Expanded(
                            child: Text(
                              widget!.servDoc != null
                                  ? 'Редактировать'
                                  : 'Создать',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).titleLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).titleLarge.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).titleLarge.fontStyle,
                                    lineHeight: 1.3,
                                  ),
                            ),
                          ),
                          Container(width: 40.0),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              16.0,
                              0.0,
                              0.0,
                            ),
                            child: wrapWithModel(
                              model: _model.formLabelModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: FormLabelWidget(
                                label: 'Изображения (минимум 1, максимум 5)',
                                requiredIndicatorColor: _hasImageForSave
                                    ? FlutterFlowTheme.of(context).primaryText
                                    : FlutterFlowTheme.of(context).error,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (_remainingExistingImageUrls.length +
                                        _model.uploadPhoto.length <
                                    5)
                                  InkWell(
                                    onTap: _pickServiceImage,
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Container(
                                      width: 140.0,
                                      height: 140.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).divider,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional(
                                              0.0,
                                              0.0,
                                            ),
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).info,
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          if (_remainingExistingImageUrls
                                                      .length +
                                                  _model.uploadPhoto.length ==
                                              0)
                                            PositionedDirectional(
                                              top: 8.0,
                                              end: 10.0,
                                              child: Text(
                                                '*',
                                                style:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).titleLarge.override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).error,
                                                      fontSize: 24.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_model.uploadPhoto.isNotEmpty)
                                  Builder(
                                    builder: (context) {
                                      final images = _model.uploadPhoto
                                          .toList();

                                      return Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(images.length, (
                                          imagesIndex,
                                        ) {
                                          final imagesItem =
                                              images[imagesIndex];
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            child: Container(
                                              width: 140.0,
                                              height: 140.0,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).divider,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTap: () =>
                                                          _openImagePreview(
                                                            (
                                                              context,
                                                            ) => Image.memory(
                                                              imagesItem
                                                                      .bytes ??
                                                                  Uint8List.fromList(
                                                                    [],
                                                                  ),
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                      child: Image.memory(
                                                        imagesItem.bytes ??
                                                            Uint8List.fromList(
                                                              [],
                                                            ),
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                          1.0,
                                                          -1.0,
                                                        ),
                                                    child: Container(
                                                      alignment:
                                                          AlignmentDirectional(
                                                            -1.0,
                                                            -1.0,
                                                          ),
                                                      child: Visibility(
                                                        visible:
                                                            imagesIndex == 0,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                4.0,
                                                              ),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).info,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    9999.0,
                                                                  ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    4.0,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .star_rounded,
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).primary,
                                                                size: 14.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                          1.0,
                                                          -1.0,
                                                        ),
                                                    child: Container(
                                                      decoration:
                                                          BoxDecoration(),
                                                      alignment:
                                                          AlignmentDirectional(
                                                            1.0,
                                                            -1.0,
                                                          ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          4.0,
                                                        ),
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model
                                                                .removeFromUploadPhoto(
                                                                  imagesItem,
                                                                );
                                                            safeSetState(() {});
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).info,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    9999.0,
                                                                  ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    4.0,
                                                                  ),
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () async {
                                                                  _model.removeFromUploadPhoto(
                                                                    imagesItem,
                                                                  );
                                                                  safeSetState(
                                                                    () {},
                                                                  );
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .close_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                    context,
                                                                  ).primaryText,
                                                                  size: 14.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).divide(SizedBox(width: 16.0)),
                                      );
                                    },
                                  ),
                                if (_remainingExistingImageUrls.isNotEmpty)
                                  Builder(
                                    builder: (context) {
                                      final imagesInserv =
                                          _remainingExistingImageUrls;

                                      return Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(imagesInserv.length, (
                                          imagesInservIndex,
                                        ) {
                                          final imagesInservItem =
                                              imagesInserv[imagesInservIndex];
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            child: Container(
                                              width: 140.0,
                                              height: 140.0,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).divider,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTap: () => _openImagePreview(
                                                        (
                                                          context,
                                                        ) => CachedNetworkImage(
                                                          imageUrl:
                                                              imagesInservItem,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            Duration(
                                                              milliseconds: 0,
                                                            ),
                                                        fadeOutDuration:
                                                            Duration(
                                                              milliseconds: 0,
                                                            ),
                                                        imageUrl:
                                                            imagesInservItem,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                          1.0,
                                                          -1.0,
                                                        ),
                                                    child: Container(
                                                      alignment:
                                                          AlignmentDirectional(
                                                            -1.0,
                                                            -1.0,
                                                          ),
                                                      child: Visibility(
                                                        visible:
                                                            imagesInservIndex ==
                                                            0,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                4.0,
                                                              ),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).info,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    9999.0,
                                                                  ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    4.0,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .star_rounded,
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).primary,
                                                                size: 14.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                          1.0,
                                                          -1.0,
                                                        ),
                                                    child: Container(
                                                      decoration:
                                                          BoxDecoration(),
                                                      alignment:
                                                          AlignmentDirectional(
                                                            1.0,
                                                            -1.0,
                                                          ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          4.0,
                                                        ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).info,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  9999.0,
                                                                ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  4.0,
                                                                ),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _stageExistingImageRemoval(
                                                                  imagesInservItem,
                                                                );
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .close_rounded,
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).primaryText,
                                                                size: 14.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).divide(SizedBox(width: 16.0)),
                                      );
                                    },
                                  ),
                              ].divide(SizedBox(width: 16.0)).addToStart(SizedBox(width: 16.0)).addToEnd(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            16.0,
                            0.0,
                            16.0,
                            0.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).divider,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      wrapWithModel(
                                        model: _model.formLabelModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: FormLabelWidget(
                                          label: 'Заголовок',
                                          requiredIndicatorColor:
                                              _model.textController1.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText
                                              : FlutterFlowTheme.of(
                                                  context,
                                                ).error,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _model.textController1,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        focusNode: _model.textFieldFocusNode1,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.textController1',
                                          Duration(milliseconds: 100),
                                          () => safeSetState(() {}),
                                        ),
                                        autofocus: false,
                                        enabled: true,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: false,
                                          labelStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelMedium.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
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
                                          hintText: FFLocalizations.of(context)
                                              .getText(
                                                '2pk8dxf8' /* Например: массаж */,
                                              ),
                                          hintStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelMedium.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
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
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondary,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                          filled: true,
                                          fillColor: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
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
                                              letterSpacing: 0.0,
                                              fontWeight: FlutterFlowTheme.of(
                                                context,
                                              ).bodyMedium.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyMedium.fontStyle,
                                            ),
                                        maxLength: 50,
                                        cursorColor: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        enableInteractiveSelection: true,
                                        validator: _model
                                            .textController1Validator
                                            .asValidator(context),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Align(
                                          alignment: AlignmentDirectional(
                                            -1.0,
                                            0.0,
                                          ),
                                          child: wrapWithModel(
                                            model: _model.formLabelModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: FormLabelWidget(
                                              label:
                                                  'Город оказания услуг: ${_serviceCity()?.title ?? 'не указан'}',
                                              requiredIndicatorColor:
                                                  _serviceCity() != null
                                                  ? FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryText
                                                  : FlutterFlowTheme.of(
                                                      context,
                                                    ).error,
                                            ),
                                          ),
                                        ),
                                      ),
                                      FFButtonWidget(
                                        onPressed: () async {
                                          await context.pushNamed(
                                            ChooseLocationCityWidget.routeName,
                                            queryParameters: {
                                              'edit': serializeParam(
                                                true,
                                                ParamType.bool,
                                              ),
                                              'addressMode': serializeParam(
                                                false,
                                                ParamType.bool,
                                              ),
                                              'initialPlace': serializeParam(
                                                widget.servDoc?.place.title
                                                            .trim()
                                                            .isNotEmpty ==
                                                        true
                                                    ? widget.servDoc!.place
                                                    : _serviceCity(),
                                                ParamType.DataStruct,
                                              ),
                                            }.withoutNulls,
                                          );
                                          safeSetState(() {});
                                        },
                                        text: FFLocalizations.of(
                                          context,
                                        ).getText('vy2pxy4r' /* Изменить */),
                                        icon: Icon(Icons.map, size: 15.0),
                                        options: FFButtonOptions(
                                          height: 40.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                16.0,
                                                0.0,
                                                16.0,
                                                0.0,
                                              ),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                0.0,
                                                0.0,
                                                0.0,
                                                0.0,
                                              ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primary,
                                          textStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).titleSmall.override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
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
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 8.0)),
                                  ),
                                  Text(
                                    _masterCity() != null
                                        ? 'Город мастера указан: ${_masterCity()!.title}'
                                        : (_serviceCity() != null
                                              ? 'Город мастера не указан. Для услуги выбран: ${_serviceCity()!.title}'
                                              : 'Город мастера не указан. Выберите город перед созданием услуги.'),
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
                                          color: _serviceCity() != null
                                              ? FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText
                                              : FlutterFlowTheme.of(
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
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 5,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: AlignmentDirectional(
                                            -1.0,
                                            0.0,
                                          ),
                                          child: wrapWithModel(
                                            model: _model.formLabelModel4,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: FormLabelWidget(
                                              label: 'Оказываю услуги по',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryBackground,
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(4.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    _ServiceLocationTabButton(
                                                      label: 'Городу',
                                                      selected: _model.onCity,
                                                      onTap: () {
                                                        safeSetState(() {
                                                          _model.onCity = true;
                                                          _model.switchValue1 =
                                                              false;
                                                        });
                                                      },
                                                    ),
                                              ),
                                              Expanded(
                                                child:
                                                    _ServiceLocationTabButton(
                                                      label: 'Адресу',
                                                      selected: !_model.onCity,
                                                      onTap: () {
                                                        safeSetState(() {
                                                          _model.onCity = false;
                                                          _model.switchValue1 =
                                                              true;
                                                        });
                                                      },
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 8.0)),
                                  ),
                                  if (!_model.onCity)
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        wrapWithModel(
                                          model: _model.formLabelModel5,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: FormLabelWidget(
                                            label: 'Адрес оказания услуги',
                                            requiredIndicatorColor:
                                                _model.adres != null
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primaryText
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width:
                                                    MediaQuery.sizeOf(
                                                      context,
                                                    ).width *
                                                    1.0,
                                                child: TextFormField(
                                                  controller:
                                                      _model.textController2,
                                                  focusNode: _model
                                                      .textFieldFocusNode2,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                        '_model.textController2',
                                                        Duration(
                                                          milliseconds: 100,
                                                        ),
                                                        () =>
                                                            safeSetState(() {}),
                                                      ),
                                                  autofocus: false,
                                                  enabled: true,
                                                  readOnly: true,
                                                  onTap: _openAddressPicker,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: false,
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.override(
                                                          font: GoogleFonts.jetBrainsMono(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintText:
                                                        'Нажмите, чтобы выбрать адрес',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.override(
                                                          font: GoogleFonts.jetBrainsMono(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).secondary,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primary,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).error,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.0,
                                                              ),
                                                        ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).secondaryBackground,
                                                    suffixIcon:
                                                        _model
                                                            .textController2!
                                                            .text
                                                            .isNotEmpty
                                                        ? InkWell(
                                                            onTap: () async {
                                                              _model
                                                                  .textController2
                                                                  ?.clear();
                                                              _model.adres =
                                                                  null;
                                                              _model.presetAdres =
                                                                  null;
                                                              safeSetState(
                                                                () {},
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.clear,
                                                              size: 22,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
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
                                                        letterSpacing: 0.0,
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
                                                  minLines: 1,
                                                  maxLines: 2,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .textController2Validator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        ),
                                      ],
                                    ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      wrapWithModel(
                                        model: _model.formLabelModel6,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: FormLabelWidget(
                                          label: 'Короткое описание',
                                          requiredIndicatorColor:
                                              _model.textController3.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText
                                              : FlutterFlowTheme.of(
                                                  context,
                                                ).error,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _model.textController3,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        focusNode: _model.textFieldFocusNode3,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.textController3',
                                          Duration(milliseconds: 100),
                                          () => safeSetState(() {}),
                                        ),
                                        autofocus: false,
                                        enabled: true,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: false,
                                          labelStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelMedium.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
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
                                          hintText: FFLocalizations.of(context)
                                              .getText(
                                                't2ke2vuu' /* Например: спины, шеи и пр. */,
                                              ),
                                          hintStyle:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelMedium.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
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
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondary,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                          filled: true,
                                          fillColor: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
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
                                              letterSpacing: 0.0,
                                              fontWeight: FlutterFlowTheme.of(
                                                context,
                                              ).bodyMedium.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyMedium.fontStyle,
                                            ),
                                        maxLines: 10,
                                        minLines: 1,
                                        maxLength: 300,
                                        cursorColor: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        enableInteractiveSelection: true,
                                        validator: _model
                                            .textController3Validator
                                            .asValidator(context),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Container(
                                          width: double.infinity,
                                          color: Color(0x00000000),
                                          child: ExpandableNotifier(
                                            controller: _model
                                                .expandableExpandableController,
                                            child: ExpandablePanel(
                                              header: wrapWithModel(
                                                model: _model.formLabelModel7,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: FormLabelWidget(
                                                  label: 'Категория',
                                                  requiredIndicatorColor:
                                                      _model.choosenCat != null
                                                      ? FlutterFlowTheme.of(
                                                          context,
                                                        ).primaryText
                                                      : FlutterFlowTheme.of(
                                                          context,
                                                        ).error,
                                                ),
                                              ),
                                              collapsed: Visibility(
                                                visible:
                                                    _model.choosenCat != null,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .radio_button_checked,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).primary,
                                                      size: 24.0,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        valueOrDefault<String>(
                                                          _model
                                                              .choosenCat
                                                              ?.titleRU,
                                                          'Без названия',
                                                        ),
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).primaryText,
                                                          letterSpacing: 0.0,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ].divide(SizedBox(width: 8.0)),
                                                ),
                                              ),
                                              expanded: SizedBox(
                                                height: 200.0,
                                                child: Builder(
                                                  builder: (context) {
                                                    final presetCat =
                                                        FFAppState()
                                                            .presetCategory
                                                            .toList()
                                                          ..sort((
                                                            first,
                                                            second,
                                                          ) {
                                                            final byTitle =
                                                                _categorySortKey(
                                                                  first,
                                                                ).compareTo(
                                                                  _categorySortKey(
                                                                    second,
                                                                  ),
                                                                );
                                                            return byTitle != 0
                                                                ? byTitle
                                                                : first.key
                                                                      .compareTo(
                                                                        second
                                                                            .key,
                                                                      );
                                                          });

                                                    return ListView.separated(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          presetCat.length,
                                                      separatorBuilder:
                                                          (_, __) => SizedBox(
                                                            height: 8.0,
                                                          ),
                                                      itemBuilder: (context, presetCatIndex) {
                                                        final presetCatItem =
                                                            presetCat[presetCatIndex];
                                                        final isSelectedCategory =
                                                            presetCatItem.key ==
                                                            _model
                                                                .choosenCat
                                                                ?.key;
                                                        return InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.choosenCat =
                                                                presetCatItem;
                                                            safeSetState(() {});
                                                            _model
                                                                .expandableExpandableController
                                                                .toggle();
                                                          },
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children:
                                                                [
                                                                  if (!isSelectedCategory)
                                                                    Icon(
                                                                      Icons
                                                                          .circle_outlined,
                                                                      color: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).primary,
                                                                      size:
                                                                          24.0,
                                                                    ),
                                                                  if (isSelectedCategory)
                                                                    Icon(
                                                                      Icons
                                                                          .radio_button_checked,
                                                                      color: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).primary,
                                                                      size:
                                                                          24.0,
                                                                    ),
                                                                  Flexible(
                                                                    child: Text(
                                                                      presetCatItem
                                                                          .titleRU,
                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ].divide(
                                                                  SizedBox(
                                                                    width: 8.0,
                                                                  ),
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              theme: ExpandableThemeData(
                                                tapHeaderToExpand: true,
                                                tapBodyToExpand: false,
                                                tapBodyToCollapse: false,
                                                headerAlignment:
                                                    ExpandablePanelHeaderAlignment
                                                        .center,
                                                hasIcon: true,
                                                iconColor: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          12.0,
                                          0.0,
                                          0.0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                wrapWithModel(
                                                  model: _model.formLabelModel8,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: FormLabelWidget(
                                                    label: 'Цена',
                                                    requiredIndicatorColor:
                                                        (int.tryParse(
                                                                  _model
                                                                      .textController4
                                                                      .text,
                                                                ) ??
                                                                0) >
                                                            0
                                                        ? FlutterFlowTheme.of(
                                                            context,
                                                          ).primaryText
                                                        : FlutterFlowTheme.of(
                                                            context,
                                                          ).error,
                                                  ),
                                                ),
                                                TextFormField(
                                                  controller:
                                                      _model.textController4,
                                                  focusNode: _model
                                                      .textFieldFocusNode4,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                        '_model.textController4',
                                                        Duration(
                                                          milliseconds: 100,
                                                        ),
                                                        () =>
                                                            safeSetState(() {}),
                                                      ),
                                                  autofocus: false,
                                                  enabled: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: false,
                                                    labelText:
                                                        FFLocalizations.of(
                                                          context,
                                                        ).getText(
                                                          'dgiq8hvh' /* за услугу */,
                                                        ),
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.override(
                                                          font: GoogleFonts.jetBrainsMono(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.override(
                                                          font: GoogleFonts.jetBrainsMono(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).secondary,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primary,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).error,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.0,
                                                              ),
                                                        ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).secondaryBackground,
                                                  ),
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
                                                        letterSpacing: 0.0,
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
                                                  maxLength: 10,
                                                  buildCounter:
                                                      (
                                                        context, {
                                                        required currentLength,
                                                        required isFocused,
                                                        maxLength,
                                                      }) => null,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .textController4Validator
                                                      .asValidator(context),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                wrapWithModel(
                                                  model: _model.formLabelModel9,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: FormLabelWidget(
                                                    label:
                                                        'Время оказания услуги',
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: _model
                                                            .textController5,
                                                        focusNode: _model
                                                            .textFieldFocusNode5,
                                                        onChanged: (_) =>
                                                            EasyDebounce.debounce(
                                                              '_model.textController5',
                                                              Duration(
                                                                milliseconds:
                                                                    100,
                                                              ),
                                                              () =>
                                                                  safeSetState(
                                                                    () {},
                                                                  ),
                                                            ),
                                                        autofocus: false,
                                                        enabled: true,
                                                        obscureText: false,
                                                        decoration: InputDecoration(
                                                          isDense: false,
                                                          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                            font: GoogleFonts.jetBrainsMono(
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .labelMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .labelMedium
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          hintText: 'Значение',
                                                          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                            font: GoogleFonts.jetBrainsMono(
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .labelMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .labelMedium
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).secondary,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8.0,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).primary,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8.0,
                                                                ),
                                                          ),
                                                          errorBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).error,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8.0,
                                                                ),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                  color:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).error,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8.0,
                                                                    ),
                                                              ),
                                                          filled: true,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).secondaryBackground,
                                                        ),
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                          letterSpacing: 0.0,
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
                                                        maxLength: 3,
                                                        buildCounter:
                                                            (
                                                              context, {
                                                              required currentLength,
                                                              required isFocused,
                                                              maxLength,
                                                            }) => null,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                        cursorColor:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primaryText,
                                                        enableInteractiveSelection:
                                                            true,
                                                        validator: _model
                                                            .textController5Validator
                                                            .asValidator(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.0),
                                                    SizedBox(
                                                      width: 92.0,
                                                      child: DropdownButtonFormField<String>(
                                                        value: _durationUnit,
                                                        isExpanded: true,
                                                        decoration: InputDecoration(
                                                          isDense: false,
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    12.0,
                                                                vertical: 16.0,
                                                              ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).secondary,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8.0,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).primary,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8.0,
                                                                ),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).secondaryBackground,
                                                        ),
                                                        dropdownColor:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).secondaryBackground,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).bodyMedium.override(
                                                              font:
                                                                  GoogleFonts.jetBrainsMono(),
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).primaryText,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                        items: const [
                                                          DropdownMenuItem(
                                                            value: 'min',
                                                            child: Text('мин.'),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'hour',
                                                            child: Text('ч.'),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'day',
                                                            child: Text('д.'),
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            safeSetState(
                                                              () =>
                                                                  _durationUnit =
                                                                      value,
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ].divide(SizedBox(height: 16.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                            ),
                          ),
                        ),
                        if (widget!.servDoc != null)
                          Container(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                24.0,
                                0.0,
                                24.0,
                                32.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Builder(
                                    builder: (context) => FFButtonWidget(
                                      onPressed:
                                          (normalizeUserText(
                                                _model.textController1.text,
                                              ).isEmpty ||
                                              normalizeUserText(
                                                _model.textController3.text,
                                              ).isEmpty ||
                                              (_model.textController4.text ==
                                                      null ||
                                                  _model.textController4.text ==
                                                      '') ||
                                              ((int.tryParse(
                                                        _model
                                                            .textController4
                                                            .text,
                                                      ) ??
                                                      0) <=
                                                  0) ||
                                              (_model.choosenCat == null) ||
                                              !_hasImageForSave ||
                                              (_model.onCity
                                                  ? (_serviceCity() == null)
                                                  : (_model.adres == null)))
                                          ? null
                                          : () async {
                                              if (_model
                                                  .uploadPhoto
                                                  .isNotEmpty) {
                                                {
                                                  safeSetState(
                                                    () =>
                                                        _model.isDataUploading_uploadDataEdit =
                                                            true,
                                                  );
                                                  var selectedUploadedFiles =
                                                      <FFUploadedFile>[];
                                                  var selectedMedia =
                                                      <SelectedFile>[];
                                                  var downloadUrls = <String>[];
                                                  try {
                                                    selectedUploadedFiles =
                                                        _model.uploadPhoto;
                                                    selectedMedia =
                                                        selectedFilesFromUploadedFiles(
                                                          selectedUploadedFiles,
                                                          isMultiData: true,
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
                                                            .where(
                                                              (u) => u != null,
                                                            )
                                                            .map((u) => u!)
                                                            .toList();
                                                  } finally {
                                                    _model.isDataUploading_uploadDataEdit =
                                                        false;
                                                  }
                                                  if (selectedUploadedFiles
                                                              .length ==
                                                          selectedMedia
                                                              .length &&
                                                      downloadUrls.length ==
                                                          selectedMedia
                                                              .length) {
                                                    safeSetState(() {
                                                      _model.uploadedLocalFiles_uploadDataEdit =
                                                          selectedUploadedFiles;
                                                      _model.uploadedFileUrls_uploadDataEdit =
                                                          downloadUrls;
                                                    });
                                                  } else {
                                                    safeSetState(() {});
                                                    return;
                                                  }
                                                }
                                              }

                                              final finalImageUrls = <String>[
                                                ..._remainingExistingImageUrls,
                                                ..._model
                                                    .uploadedFileUrls_uploadDataEdit,
                                              ];

                                              await widget!.servDoc!.reference
                                                  .update({
                                                    ...createServiceRecordData(
                                                      title: _model
                                                          .textController1
                                                          .text,
                                                      description: _model
                                                          .textController3
                                                          .text,
                                                      price: int.tryParse(
                                                        _model
                                                            .textController4
                                                            .text,
                                                      ),
                                                      time: int.tryParse(
                                                        _model
                                                            .textController5
                                                            .text,
                                                      ),
                                                      timeUnit: _durationUnit,
                                                      categoryKey: _model
                                                          .choosenCat
                                                          ?.key,
                                                      status: ServiceStatus
                                                          .onModerate,
                                                      place: updatePlaceStruct(
                                                        _model.onCity
                                                            ? _serviceCity()
                                                            : _model.adres,
                                                        clearUnsetFields: false,
                                                      ),
                                                      location: _model.onCity
                                                          ? _serviceCity()
                                                                ?.location
                                                          : _model
                                                                .adres
                                                                ?.location,
                                                      masterTitle:
                                                          currentUserDocument
                                                              ?.masterData
                                                              .title,
                                                      masterPhoto:
                                                          currentUserDocument
                                                              ?.masterData
                                                              .mainPhoto,
                                                    ),
                                                    ...mapToFirestore({
                                                      'image': finalImageUrls,
                                                    }),
                                                  });

                                              for (final imageUrl
                                                  in _removedImageUrls) {
                                                try {
                                                  await FirebaseStorage.instance
                                                      .refFromURL(imageUrl)
                                                      .delete();
                                                } catch (error) {
                                                  debugPrint(
                                                    'Failed to delete removed service image: $error',
                                                  );
                                                }
                                              }
                                              await showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (dialogContext) {
                                                  return Dialog(
                                                    elevation: 0,
                                                    insetPadding:
                                                        EdgeInsets.zero,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    alignment:
                                                        AlignmentDirectional(
                                                          0.0,
                                                          0.0,
                                                        ).resolve(
                                                          Directionality.of(
                                                            context,
                                                          ),
                                                        ),
                                                    child: SaveServChangeWidget(
                                                      create: false,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                      text: FFLocalizations.of(context).getText(
                                        't7hzxc2l' /* Сохранить изменения */,
                                      ),
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          0.0,
                                        ),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0.0,
                                              0.0,
                                              0.0,
                                              0.0,
                                            ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primary,
                                        textStyle: TextStyle(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryBackground,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                        elevation: 0.0,
                                        borderRadius: BorderRadius.circular(
                                          28.0,
                                        ),
                                        disabledColor: FlutterFlowTheme.of(
                                          context,
                                        ).tertiary,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) => FFButtonWidget(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return Dialog(
                                              elevation: 0,
                                              insetPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 36.0,
                                                  ),
                                              backgroundColor:
                                                  Colors.transparent,
                                              alignment:
                                                  AlignmentDirectional(
                                                    0.0,
                                                    0.0,
                                                  ).resolve(
                                                    Directionality.of(context),
                                                  ),
                                              child: DelServWidget(
                                                servTodel: widget!.servDoc!,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      text: FFLocalizations.of(context).getText(
                                        'ajv2evw0' /* Удалить услугу */,
                                      ),
                                      icon: Icon(
                                        Icons.archive_rounded,
                                        size: 15.0,
                                      ),
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          0.0,
                                        ),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0.0,
                                              0.0,
                                              0.0,
                                              0.0,
                                            ),
                                        iconColor: FlutterFlowTheme.of(
                                          context,
                                        ).error,
                                        color: Colors.transparent,
                                        textStyle: TextStyle(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).error,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                        elevation: 0.0,
                                        borderRadius: BorderRadius.circular(
                                          28.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                            ),
                          ),
                        if (widget!.servDoc == null)
                          Container(
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                24.0,
                                0.0,
                                24.0,
                                32.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Builder(
                                    builder: (context) => FFButtonWidget(
                                      onPressed:
                                          (normalizeUserText(
                                                _model.textController1.text,
                                              ).isEmpty ||
                                              normalizeUserText(
                                                _model.textController3.text,
                                              ).isEmpty ||
                                              (_model.textController4.text ==
                                                      null ||
                                                  _model.textController4.text ==
                                                      '') ||
                                              ((int.tryParse(
                                                        _model
                                                            .textController4
                                                            .text,
                                                      ) ??
                                                      0) <=
                                                  0) ||
                                              (_model.choosenCat == null) ||
                                              (widget!.servDoc != null
                                                  ? (!(widget!
                                                            .servDoc!
                                                            .image
                                                            .isNotEmpty) ||
                                                        !(_model
                                                            .uploadPhoto
                                                            .isNotEmpty))
                                                  : !(_model
                                                        .uploadPhoto
                                                        .isNotEmpty)) ||
                                              (_model.onCity
                                                  ? (_serviceCity() == null)
                                                  : (_model.adres == null)))
                                          ? null
                                          : () async {
                                              var isFirstService = false;
                                              final ownerReference =
                                                  currentUserReference;
                                              if (ownerReference != null) {
                                                try {
                                                  final existingServices =
                                                      await queryServiceRecordOnce(
                                                        queryBuilder:
                                                            (
                                                              serviceRecord,
                                                            ) => serviceRecord
                                                                .where(
                                                                  'owner',
                                                                  isEqualTo:
                                                                      ownerReference,
                                                                ),
                                                        limit: 1,
                                                      );
                                                  isFirstService =
                                                      existingServices.isEmpty;
                                                } catch (_) {
                                                  isFirstService = false;
                                                }
                                              }
                                              if (_model
                                                  .uploadPhoto
                                                  .isNotEmpty) {
                                                {
                                                  safeSetState(
                                                    () =>
                                                        _model.isDataUploading_uploadDataCreate =
                                                            true,
                                                  );
                                                  var selectedUploadedFiles =
                                                      <FFUploadedFile>[];
                                                  var selectedMedia =
                                                      <SelectedFile>[];
                                                  var downloadUrls = <String>[];
                                                  try {
                                                    selectedUploadedFiles =
                                                        _model.uploadPhoto;
                                                    selectedMedia =
                                                        selectedFilesFromUploadedFiles(
                                                          selectedUploadedFiles,
                                                          isMultiData: true,
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
                                                            .where(
                                                              (u) => u != null,
                                                            )
                                                            .map((u) => u!)
                                                            .toList();
                                                  } finally {
                                                    _model.isDataUploading_uploadDataCreate =
                                                        false;
                                                  }
                                                  if (selectedUploadedFiles
                                                              .length ==
                                                          selectedMedia
                                                              .length &&
                                                      downloadUrls.length ==
                                                          selectedMedia
                                                              .length) {
                                                    safeSetState(() {
                                                      _model.uploadedLocalFiles_uploadDataCreate =
                                                          selectedUploadedFiles;
                                                      _model.uploadedFileUrls_uploadDataCreate =
                                                          downloadUrls;
                                                    });
                                                  } else {
                                                    safeSetState(() {});
                                                    return;
                                                  }
                                                }
                                              }

                                              var serviceRecordReference =
                                                  ServiceRecord.collection
                                                      .doc();
                                              await serviceRecordReference.set({
                                                ...createServiceRecordData(
                                                  title: _model
                                                      .textController1
                                                      .text,
                                                  owner: currentUserReference,
                                                  description: _model
                                                      .textController3
                                                      .text,
                                                  price: int.tryParse(
                                                    _model.textController4.text,
                                                  ),
                                                  time: int.tryParse(
                                                    _model.textController5.text,
                                                  ),
                                                  timeUnit: _durationUnit,
                                                  categoryKey:
                                                      _model.choosenCat?.key,
                                                  place: updatePlaceStruct(
                                                    _model.onCity
                                                        ? _serviceCity()
                                                        : _model.adres,
                                                    clearUnsetFields: false,
                                                    create: true,
                                                  ),
                                                  status:
                                                      ServiceStatus.onModerate,
                                                  location: _model.onCity
                                                      ? _serviceCity()?.location
                                                      : _model.adres?.location,
                                                  masterTitle:
                                                      currentUserDocument
                                                          ?.masterData
                                                          .title,
                                                  masterPhoto:
                                                      currentUserDocument
                                                          ?.masterData
                                                          .mainPhoto,
                                                ),
                                                ...mapToFirestore({
                                                  'image': _model
                                                      .uploadedFileUrls_uploadDataCreate,
                                                }),
                                              });
                                              _model.newServ =
                                                  ServiceRecord.getDocumentFromData({
                                                    ...createServiceRecordData(
                                                      title: _model
                                                          .textController1
                                                          .text,
                                                      owner:
                                                          currentUserReference,
                                                      description: _model
                                                          .textController3
                                                          .text,
                                                      price: int.tryParse(
                                                        _model
                                                            .textController4
                                                            .text,
                                                      ),
                                                      time: int.tryParse(
                                                        _model
                                                            .textController5
                                                            .text,
                                                      ),
                                                      timeUnit: _durationUnit,
                                                      categoryKey: _model
                                                          .choosenCat
                                                          ?.key,
                                                      place: updatePlaceStruct(
                                                        _model.onCity
                                                            ? _serviceCity()
                                                            : _model.adres,
                                                        clearUnsetFields: false,
                                                        create: true,
                                                      ),
                                                      status: ServiceStatus
                                                          .onModerate,
                                                      location: _model.onCity
                                                          ? _serviceCity()
                                                                ?.location
                                                          : _model
                                                                .adres
                                                                ?.location,
                                                      masterTitle:
                                                          currentUserDocument
                                                              ?.masterData
                                                              .title,
                                                      masterPhoto:
                                                          currentUserDocument
                                                              ?.masterData
                                                              .mainPhoto,
                                                    ),
                                                    ...mapToFirestore({
                                                      'image': _model
                                                          .uploadedFileUrls_uploadDataCreate,
                                                    }),
                                                  }, serviceRecordReference);
                                              await showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (dialogContext) {
                                                  return Dialog(
                                                    elevation: 0,
                                                    insetPadding:
                                                        EdgeInsets.zero,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    alignment:
                                                        AlignmentDirectional(
                                                          0.0,
                                                          0.0,
                                                        ).resolve(
                                                          Directionality.of(
                                                            context,
                                                          ),
                                                        ),
                                                    child: SaveServChangeWidget(
                                                      create: true,
                                                      showFirstServiceInvite:
                                                          isFirstService,
                                                    ),
                                                  );
                                                },
                                              );

                                              safeSetState(() {});
                                            },
                                      text: FFLocalizations.of(context).getText(
                                        'uokub5fi' /* Создать услугу */,
                                      ),
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          0.0,
                                        ),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0.0,
                                              0.0,
                                              0.0,
                                              0.0,
                                            ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primary,
                                        textStyle: TextStyle(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryBackground,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                        elevation: 0.0,
                                        borderRadius: BorderRadius.circular(
                                          28.0,
                                        ),
                                        disabledColor: FlutterFlowTheme.of(
                                          context,
                                        ).tertiary,
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                            ),
                          ),
                      ].divide(SizedBox(height: 24.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_model.isDataUploading_uploadDataEdit ||
              _model.isDataUploading_uploadDataCreate)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Загружаем фотографии…',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceLocationTabButton extends StatelessWidget {
  const _ServiceLocationTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected
              ? FlutterFlowTheme.of(context).primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8.0,
                    offset: Offset(0.0, 2.0),
                  ),
                ]
              : null,
        ),
        alignment: AlignmentDirectional(0.0, 0.0),
        padding: EdgeInsets.all(8.0),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FlutterFlowTheme.of(context).labelLarge.override(
            font: GoogleFonts.jetBrainsMono(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            color: selected
                ? FlutterFlowTheme.of(context).info
                : FlutterFlowTheme.of(context).primaryText,
            letterSpacing: 0.0,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
