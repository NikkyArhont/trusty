import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
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
import 'package:provider/provider.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/share_prompt/share_prompt_service.dart';
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
  static const int _servicesPageSize = 12;

  late MainModel _model;
  int _visibleServicesCount = _servicesPageSize;
  int _servicesShuffleSeed = DateTime.now().microsecondsSinceEpoch;
  late Stream<List<ServiceRecord>> _servicesStream;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<List<ServiceRecord>> _createServicesStream() => queryServiceRecord();

  Future<void> _refreshServices() async {
    try {
      await ServiceRecord.collection.get(
        const GetOptions(source: Source.server),
      );
      if (!mounted) return;
      safeSetState(() {
        _visibleServicesCount = _servicesPageSize;
        _servicesShuffleSeed = DateTime.now().microsecondsSinceEpoch;
        _servicesStream = _createServicesStream();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить услуги. Проверьте интернет.'),
        ),
      );
    }
  }

  void _selectCategory(String categoryKey) {
    if (FFAppState().globalFilter.catKey == categoryKey) {
      return;
    }
    FFAppState().updateGlobalFilterStruct(
      (filter) => filter..catKey = categoryKey,
    );
    safeSetState(() {
      _visibleServicesCount = _servicesPageSize;
    });
  }

  bool _matchesSelectedCity(ServiceRecord service) {
    final selectedCity = FFAppState().globalFilter.place;
    final selectedCityId = selectedCity.cityId.trim();
    final selectedCityTitle = selectedCity.title.trim().toLowerCase();
    if (selectedCityId.isEmpty && selectedCityTitle.isEmpty) {
      return true;
    }

    final serviceCityId = service.place.cityId.trim();
    if (selectedCityId.isNotEmpty && serviceCityId == selectedCityId) {
      return true;
    }

    if (serviceCityId.isEmpty && selectedCityTitle.isNotEmpty) {
      final servicePlaceText =
          '${service.place.title}, ${service.place.description}'.toLowerCase();
      return servicePlaceText.contains(selectedCityTitle);
    }

    return false;
  }

  int _compareServicesRandomly(ServiceRecord first, ServiceRecord second) {
    final firstRank = Object.hash(_servicesShuffleSeed, first.reference.id);
    final secondRank = Object.hash(_servicesShuffleSeed, second.reference.id);
    final rankComparison = firstRank.compareTo(secondRank);
    return rankComparison != 0
        ? rankComparison
        : first.reference.id.compareTo(second.reference.id);
  }

  bool _hasRecommendations(ServiceRecord service) =>
      service.recommendations.isNotEmpty ||
      service.recommenderPhoneHashes.any((hash) => hash.trim().isNotEmpty) ||
      service.recommenderPhones.any((phone) => phone.trim().isNotEmpty);

  int _compareServicesForMain(ServiceRecord first, ServiceRecord second) {
    if (!currentUserIsRegistered) {
      final firstHasRecommendations = _hasRecommendations(first);
      final secondHasRecommendations = _hasRecommendations(second);
      if (firstHasRecommendations != secondHasRecommendations) {
        return firstHasRecommendations ? -1 : 1;
      }
    }
    return _compareServicesRandomly(first, second);
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
    return upperBound.ceilToDouble() + 32.0;
  }

  Widget _buildCategoryMenu(BuildContext context) {
    final categories = FFAppState().presetCategory.toList()
      ..sort((first, second) {
        String sortKey(String value) =>
            value.toLowerCase().replaceAll('ё', 'е');
        return sortKey(first.titleRU).compareTo(sortKey(second.titleRU));
      });
    final allLabel = FFLocalizations.of(context).getText('of2007qn' /* Все */);
    final labels = <String>[
      allLabel,
      ...categories.map((category) => category.titleRU),
    ];
    final chips = <Widget>[
      _buildCategoryChip(
        context: context,
        label: allLabel,
        selected: FFAppState().globalFilter.catKey.isEmpty,
        onTap: () => _selectCategory(''),
      ),
      ...categories.map(
        (category) => _buildCategoryChip(
          context: context,
          label: category.titleRU,
          selected: FFAppState().globalFilter.catKey == category.key,
          onTap: () => _selectCategory(category.key),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth - 24.0;
          final wrapWidth = _twoRowCategoryWrapWidth(
            context,
            labels,
            viewportWidth,
          );
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: wrapWidth,
              child: Wrap(spacing: 8.0, runSpacing: 8.0, children: chips),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainModel());
    _servicesStream = _createServicesStream();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPushNotificationsForCurrentUser(
        requestPermission: !currentUserIsAnonymous,
      );
      if (currentUserIsRegistered) {
        Future.delayed(
          const Duration(milliseconds: 800),
          showSharePromptIfEligible,
        );
      }
    });
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
      stream: _servicesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 40.0),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Не удалось загрузить рекомендации',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    FilledButton(
                      onPressed: () => safeSetState(() {
                        _servicesStream = _createServicesStream();
                      }),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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
        final cityServiceRecordList =
            (snapshot.data ?? [])
                .where((service) => service.status == ServiceStatus.show)
                .where(_matchesSelectedCity)
                .toList()
              ..sort(_compareServicesForMain);
        final selectedCategoryKey = FFAppState().globalFilter.catKey;
        final mainServiceRecordList = cityServiceRecordList
            .where(
              (service) =>
                  selectedCategoryKey.isEmpty ||
                  service.categoryKey == selectedCategoryKey,
            )
            .toList();

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshServices,
                  color: FlutterFlowTheme.of(context).primary,
                  child: SingleChildScrollView(
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(
                              context,
                            ).primaryBackground,
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              24.0,
                              16.0,
                              8.0,
                            ),
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
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFLocalizations.of(
                                              context,
                                            ).getText('6ef5ecez' /* Сарафан */),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 32.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FlutterFlowIconButton(
                                          borderColor: FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                          borderRadius: 12.0,
                                          borderWidth: 1.0,
                                          buttonSize: 40.0,
                                          fillColor: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                          icon: Icon(
                                            Icons.favorite_border,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            context.pushNamed(
                                              FavoritesWidget.routeName,
                                            );
                                          },
                                        ),
                                        FlutterFlowIconButton(
                                          borderColor: FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                          borderRadius: 12.0,
                                          borderWidth: 1.0,
                                          buttonSize: 40.0,
                                          fillColor: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                          icon: Icon(
                                            Icons.location_on,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            context.pushNamed(
                                              ChooseLocationCityWidget
                                                  .routeName,
                                              queryParameters: {
                                                'edit': serializeParam(
                                                  false,
                                                  ParamType.bool,
                                                ),
                                              }.withoutNulls,
                                            );
                                          },
                                        ),
                                        FlutterFlowIconButton(
                                          borderColor: FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                          borderRadius: 12.0,
                                          borderWidth: 1.0,
                                          buttonSize: 40.0,
                                          fillColor: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                          icon: Icon(
                                            Icons.search_rounded,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            context.pushNamed(
                                              SearchWidget.routeName,
                                            );
                                          },
                                        ),
                                        FlutterFlowIconButton(
                                          borderColor: FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                          borderRadius: 12.0,
                                          borderWidth: 1.0,
                                          buttonSize: 40.0,
                                          fillColor: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                          icon: Icon(
                                            Icons.map_outlined,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            context.pushNamed(
                                              SearchResultWidget.routeName,
                                              queryParameters: {
                                                'listResult': serializeParam(
                                                  cityServiceRecordList,
                                                  ParamType.Document,
                                                  isList: true,
                                                ),
                                                'showCategories':
                                                    serializeParam(
                                                      true,
                                                      ParamType.bool,
                                                    ),
                                              }.withoutNulls,
                                              extra: <String, dynamic>{
                                                'listResult':
                                                    cityServiceRecordList,
                                              },
                                            );
                                          },
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(height: 12.0)),
                            ),
                          ),
                        ),
                        _buildCategoryMenu(context),
                        Container(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              12.0,
                              0.0,
                              12.0,
                              0.0,
                            ),
                            child: Builder(
                              builder: (context) {
                                final mainVar = mainServiceRecordList
                                    .take(_visibleServicesCount)
                                    .toList();
                                final hasMore =
                                    mainVar.length <
                                    mainServiceRecordList.length;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MasonryGridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                          ),
                                      crossAxisSpacing: 10.0,
                                      mainAxisSpacing: 10.0,
                                      itemCount: mainVar.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, mainVarIndex) {
                                        final mainVarItem =
                                            mainVar[mainVarIndex];
                                        return ServiceCardClientWidget(
                                          key: Key(
                                            'Key55p_${mainVarIndex}_of_${mainVar.length}',
                                          ),
                                          servicedoc: mainVarItem,
                                        );
                                      },
                                    ),
                                    if (hasMore)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 16.0,
                                        ),
                                        child: FFButtonWidget(
                                          onPressed: () => safeSetState(() {
                                            _visibleServicesCount +=
                                                _servicesPageSize;
                                          }),
                                          text: 'Показать ещё',
                                          options: FFButtonOptions(
                                            height: 44.0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24.0,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                            textStyle:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.override(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).info,
                                                  letterSpacing: 0.0,
                                                ),
                                            elevation: 0.0,
                                            borderRadius: BorderRadius.circular(
                                              22.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 0.0)).addToEnd(SizedBox(height: 120.0)),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.menuModel,
                    updateCallback: () => safeSetState(() {}),
                    child: MenuWidget(currentPage: Menu.main),
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
