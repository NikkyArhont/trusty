import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
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
  const SearchResultWidget({super.key, required this.listResult});

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

  LatLng get _initialMapLocation {
    for (final service in _visibleServices) {
      final location = service.location;
      if (location != null) {
        return location;
      }
    }

    return FFAppState().globalFilter.place.location ??
        const LatLng(55.7558, 37.6173);
  }

  List<ServiceRecord> get _visibleServices =>
      (widget.listResult ?? const <ServiceRecord>[])
          .where((service) => service.status == ServiceStatus.show)
          .toList();

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
                      children:
                          [
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
                                        alignment: AlignmentDirectional(
                                          1.0,
                                          0.0,
                                        ),
                                        child: FFButtonWidget(
                                          onPressed: () async {
                                            _model.googleMapsController =
                                                Completer<
                                                  GoogleMapController
                                                >();
                                            _model.listOrMap = false;
                                            safeSetState(() {});
                                          },
                                          text: FFLocalizations.of(
                                            context,
                                          ).getText('gpfqo0lp' /* Карта */),
                                          icon: Icon(Icons.map, size: 24.0),
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
                                            ).primaryBackground,
                                            textStyle:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).titleSmall.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                            elevation: 0.0,
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondaryText,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ].addToStart(SizedBox(width: 24.0)).addToEnd(SizedBox(width: 24.0)),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                          12.0,
                                          0.0,
                                          12.0,
                                          0.0,
                                        ),
                                    child: Builder(
                                      builder: (context) {
                                        final services = _visibleServices;
                                        return MasonryGridView.builder(
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                              ),
                                          crossAxisSpacing: 10.0,
                                          mainAxisSpacing: 10.0,
                                          itemCount: services.length,
                                          itemBuilder: (context, index) {
                                            final service = services[index];
                                            return ServiceCardClientWidget(
                                              key: Key(
                                                'search_result_${service.reference.id}',
                                              ),
                                              servicedoc: service,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ]
                              .divide(SizedBox(height: 12.0))
                              .addToStart(SizedBox(height: 24.0))
                              .addToEnd(SizedBox(height: 24.0)),
                    );
                  } else {
                    final mapServices = _visibleServices
                        .where((service) => service.location != null)
                        .toList();
                    return Stack(
                      children: [
                        FlutterFlowGoogleMap(
                          controller: _model.googleMapsController,
                          onCameraIdle: (latLng) =>
                              _model.googleMapsCenter = latLng,
                          initialLocation: _model.googleMapsCenter ??=
                              _model.setLoc ?? _initialMapLocation,
                          markers: mapServices
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
                          markerColorValue: FlutterFlowTheme.of(
                            context,
                          ).primary,
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
                        Positioned(
                          top: 16.0,
                          left: 16.0,
                          child: PointerInterceptor(
                            intercepting: isWeb,
                            child: wrapWithModel(
                              model: _model.navBackModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: NavBackWidget(),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16.0,
                          bottom: _model.choosenServ == null ? 16.0 : 140.0,
                          child: PointerInterceptor(
                            intercepting: isWeb,
                            child: FlutterFlowIconButton(
                              borderColor: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              borderRadius: 12.0,
                              buttonSize: 44.0,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.my_location,
                                color: FlutterFlowTheme.of(context).info,
                                size: 22.0,
                              ),
                              onPressed: () async {
                                await requestPermission(locationPermission);
                                final location = await getCurrentUserLocation(
                                  defaultLocation: _initialMapLocation,
                                );
                                currentUserLocationValue = location;
                                _model.setLoc = location;
                                _model.googleMapsCenter = location;
                                safeSetState(() {});
                                final controller =
                                    await _model.googleMapsController.future;
                                await controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    location.toGoogleMaps(),
                                    14.0,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (mapServices.isEmpty)
                          Positioned(
                            left: 24.0,
                            right: 24.0,
                            top: 88.0,
                            child: PointerInterceptor(
                              intercepting: isWeb,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Text(
                                  'У найденных услуг пока нет адресов на карте.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        if (_model.choosenServ != null)
                          Positioned(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                            child: PointerInterceptor(
                              intercepting: isWeb,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.0),
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
                                  model: _model.specialistServiceCardMapModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SpecialistServiceCardMapWidget(
                                    servDoc: _model.choosenServ!,
                                  ),
                                ),
                              ),
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
