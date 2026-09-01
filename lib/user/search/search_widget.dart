import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/app_page_header/app_page_header.dart';
import '/user/service_card_client/service_card_client_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:text_search/text_search.dart';
import 'search_model.dart';
export 'search_model.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  static String routeName = 'Search';
  static String routePath = '/search';

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late SearchModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.setLoc = FFAppState().globalFilter.place.location;
      safeSetState(() {});
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  List<ServiceRecord> _searchServices(
    List<ServiceRecord> services,
    String query,
  ) {
    final searchQuery = query.trim();
    if (searchQuery.isEmpty) {
      return services;
    }

    return TextSearch(
      services
          .map(
            (record) => TextSearchItem.fromTerms(record, [
              record.title,
              record.description,
              record.categoryKey,
            ]),
          )
          .toList(),
    ).search(searchQuery).map((r) => r.object).toList();
  }

  void _activateSearch(String query, {bool saveHistory = true}) {
    final searchQuery = query.trim();
    _model.searchActive = true;

    if (saveHistory &&
        searchQuery.isNotEmpty &&
        !FFAppState().previosSearch.contains(searchQuery)) {
      FFAppState().addToPreviosSearch(searchQuery);
    }
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: selected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : FlutterFlowTheme.of(context).secondaryText,
            fontWeight: FontWeight.w500,
            fontSize: 13.0,
          ),
        ),
      ),
    );
  }

  double _categoryChipWidth(BuildContext context, String label) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    return painter.width + 30.0;
  }

  int _categoryWrapRowCount(
    List<double> itemWidths,
    double maxWidth, {
    double spacing = 8.0,
  }) {
    var rows = 1;
    var usedWidth = 0.0;

    for (final itemWidth in itemWidths) {
      if (usedWidth == 0.0) {
        usedWidth = itemWidth;
      } else if (usedWidth + spacing + itemWidth <= maxWidth) {
        usedWidth += spacing + itemWidth;
      } else {
        rows += 1;
        usedWidth = itemWidth;
      }
    }

    return rows;
  }

  double _twoRowCategoryWrapWidth(
    BuildContext context,
    List<String> labels,
    double viewportWidth,
  ) {
    final itemWidths = labels
        .map((label) => _categoryChipWidth(context, label))
        .toList();
    final totalWidth =
        itemWidths.fold<double>(0.0, (total, width) => total + width) +
        (itemWidths.length - 1) * 8.0;
    var lowerBound = viewportWidth;
    var upperBound = totalWidth > viewportWidth ? totalWidth : viewportWidth;

    for (var iteration = 0; iteration < 16; iteration++) {
      final candidate = (lowerBound + upperBound) / 2;
      if (_categoryWrapRowCount(itemWidths, candidate) <= 2) {
        upperBound = candidate;
      } else {
        lowerBound = candidate;
      }
    }

    // Text rendering in the browser can be a few pixels wider than TextPainter
    // reports. Keep a small reserve so the final chip stays on the second row.
    return upperBound.ceilToDouble() + 32.0;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return StreamBuilder<List<ServiceRecord>>(
      stream: queryServiceRecord(
        queryBuilder: (serviceRecord) => serviceRecord
            .where(
              'place.cityId',
              isEqualTo: FFAppState().globalFilter.place.cityId != ''
                  ? FFAppState().globalFilter.place.cityId
                  : null,
            )
            .where(
              'categoryKey',
              isEqualTo: FFAppState().globalFilter.catKey != ''
                  ? FFAppState().globalFilter.catKey
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
        final searchServiceRecordList = (snapshot.data ?? [])
            .where((service) => service.status == ServiceStatus.show)
            .toList();
        final visibleSearchResults = _model.searchActive
            ? _searchServices(
                searchServiceRecordList,
                _model.textController.text,
              )
            : searchServiceRecordList;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const AppPageHeader(title: 'Поиск', showBack: true),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          16.0,
                          0.0,
                          16.0,
                          0.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Container(
                                width: 400.0,
                                height: 40.0,
                                child: TextFormField(
                                  controller: _model.textController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  focusNode: _model.textFieldFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.textController',
                                    Duration(milliseconds: 100),
                                    () => safeSetState(() {}),
                                  ),
                                  autofocus: false,
                                  enabled: true,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                          16.0,
                                          8.0,
                                          16.0,
                                          8.0,
                                        ),
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                          ),
                                          fontSize: 16.0,
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
                                    ).getText('78vel1nk' /* Поиск услуг... */),
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,
                                          ),
                                          fontSize: 16.0,
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
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primary,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(
                                      context,
                                    ).secondaryBackground,
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20.0,
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 40.0,
                                      minHeight: 40.0,
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                        fontSize: 16.0,
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
                                  enableInteractiveSelection: true,
                                  validator: _model.textControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed:
                                  _model.textController.text.trim().isEmpty
                                  ? null
                                  : () async {
                                      safeSetState(() {
                                        _activateSearch(
                                          _model.textController.text,
                                        );
                                      });
                                    },
                              text: 'Найти',
                              options: FFButtonOptions(
                                width: 76.0,
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0,
                                  0.0,
                                  12.0,
                                  0.0,
                                ),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                ),
                                color: FlutterFlowTheme.of(context).primary,
                                disabledColor: FlutterFlowTheme.of(
                                  context,
                                ).alternate,
                                disabledTextColor: FlutterFlowTheme.of(
                                  context,
                                ).secondaryText,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).titleSmall.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).info,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).titleSmall.fontStyle,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                safeSetState(() {
                                  _model.textController?.clear();
                                  _model.simpleSearchResults = [];
                                  _model.searchActive = false;
                                });
                              },
                              child: Text(
                                FFLocalizations.of(
                                  context,
                                ).getText('6mio2rsv' /* Очистить */),
                                style: FlutterFlowTheme.of(context).labelLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).labelLarge.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelLarge.fontStyle,
                                      lineHeight: 1.3,
                                    ),
                              ),
                            ),
                          ].divide(SizedBox(width: 8.0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Builder(
                          builder: (context) {
                            final presetCats =
                                FFAppState().presetCategory.toList()..sort((
                                  first,
                                  second,
                                ) {
                                  String sortKey(String value) =>
                                      value.toLowerCase().replaceAll('ё', 'е');
                                  return sortKey(
                                    first.titleRU,
                                  ).compareTo(sortKey(second.titleRU));
                                });
                            final allLabel = FFLocalizations.of(
                              context,
                            ).getText('1hsgtllu' /* Все */);
                            final labels = <String>[
                              allLabel,
                              ...presetCats.map((category) => category.titleRU),
                            ];
                            final chips = <Widget>[
                              _buildCategoryChip(
                                context: context,
                                label: allLabel,
                                selected:
                                    FFAppState().globalFilter.catKey.isEmpty,
                                onTap: () {
                                  FFAppState().updateGlobalFilterStruct(
                                    (filter) => filter..catKey = '',
                                  );
                                  safeSetState(() {});
                                },
                              ),
                              ...presetCats.map(
                                (category) => _buildCategoryChip(
                                  context: context,
                                  label: category.titleRU,
                                  selected:
                                      FFAppState().globalFilter.catKey ==
                                      category.key,
                                  onTap: () {
                                    FFAppState().updateGlobalFilterStruct(
                                      (filter) => filter..catKey = category.key,
                                    );
                                    safeSetState(() {});
                                  },
                                ),
                              ),
                            ];

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final viewportWidth =
                                    constraints.maxWidth - 24.0;
                                final wrapWidth = _twoRowCategoryWrapWidth(
                                  context,
                                  labels,
                                  viewportWidth,
                                );

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: SizedBox(
                                    width: wrapWidth,
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: chips,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (_model.searchActive)
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24.0,
                              0.0,
                              0.0,
                              0.0,
                            ),
                            child: Text(
                              'Найдено: ${visibleSearchResults.length.toString()}',
                              style: FlutterFlowTheme.of(context).titleMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).titleMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).titleMedium.fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ),
                        ),
                      if ((FFAppState().previosSearch.isNotEmpty) &&
                          !_model.searchActive)
                        Container(
                          decoration: BoxDecoration(),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24.0,
                              0.0,
                              24.0,
                              0.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'erpbucl0' /* История поиска */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).titleMedium.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).titleMedium.fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        FFAppState().previosSearch = [];
                                        safeSetState(() {});
                                      },
                                      child: Text(
                                        FFLocalizations.of(
                                          context,
                                        ).getText('sgi0zc0m' /* Очистить */),
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).labelLarge.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelLarge.fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) {
                                    final searchHistory = FFAppState()
                                        .previosSearch
                                        .toList();

                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: searchHistory.length,
                                      itemBuilder: (context, searchHistoryIndex) {
                                        final searchHistoryItem =
                                            searchHistory[searchHistoryIndex];
                                        return Container(
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  0.0,
                                                  8.0,
                                                  0.0,
                                                  8.0,
                                                ),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                safeSetState(() {
                                                  _model.textController?.text =
                                                      searchHistoryItem;
                                                  _activateSearch(
                                                    searchHistoryItem,
                                                    saveHistory: false,
                                                  );
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.history_rounded,
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).hint,
                                                    size: 20.0,
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      searchHistoryItem,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).bodyMedium.override(
                                                            font: GoogleFonts.inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
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
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                            lineHeight: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      FFAppState()
                                                          .removeFromPreviosSearch(
                                                            searchHistoryItem,
                                                          );
                                                      safeSetState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).hint,
                                                      size: 18.0,
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 16.0)),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      if (_model.searchActive ||
                          FFAppState().previosSearch.isEmpty)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            12.0,
                            0.0,
                            12.0,
                            0.0,
                          ),
                          child: Builder(
                            builder: (context) {
                              final serv = visibleSearchResults.toList();

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
                                  return ServiceCardClientWidget(
                                    key: Key(
                                      'Keyq2m_${servIndex}_of_${serv.length}',
                                    ),
                                    servicedoc: servItem,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ].divide(SizedBox(height: 12.0)).addToEnd(SizedBox(height: 72.0)),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_model.searchActive)
                        FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(
                              SearchResultWidget.routeName,
                              queryParameters: {
                                'listResult': serializeParam(
                                  visibleSearchResults,
                                  ParamType.Document,
                                  isList: true,
                                ),
                              }.withoutNulls,
                              extra: <String, dynamic>{
                                'listResult': visibleSearchResults,
                              },
                            );
                          },
                          text: FFLocalizations.of(context).getText(
                            'xzz5cq7c' /*  Посмотреть результаты на карт... */,
                          ),
                          icon: Icon(Icons.map, size: 24.0),
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
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).titleSmall.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).info,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).titleSmall.fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                    ].divide(SizedBox(height: 12.0)),
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
