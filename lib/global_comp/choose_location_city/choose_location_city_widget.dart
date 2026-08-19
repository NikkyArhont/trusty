import '/backend/backend.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/city_item/city_item_widget.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
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
    this.addressMode = false,
    this.initialPlace,
  });

  final bool? edit;
  final bool addressMode;
  final PlaceStruct? initialPlace;

  static String routeName = 'chooseLocationCity';
  static String routePath = '/chooseLocationCity';

  @override
  State<ChooseLocationCityWidget> createState() =>
      _ChooseLocationCityWidgetState();
}

class _ChooseLocationCityWidgetState extends State<ChooseLocationCityWidget> {
  late ChooseLocationCityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _searchRunId = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChooseLocationCityModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    if (!widget.addressMode) {
      final currentCity =
          widget.initialPlace ?? FFAppState().globalFilter.place;
      if (currentCity.title.trim().isNotEmpty) {
        _model.choosenPlace = currentCity;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _ensureCityList() {
    if (FFAppState().listRUCities.isNotEmpty) {
      return;
    }

    FFAppState().listRUCities =
        functions
            .createCityList(FFAppState().listCityVocab)
            ?.toList()
            .cast<PlaceStruct>() ??
        [];
  }

  List<PlaceStruct> _localCityResults(String query) {
    _ensureCityList();
    return functions
            .searchCityText(FFAppState().listRUCities.toList(), query)
            ?.toList()
            .cast<PlaceStruct>() ??
        [];
  }

  List<PlaceStruct> _uniquePlaces(List<PlaceStruct> places) {
    final seen = <String>{};
    final result = <PlaceStruct>[];
    for (final place in places) {
      final key = place.id.trim().isNotEmpty
          ? place.id.trim()
          : '${place.title.trim()}|${place.description.trim()}';
      if (key.trim().isEmpty || seen.contains(key)) {
        continue;
      }
      seen.add(key);
      result.add(place);
    }
    return result;
  }

  PlaceStruct? _addressSearchCity() {
    final initialCity = widget.initialPlace;
    if (initialCity != null && initialCity.title.trim().isNotEmpty) {
      return initialCity;
    }
    final filterCity = FFAppState().globalFilter.place;
    return filterCity.title.trim().isNotEmpty ? filterCity : null;
  }

  String _addressSearchText(String query) {
    final city = _addressSearchCity()?.title.trim() ?? '';
    return city.isNotEmpty ? '$city, $query' : query;
  }

  String _shortAddressTitle(String value) {
    final city = _addressSearchCity()?.title.trim() ?? '';
    final parts = value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .where(
          (part) =>
              !RegExp(r'^\d{5,6}$').hasMatch(part) &&
              part.toLowerCase() != 'россия',
        )
        .toList();

    if (city.isNotEmpty) {
      final cityIndex = parts.indexWhere(
        (part) => part.toLowerCase() == city.toLowerCase(),
      );
      if (cityIndex >= 0) {
        return parts.take(cityIndex + 1).join(', ');
      }
      return [...parts.take(2), city].join(', ');
    }

    return parts.take(3).join(', ');
  }

  Future<void> _searchPlaces(String value) async {
    final runId = ++_searchRunId;
    final query = value.trim();

    _model.choosenPlace = null;
    if (query.isEmpty) {
      _model.searchResult = [];
      _model.isSearching = false;
      _model.searchCompleted = false;
      safeSetState(() {});
      return;
    }

    if (widget.addressMode && _addressSearchCity() == null) {
      _model.searchResult = [];
      _model.isSearching = false;
      _model.searchCompleted = true;
      safeSetState(() {});
      return;
    }

    final localCities = widget.addressMode
        ? <PlaceStruct>[]
        : _localCityResults(query);
    _model.searchResult = [];
    _model.isSearching = widget.addressMode;
    _model.searchCompleted = false;
    safeSetState(() {});

    if (widget.addressMode) {
      final searchText = _addressSearchText(query);
      var apiResults = <PlaceStruct>[];
      var fallbackResults = <PlaceStruct>[];

      try {
        _model.addressSearchResult = await AdresCall.call(
          search: searchText,
        ).timeout(const Duration(seconds: 6));
        if (runId != _searchRunId) {
          return;
        }

        if (_model.addressSearchResult?.succeeded ?? false) {
          apiResults =
              AdresCall.places(
                _model.addressSearchResult?.jsonBody,
                cityId: _addressSearchCity()?.cityId,
              ).where((place) {
                final cityName = _addressSearchCity()!.title
                    .trim()
                    .toLowerCase();
                final addressText = '${place.title}, ${place.description}'
                    .toLowerCase();
                return addressText.contains(cityName);
              }).toList();
        }

        if (apiResults.isEmpty) {
          final geocodeResult = await GeocodeCall.call(
            adress: searchText,
          ).timeout(const Duration(seconds: 6));
          if (runId != _searchRunId) {
            return;
          }

          final formattedAddress = GeocodeCall.adressTitle(
            geocodeResult.jsonBody,
          );
          final lat = GeocodeCall.lat(geocodeResult.jsonBody);
          final lng = GeocodeCall.lng(geocodeResult.jsonBody);
          if ((geocodeResult.succeeded) &&
              formattedAddress != null &&
              formattedAddress.trim().isNotEmpty) {
            fallbackResults = [
              PlaceStruct(
                id: GeocodeCall.adresID(geocodeResult.jsonBody) ?? '',
                title: _shortAddressTitle(formattedAddress),
                description: '',
                cityId: _addressSearchCity()?.cityId ?? '',
                location: functions.dobleTOloc(lat, lng),
              ),
            ];
          }
        }
      } catch (_) {
        apiResults = [];
        fallbackResults = [];
      }

      if (runId != _searchRunId) {
        return;
      }
      _model.searchResult = _uniquePlaces([...apiResults, ...fallbackResults]);
    } else {
      _model.searchResult = localCities;
    }

    if (runId != _searchRunId) {
      return;
    }
    _model.isSearching = false;
    _model.searchCompleted = true;
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
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
                          wrapWithModel(
                            model: _model.navBackModel,
                            updateCallback: () => safeSetState(() {}),
                            child: NavBackWidget(),
                          ),
                          const Spacer(),
                        ],
                      ),
                      Container(height: 16.0),
                      Text(
                        widget.addressMode
                            ? 'Выберите адрес'
                            : FFLocalizations.of(
                                context,
                              ).getText('c4xq9wb4' /* Выберите свой город */),
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
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(
                                context,
                              ).headlineMedium.fontWeight,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).headlineMedium.fontStyle,
                            ),
                      ),
                      Text(
                        widget.addressMode
                            ? 'Начните вводить улицу и выберите подходящий адрес'
                            : FFLocalizations.of(context).getText(
                                'ie17ultr' /* Чтобы найти услуги и клиентов ... */,
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
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(
                            context,
                          ).bodyMedium.fontWeight,
                          fontStyle: FlutterFlowTheme.of(
                            context,
                          ).bodyMedium.fontStyle,
                        ),
                      ),
                      if (widget.addressMode)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 12.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).divider,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 22.0,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  _addressSearchCity() == null
                                      ? 'Город оказания услуг не выбран'
                                      : 'Поиск адреса в городе: ${_addressSearchCity()!.title}',
                                  style: FlutterFlowTheme.of(context).bodyMedium
                                      .override(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
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
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _model.textController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                focusNode: _model.textFieldFocusNode,
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
                                  hintText: widget.addressMode
                                      ? 'Введите улицу и дом'
                                      : FFLocalizations.of(context).getText(
                                          'xamu0jwy' /* Введите название */,
                                        ),
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
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondary,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).primary,
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
                                cursorColor: FlutterFlowTheme.of(
                                  context,
                                ).primaryText,
                                onTapOutside: (_) => FocusManager
                                    .instance
                                    .primaryFocus
                                    ?.unfocus(),
                                enableInteractiveSelection: true,
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            FilledButton.icon(
                              onPressed:
                                  widget.addressMode &&
                                      _addressSearchCity() == null
                                  ? null
                                  : () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      await _searchPlaces(
                                        _model.textController.text,
                                      );
                                    },
                              icon: const Icon(
                                Icons.search_rounded,
                                size: 20.0,
                              ),
                              label: const Text('Поиск'),
                              style: FilledButton.styleFrom(
                                backgroundColor: FlutterFlowTheme.of(
                                  context,
                                ).primary,
                                foregroundColor: FlutterFlowTheme.of(
                                  context,
                                ).info,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      if (_model.isSearching)
                        Text(
                          'Ищем...',
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
                      if (!_model.isSearching &&
                          _model.searchCompleted &&
                          _model.searchResult.isEmpty &&
                          _model.choosenPlace == null)
                        Text(
                          'Ничего не найдено',
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
                      padding: EdgeInsetsDirectional.fromSTEB(
                        24.0,
                        0.0,
                        24.0,
                        0.0,
                      ),
                      child: Builder(
                        builder: (context) {
                          final searchREsult = _model.searchResult.toList();

                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
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
                                  if (widget.addressMode) {
                                    _model.addressDetailsResult =
                                        await IdToGeoCall.call(
                                          placeId: searchREsultItem.id,
                                        );
                                    final geocodeResult = await GeocodeCall.call(
                                      adress:
                                          '${searchREsultItem.title}, ${searchREsultItem.description}',
                                    );
                                    final ruFormattedAddress =
                                        GeocodeCall.adressTitle(
                                          geocodeResult.jsonBody,
                                        );
                                    final geocodeLat = GeocodeCall.lat(
                                      geocodeResult.jsonBody,
                                    );
                                    final geocodeLng = GeocodeCall.lng(
                                      geocodeResult.jsonBody,
                                    );
                                    final detailsLat = IdToGeoCall.lat(
                                      _model.addressDetailsResult?.jsonBody,
                                    );
                                    final detailsLng = IdToGeoCall.lng(
                                      _model.addressDetailsResult?.jsonBody,
                                    );
                                    final latitude =
                                        detailsLat ??
                                        geocodeLat ??
                                        searchREsultItem.location?.latitude;
                                    final longitude =
                                        detailsLng ??
                                        geocodeLng ??
                                        searchREsultItem.location?.longitude;
                                    if (latitude == null || longitude == null) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Не удалось определить координаты адреса. Выберите другой вариант.',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    _model.choosenPlace = PlaceStruct(
                                      title:
                                          (geocodeResult.succeeded
                                                      ? ruFormattedAddress
                                                      : null)
                                                  ?.trim()
                                                  .isNotEmpty ==
                                              true
                                          ? _shortAddressTitle(
                                              ruFormattedAddress!.trim(),
                                            )
                                          : searchREsultItem.description
                                                .trim()
                                                .isNotEmpty
                                          ? _shortAddressTitle(
                                              '${searchREsultItem.title}, ${searchREsultItem.description}',
                                            )
                                          : searchREsultItem.title,
                                      description: searchREsultItem.description,
                                      id: searchREsultItem.id,
                                      cityId:
                                          _addressSearchCity()?.cityId ??
                                          searchREsultItem.cityId,
                                      location: LatLng(latitude, longitude),
                                    );
                                  } else {
                                    _model.choosenPlace = searchREsultItem;
                                  }
                                  if (!widget.addressMode) {
                                    _model.searchResult = [];
                                  }
                                  _model.isSearching = false;
                                  _model.searchCompleted = false;
                                  safeSetState(() {});
                                  if (!widget.addressMode) {
                                    safeSetState(() {
                                      _model.textController?.clear();
                                    });
                                  }
                                },
                                child: CityItemWidget(
                                  key: Key(
                                    'Keyw3i_${searchREsultIndex}_of_${searchREsult.length}',
                                  ),
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
                    onPressed:
                        (_model.choosenPlace == null ||
                            (widget.addressMode &&
                                _model.choosenPlace?.location == null))
                        ? null
                        : () async {
                            if (widget.addressMode) {
                              FFAppState().tempServiceAddress =
                                  _model.choosenPlace;
                              context.safePop();
                            } else {
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
                            }
                          },
                    text: FFLocalizations.of(
                      context,
                    ).getText('hfwzvn2l' /* Подтвердить */),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        20.0,
                        0.0,
                        20.0,
                        0.0,
                      ),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                      ),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: GoogleFonts.jetBrainsMono(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
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
      ),
    );
  }
}
