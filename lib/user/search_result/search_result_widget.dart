import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/user/service_card_client/service_card_client_widget.dart';
import '/user/specialist_service_card_map/specialist_service_card_map_widget.dart';
import 'dart:ui';
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'search_result_model.dart';
export 'search_result_model.dart';

class SearchResultWidget extends StatefulWidget {
  const SearchResultWidget({
    super.key,
    required this.listResult,
  });

  final List<ServiceRecord>? listResult;

  static String routeName = 'SearchResult';
  static String routePath = '/searchResult';

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  late SearchResultModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.setLoc = FFAppState().globalFilter.place.location;
      safeSetState(() {});
    });

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
      resizeToAvoidBottomInset: false,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_model.listOrMap) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            wrapWithModel(
                              model: _model.navBackModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: NavBackWidget(),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(1.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    _model.listOrMap = false;
                                    safeSetState(() {});
                                  },
                                  text: FFLocalizations.of(context).getText(
                                    'gpfqo0lp' /* Карта */,
                                  ),
                                  icon: Icon(
                                    Icons.map,
                                    size: 24.0,
                                  ),
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ]
                              .addToStart(SizedBox(width: 24.0))
                              .addToEnd(SizedBox(width: 24.0)),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Builder(
                            builder: (context) {
                              final serv = widget!.listResult!.toList();

                              return MasonryGridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                itemCount: serv.length,
                                shrinkWrap: true,
                                itemBuilder: (context, servIndex) {
                                  final servItem = serv[servIndex];
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed(
                                        ServiceDetailWidget.routeName,
                                        queryParameters: {
                                          'serviceDoc': serializeParam(
                                            servItem,
                                            ParamType.Document,
                                          ),
                                        }.withoutNulls,
                                        extra: <String, dynamic>{
                                          'serviceDoc': servItem,
                                        },
                                      );
                                    },
                                    child: ServiceCardClientWidget(
                                      key: Key(
                                          'Keyhu4_${servIndex}_of_${serv.length}'),
                                      servicedoc: servItem,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ]
                          .divide(SizedBox(height: 12.0))
                          .addToStart(SizedBox(height: 24.0))
                          .addToEnd(SizedBox(height: 24.0)),
                    );
                  } else {
                    return Stack(
                      children: [
                        FlutterFlowGoogleMap(
                          controller: _model.googleMapsController,
                          onCameraIdle: (latLng) =>
                              _model.googleMapsCenter = latLng,
                          initialLocation: _model.googleMapsCenter ??=
                              _model.setLoc!,
                          markers: (widget!.listResult ?? [])
                              .map(
                                (marker) => FlutterFlowMarker(
                                  marker.reference.path,
                                  marker.location!,
                                  () async {
                                    _model.choosenServ = marker;
                                    safeSetState(() {});
                                  },
                                ),
                              )
                              .toList(),
                          markerColor: GoogleMarkerColor.blue,
                          mapType: MapType.normal,
                          style: GoogleMapStyle.standard,
                          initialZoom: 14.0,
                          allowInteraction: true,
                          allowZoom: true,
                          showZoomControls: false,
                          showLocation: true,
                          showCompass: false,
                          showMapToolbar: false,
                          showTraffic: false,
                          centerMapOnMarkerTap: true,
                          mapTakesGesturePreference: false,
                        ),
                        PointerInterceptor(
                          intercepting: isWeb,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  wrapWithModel(
                                    model: _model.navBackModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: NavBackWidget(),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional(1.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          _model.listOrMap = true;
                                          safeSetState(() {});
                                        },
                                        text:
                                            FFLocalizations.of(context).getText(
                                          'nbdslzq7' /* Список */,
                                        ),
                                        icon: Icon(
                                          Icons.list,
                                          size: 24.0,
                                        ),
                                        options: FFButtonOptions(
                                          height: 40.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                          elevation: 0.0,
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                                    .addToStart(SizedBox(width: 24.0))
                                    .addToEnd(SizedBox(width: 24.0)),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 12.0, 0.0),
                                    child: FlutterFlowIconButton(
                                      borderColor: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: 8.0,
                                      buttonSize: 40.0,
                                      fillColor:
                                          FlutterFlowTheme.of(context).primary,
                                      icon: Icon(
                                        Icons.my_location,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        currentUserLocationValue =
                                            await getCurrentUserLocation(
                                                defaultLocation:
                                                    LatLng(0.0, 0.0));
                                        await requestPermission(
                                            locationPermission);
                                        if (currentUserLocationValue != null) {
                                          _model.setLoc =
                                              currentUserLocationValue;
                                          safeSetState(() {});
                                        } else {
                                          _model.setLoc = FFAppState()
                                              .globalFilter
                                              .place
                                              .location;
                                          safeSetState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              if (_model.choosenServ != null)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          ServiceDetailWidget.routeName,
                                          queryParameters: {
                                            'serviceDoc': serializeParam(
                                              _model.choosenServ,
                                              ParamType.Document,
                                            ),
                                          }.withoutNulls,
                                          extra: <String, dynamic>{
                                            'serviceDoc': _model.choosenServ,
                                          },
                                        );
                                      },
                                      child: wrapWithModel(
                                        model: _model
                                            .specialistServiceCardMapModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: SpecialistServiceCardMapWidget(
                                          servDoc: _model.choosenServ!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ]
                                .addToStart(SizedBox(height: 24.0))
                                .addToEnd(SizedBox(height: 24.0)),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ].divide(SizedBox(height: 2.0)),
        ),
      ),
    );
  }
}
