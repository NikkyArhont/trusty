import '/backend/backend.dart';
import '/backend/dummy_data.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import '/user/service_card_client/service_card_client_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_model.dart';
export 'main_model.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  static String routeName = 'main';
  static String routePath = '/main';

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  late MainModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainModel());

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

    return StreamBuilder<List<ServiceRecord>>(
      stream: queryServiceRecord(
        queryBuilder: (serviceRecord) => serviceRecord
            .where(
              'categoryKey',
              isEqualTo: FFAppState().globalFilter.catKey != ''
                  ? FFAppState().globalFilter.catKey
                  : null,
            )
            .where(
              'place.cityId',
              isEqualTo: FFAppState().globalFilter.place.cityId != ''
                  ? FFAppState().globalFilter.place.cityId
                  : null,
            ),
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: SpinKitPulse(
                  color: FlutterFlowTheme.of(context).primary,
                  size: 50.0,
                ),
              ),
            ),
          );
        }
        List<ServiceRecord> mainServiceRecordList = List.from(snapshot.data ?? []);
        final catKey = FFAppState().globalFilter.catKey;
        final dummyServices = DummyDataHelper.getDummyServices();
        
        mainServiceRecordList.addAll(
          (catKey != null && catKey != '') 
            ? dummyServices.where((s) => s.categoryKey == catKey) 
            : dummyServices
        );

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 24.0, 16.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          '6ef5ecez' /* Trusty */,
                                        ),
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 32.0,
                                        ),
                                      ),
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          '5za4bwk8' /* Recommendations you trust */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ],
                                  ),
                                  FlutterFlowIconButton(
                                    borderColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    borderRadius: 12.0,
                                    borderWidth: 1.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    icon: Icon(
                                      Icons.location_on,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      context.pushNamed(
                                        ChooseLocationCityWidget.routeName,
                                        queryParameters: {
                                          'edit': serializeParam(
                                            false,
                                            ParamType.bool,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 12.0, 16.0, 12.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 22.0,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'bm0k963u' /* Поиск услуг... */,
                                          ),
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .hint,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.tune_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 20.0,
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 12.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().updateGlobalFilterStruct(
                                      (e) => e..catKey = null,
                                    );
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FFAppState().globalFilter.catKey ==
                                                  null ||
                                              FFAppState()
                                                      .globalFilter
                                                      .catKey ==
                                                  ''
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color:
                                            FFAppState().globalFilter.catKey ==
                                                        null ||
                                                    FFAppState()
                                                            .globalFilter
                                                            .catKey ==
                                                        ''
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .divider,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 10.0, 20.0, 10.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'of2007qn' /* Все */,
                                        ),
                                        style: TextStyle(
                                          color: FFAppState()
                                                          .globalFilter
                                                          .catKey ==
                                                      null ||
                                                  FFAppState()
                                                          .globalFilter
                                                          .catKey ==
                                                      ''
                                              ? Colors.white
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final presetCats =
                                        FFAppState().presetCategory.toList();

                                    return Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: List.generate(presetCats.length,
                                          (presetCatsIndex) {
                                        final presetCatsItem =
                                            presetCats[presetCatsIndex];
                                        return InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            FFAppState()
                                                .updateGlobalFilterStruct(
                                              (e) => e
                                                ..catKey = presetCatsItem.key,
                                            );
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: FFAppState()
                                                          .globalFilter
                                                          .catKey ==
                                                      presetCatsItem.key
                                                  ? FlutterFlowTheme.of(context)
                                                      .primary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              border: Border.all(
                                                color: FFAppState()
                                                            .globalFilter
                                                            .catKey ==
                                                        presetCatsItem.key
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .divider,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 10.0, 20.0, 10.0),
                                              child: Text(
                                                presetCatsItem.titleRU,
                                                style: TextStyle(
                                                  color: FFAppState()
                                                              .globalFilter
                                                              .catKey ==
                                                          presetCatsItem.key
                                                      ? Colors.white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).divide(SizedBox(width: 12.0)),
                                    );
                                  },
                                ),
                              ]
                                  .divide(SizedBox(width: 12.0))
                                  .addToStart(SizedBox(width: 12.0))
                                  .addToEnd(SizedBox(width: 12.0)),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Builder(
                            builder: (context) {
                              final mainVar = mainServiceRecordList.toList();

                              return MasonryGridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                itemCount: mainVar.length,
                                shrinkWrap: true,
                                itemBuilder: (context, mainVarIndex) {
                                  final mainVarItem = mainVar[mainVarIndex];
                                  return ServiceCardClientWidget(
                                    key: Key(
                                        'Key55p_${mainVarIndex}_of_${mainVar.length}'),
                                    servicedoc: mainVarItem,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ]
                        .divide(SizedBox(height: 0.0))
                        .addToEnd(SizedBox(height: 120.0)),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.menuModel,
                    updateCallback: () => safeSetState(() {}),
                    child: MenuWidget(
                      currentPage: Menu.main,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
