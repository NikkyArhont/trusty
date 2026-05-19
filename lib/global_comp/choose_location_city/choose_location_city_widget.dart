import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/current_location_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/city_item/city_item_widget.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/no_set_loc/no_set_loc_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'choose_location_city_model.dart';
export 'choose_location_city_model.dart';

class ChooseLocationCityWidget extends StatefulWidget {
  const ChooseLocationCityWidget({
    super.key,
    required this.edit,
  });

  final bool? edit;

  static String routeName = 'chooseLocationCity';
  static String routePath = '/chooseLocationCity';

  @override
  State<ChooseLocationCityWidget> createState() =>
      _ChooseLocationCityWidgetState();
}

class _ChooseLocationCityWidgetState extends State<ChooseLocationCityWidget> {
  late ChooseLocationCityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChooseLocationCityModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (FFAppState().firstTime)
                          wrapWithModel(
                            model: _model.navBackModel,
                            updateCallback: () => safeSetState(() {}),
                            child: NavBackWidget(),
                          ),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional(1.0, 0.0),
                            child: Builder(
                              builder: (context) => InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  currentUserLocationValue =
                                      await getCurrentUserLocation(
                                          defaultLocation: LatLng(0.0, 0.0));
                                  await requestPermission(locationPermission);
                                  if (currentUserLocationValue != null) {
                                    safeSetState(() {
                                      _model.textController?.clear();
                                    });
                                    _model.searchResult = [];
                                    _model.choosenPlace =
                                        functions.searchCityLocation(
                                            FFAppState().listRUCities.toList(),
                                            currentUserLocationValue);
                                    safeSetState(() {});
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                          alignment: AlignmentDirectional(
                                                  0.0, 0.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          child: NoSetLocWidget(),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: wrapWithModel(
                                  model: _model.currentLocationModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CurrentLocationWidget(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 16.0,
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'c4xq9wb4' /* Выберите свой город */,
                      ),
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'ie17ultr' /* Чтобы найти услуги и клиентов ... */,
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
                  ].divide(SizedBox(height: 4.0)),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _model.textController,
                      focusNode: _model.textFieldFocusNode,
                      onChanged: (_) => EasyDebounce.debounce(
                        '_model.textController',
                        Duration(milliseconds: 100),
                        () async {
                          _model.searchResult = functions
                              .searchCityText(
                                  FFAppState().listRUCities.toList(),
                                  _model.textController.text)!
                              .toList()
                              .cast<PlaceStruct>();
                          _model.choosenPlace = null;
                          safeSetState(() {});
                        },
                      ),
                      autofocus: false,
                      enabled: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: false,
                        labelStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.jetBrainsMono(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                        hintText: FFLocalizations.of(context).getText(
                          'xamu0jwy' /* Введите название */,
                        ),
                        hintStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.jetBrainsMono(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
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
                            FlutterFlowTheme.of(context).secondaryBackground,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                        ),
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
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                      cursorColor: FlutterFlowTheme.of(context).primaryText,
                      enableInteractiveSelection: true,
                      validator:
                          _model.textControllerValidator.asValidator(context),
                    ),
                    if (_model.choosenPlace != null)
                      wrapWithModel(
                        model: _model.cityItemModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: CityItemWidget(
                          selected: true,
                          name: _model.choosenPlace?.title,
                          region: _model.choosenPlace?.description,
                        ),
                      ),
                  ].divide(SizedBox(height: 16.0)),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Visibility(
                  visible: _model.searchResult.isNotEmpty,
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Builder(
                      builder: (context) {
                        final searchREsult = _model.searchResult.toList();

                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            12.0,
                            0,
                            0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: searchREsult.length,
                          itemBuilder: (context, searchREsultIndex) {
                            final searchREsultItem =
                                searchREsult[searchREsultIndex];
                            return InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.choosenPlace = searchREsultItem;
                                _model.searchResult = [];
                                safeSetState(() {});
                                safeSetState(() {
                                  _model.textController?.clear();
                                });
                              },
                              child: CityItemWidget(
                                key: Key(
                                    'Keyw3i_${searchREsultIndex}_of_${searchREsult.length}'),
                                selected: false,
                                name: searchREsultItem.title,
                                region: searchREsultItem.description,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                border: Border.all(
                  color: FlutterFlowTheme.of(context).divider,
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: FFButtonWidget(
                  onPressed: (_model.choosenPlace == null)
                      ? null
                      : () async {
                          FFAppState().updateGlobalFilterStruct(
                            (e) => e..place = _model.choosenPlace,
                          );
                          FFAppState().firstTime = false;
                          safeSetState(() {});
                          if (widget!.edit!) {
                            context.safePop();
                          } else {
                            context.goNamed(MainWidget.routeName);
                          }
                        },
                  text: FFLocalizations.of(context).getText(
                    'hfwzvn2l' /* Подтвердить */,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44.0,
                    padding: EdgeInsets.all(16.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: GoogleFonts.jetBrainsMono(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(22.0),
                    disabledColor: FlutterFlowTheme.of(context).tertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
