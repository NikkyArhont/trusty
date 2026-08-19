import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/share_prompt/share_prompt_service.dart';
import '/backend/schema/enums/enums.dart';
import '/components/stat_card_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/global_comp/menu/menu_widget.dart';
import '/master/no_service/no_service_widget.dart';
import '/master/notifications/master_notifications_widget.dart';
import '/master/specialist_service_card/specialist_service_card_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'specialist_dashboard_model.dart';
export 'specialist_dashboard_model.dart';

class SpecialistDashboardWidget extends StatefulWidget {
  const SpecialistDashboardWidget({super.key});

  static String routeName = 'SpecialistDashboard';
  static String routePath = '/specialistDashboard';

  @override
  State<SpecialistDashboardWidget> createState() =>
      _SpecialistDashboardWidgetState();
}

class _SpecialistDashboardWidgetState extends State<SpecialistDashboardWidget> {
  late SpecialistDashboardModel _model;
  String _selectedTimeFilter = 'Неделя';
  String _selectedMetric = 'Клиенты';

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _weeklyDateLabel(BuildContext context, DateTime date) {
    final rawMonth = dateTimeFormat(
      'MMM',
      date,
      locale: FFLocalizations.of(context).languageCode,
    ).replaceAll('.', '').trim();
    final month = rawMonth.isEmpty
        ? ''
        : '${rawMonth[0].toUpperCase()}${rawMonth.substring(1)}.';
    return '${date.day}\n$month';
  }

  Future<void> _refreshDashboard() async {
    try {
      final userRef = currentUserReference;
      if (userRef == null) return;

      final userSnapshot = await userRef.get(
        const GetOptions(source: Source.server),
      );
      await ServiceRecord.collection
          .where('owner', isEqualTo: userRef)
          .get(const GetOptions(source: Source.server));
      await RecordsRecord.collection
          .where('master', isEqualTo: userRef)
          .get(const GetOptions(source: Source.server));

      if (!mounted) return;
      if (userSnapshot.exists) {
        currentUserDocument = UserRecord.fromSnapshot(userSnapshot);
      }
      safeSetState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить панель. Проверьте интернет.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpecialistDashboardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPushNotificationsForCurrentUser();
      initPushNotificationNavigationForMaster();
      Future.delayed(
        const Duration(milliseconds: 800),
        showSharePromptIfEligible,
      );
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshDashboard,
              color: FlutterFlowTheme.of(context).primary,
              child: SingleChildScrollView(
                primary: false,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          24.0,
                          32.0,
                          24.0,
                          16.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FFLocalizations.of(
                                      context,
                                    ).getText('ms588699' /* Панель */),
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
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
                                  AuthUserStreamWidget(
                                    builder: (context) => Text(
                                      valueOrDefault<String>(
                                        currentUserDocument?.masterData?.title,
                                        'Без названия',
                                      ),
                                      maxLines: 3,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.normal,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).bodyMedium.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.fontStyle,
                                            lineHeight: 1.5,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const MasterNotificationsBell(),
                                const SizedBox(width: 8.0),
                                AuthUserStreamWidget(
                                  builder: (context) => Container(
                                    width: 48.0,
                                    height: 48.0,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: CachedNetworkImage(
                                      fadeInDuration: Duration(milliseconds: 0),
                                      fadeOutDuration: Duration(
                                        milliseconds: 0,
                                      ),
                                      imageUrl: currentUserDocument!
                                          .masterData
                                          .mainPhoto,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 144,
                                      memCacheHeight: 144,
                                      maxWidthDiskCache: 288,
                                      maxHeightDiskCache: 288,
                                      errorWidget:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                'assets/images/error_image.png',
                                                fit: BoxFit.cover,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        24.0,
                        0.0,
                        24.0,
                        16.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: ['Неделя', 'Месяц']
                            .map(
                              (filter) => Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0,
                                    0.0,
                                    filter == 'Месяц' ? 0.0 : 8.0,
                                    0.0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedTimeFilter = filter;
                                      });
                                    },
                                    child: Container(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      decoration: BoxDecoration(
                                        color: _selectedTimeFilter == filter
                                            ? FlutterFlowTheme.of(
                                                context,
                                              ).primary
                                            : FlutterFlowTheme.of(
                                                context,
                                              ).secondaryBackground,
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        border: Border.all(
                                          color: _selectedTimeFilter == filter
                                              ? Colors.transparent
                                              : FlutterFlowTheme.of(
                                                  context,
                                                ).divider,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Text(
                                        filter,
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    _selectedTimeFilter ==
                                                        filter
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                              color:
                                                  _selectedTimeFilter == filter
                                                  ? FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryBackground
                                                  : FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryText,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    StreamBuilder<List<RecordsRecord>>(
                      stream: queryRecordsRecord(
                        queryBuilder: (r) =>
                            r.where('master', isEqualTo: currentUserReference),
                      ),
                      builder: (context, recordsSnapshot) {
                        return StreamBuilder<List<ServiceRecord>>(
                          stream: queryServiceRecord(
                            queryBuilder: (s) => s.where(
                              'owner',
                              isEqualTo: currentUserReference,
                            ),
                          ),
                          builder: (context, servicesSnapshot) {
                            final recordsList = (recordsSnapshot.data ?? [])
                                .where(
                                  (record) =>
                                      record.status == RecordStatus.complite,
                                )
                                .toList();
                            final servicesList = servicesSnapshot.data ?? [];

                            DateTime? recordStatisticsDate(
                              RecordsRecord record,
                            ) => record.completedTime ?? record.date;

                            // Time Filter
                            final now = DateTime.now();
                            DateTime? filterStartDate;
                            if (_selectedTimeFilter == 'Неделя') {
                              filterStartDate = now.subtract(
                                const Duration(days: 7),
                              );
                            } else if (_selectedTimeFilter == 'Месяц') {
                              filterStartDate = now.subtract(
                                const Duration(days: 30),
                              );
                            }

                            final filteredRecords = filterStartDate == null
                                ? recordsList
                                : recordsList
                                      .where(
                                        (r) =>
                                            recordStatisticsDate(r) != null &&
                                            recordStatisticsDate(
                                              r,
                                            )!.isAfter(filterStartDate!),
                                      )
                                      .toList();

                            final double visitsCount = filteredRecords.length
                                .toDouble();

                            final Set<String> uniqueClients = {};
                            for (var recordRec in filteredRecords) {
                              final clientId = recordRec.clientPhone.isNotEmpty
                                  ? recordRec.clientPhone
                                  : (recordRec.client?.path ?? '');
                              if (clientId.isNotEmpty) {
                                uniqueClients.add(clientId);
                              }
                            }
                            final double clientsCount = uniqueClients.length
                                .toDouble();

                            final Set<String> filteredRecommenders = {};
                            final Set<String> structPhones = {};
                            for (var serviceRec in servicesList) {
                              for (var rec in serviceRec.recommendations) {
                                if (rec.phone.isNotEmpty) {
                                  structPhones.add(rec.phone);
                                  if (filterStartDate != null &&
                                      rec.date != null) {
                                    if (rec.date!.isAfter(filterStartDate)) {
                                      filteredRecommenders.add(rec.phone);
                                    }
                                  } else {
                                    filteredRecommenders.add(rec.phone);
                                  }
                                }
                              }
                              // Fallback for legacy recommenderPhones that are not in recommendations list
                              for (var phone in serviceRec.recommenderPhones) {
                                if (phone.isNotEmpty &&
                                    !structPhones.contains(phone)) {
                                  filteredRecommenders.add(phone);
                                }
                              }
                            }
                            final double recommendationsCount =
                                filteredRecommenders.length.toDouble();

                            // Chart Data Calculation
                            final xLabels = <String>[];
                            final yData = <double>[];

                            if (_selectedMetric != 'Рекомендации' &&
                                _selectedTimeFilter == 'Неделя') {
                              for (int i = 6; i >= 0; i--) {
                                final day = now.subtract(Duration(days: i));
                                xLabels.add(_weeklyDateLabel(context, day));

                                final dayRecords = recordsList.where((r) {
                                  final recordDate = recordStatisticsDate(r);
                                  if (recordDate == null) return false;
                                  return recordDate.year == day.year &&
                                      recordDate.month == day.month &&
                                      recordDate.day == day.day;
                                }).toList();

                                if (_selectedMetric == 'Посещения') {
                                  yData.add(dayRecords.length.toDouble());
                                } else if (_selectedMetric == 'Клиенты') {
                                  final Set<String> dayClients = {};
                                  for (var r in dayRecords) {
                                    final id = r.clientPhone.isNotEmpty
                                        ? r.clientPhone
                                        : (r.client?.path ?? '');
                                    if (id.isNotEmpty) dayClients.add(id);
                                  }
                                  yData.add(dayClients.length.toDouble());
                                }
                              }
                            } else if (_selectedMetric != 'Рекомендации' &&
                                _selectedTimeFilter == 'Месяц') {
                              for (int i = 29; i >= 0; i--) {
                                final day = now.subtract(Duration(days: i));
                                if (i == 29 || i == 0 || i % 5 == 4) {
                                  xLabels.add(
                                    '${day.day}.${day.month.toString().padLeft(2, '0')}',
                                  );
                                } else {
                                  xLabels.add('');
                                }

                                final dayRecords = recordsList.where((r) {
                                  final recordDate = recordStatisticsDate(r);
                                  if (recordDate == null) return false;
                                  return recordDate.year == day.year &&
                                      recordDate.month == day.month &&
                                      recordDate.day == day.day;
                                }).toList();

                                if (_selectedMetric == 'Посещения') {
                                  yData.add(dayRecords.length.toDouble());
                                } else if (_selectedMetric == 'Клиенты') {
                                  final Set<String> dayClients = {};
                                  for (var r in dayRecords) {
                                    final id = r.clientPhone.isNotEmpty
                                        ? r.clientPhone
                                        : (r.client?.path ?? '');
                                    if (id.isNotEmpty) dayClients.add(id);
                                  }
                                  yData.add(dayClients.length.toDouble());
                                }
                              }
                            }

                            // Chart actual recommendations by day
                            if (_selectedMetric == 'Рекомендации') {
                              if (_selectedTimeFilter == 'Неделя') {
                                for (int i = 6; i >= 0; i--) {
                                  final day = now.subtract(Duration(days: i));
                                  xLabels.add(_weeklyDateLabel(context, day));

                                  final Set<String> dayRecs = {};
                                  for (var s in servicesList) {
                                    for (var r in s.recommendations) {
                                      if (r.phone.isNotEmpty &&
                                          r.date != null &&
                                          r.date!.year == day.year &&
                                          r.date!.month == day.month &&
                                          r.date!.day == day.day) {
                                        dayRecs.add(r.phone);
                                      }
                                    }
                                  }
                                  yData.add(dayRecs.length.toDouble());
                                }
                              } else if (_selectedTimeFilter == 'Месяц') {
                                for (int i = 29; i >= 0; i--) {
                                  final day = now.subtract(Duration(days: i));
                                  if (i == 29 || i == 0 || i % 5 == 4) {
                                    xLabels.add(
                                      '${day.day}.${day.month.toString().padLeft(2, '0')}',
                                    );
                                  } else {
                                    xLabels.add('');
                                  }

                                  final Set<String> dayRecs = {};
                                  for (var s in servicesList) {
                                    for (var r in s.recommendations) {
                                      if (r.phone.isNotEmpty &&
                                          r.date != null &&
                                          r.date!.year == day.year &&
                                          r.date!.month == day.month &&
                                          r.date!.day == day.day) {
                                        dayRecs.add(r.phone);
                                      }
                                    }
                                  }
                                  yData.add(dayRecs.length.toDouble());
                                }
                              }
                            }

                            // Determine MaxY dynamically
                            double maxVal = yData.isEmpty
                                ? 10.0
                                : yData.reduce((a, b) => a > b ? a : b);
                            double maxY = maxVal < 5.0
                                ? 5.0
                                : (maxVal * 1.25).roundToDouble();
                            // Theme Color matching the selected metric
                            Color activeColor;
                            String metricTitle;
                            if (_selectedMetric == 'Клиенты') {
                              activeColor = FlutterFlowTheme.of(
                                context,
                              ).primary;
                              metricTitle = 'Динамика клиентов';
                            } else if (_selectedMetric == 'Посещения') {
                              activeColor = FlutterFlowTheme.of(
                                context,
                              ).success;
                              metricTitle = 'Динамика посещений';
                            } else {
                              activeColor = FlutterFlowTheme.of(
                                context,
                              ).accent3;
                              metricTitle = 'Динамика рекомендаций';
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0,
                                      0.0,
                                      24.0,
                                      0.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedMetric = 'Клиенты';
                                                  });
                                                },
                                                child: wrapWithModel(
                                                  model: _model.statCardModel1,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: StatCardWidget(
                                                    value: clientsCount,
                                                    label: 'Клиенты',
                                                    bgColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).primary.withOpacity(
                                                          _selectedMetric ==
                                                                  'Клиенты'
                                                              ? 0.3
                                                              : 0.12,
                                                        ),
                                                    textColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).primary,
                                                    icon: Icons
                                                        .people_alt_rounded,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedMetric =
                                                        'Посещения';
                                                  });
                                                },
                                                child: wrapWithModel(
                                                  model: _model.statCardModel2,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: StatCardWidget(
                                                    value: visitsCount,
                                                    label: 'Посещения',
                                                    bgColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).success.withOpacity(
                                                          _selectedMetric ==
                                                                  'Посещения'
                                                              ? 0.3
                                                              : 0.12,
                                                        ),
                                                    textColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).success,
                                                    icon: Icons
                                                        .event_available_rounded,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedMetric =
                                                        'Рекомендации';
                                                  });
                                                },
                                                child: wrapWithModel(
                                                  model: _model.statCardModel3,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: StatCardWidget(
                                                    value: recommendationsCount,
                                                    label: 'Рекомендации',
                                                    bgColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).accent3.withOpacity(
                                                          _selectedMetric ==
                                                                  'Рекомендации'
                                                              ? 0.3
                                                              : 0.12,
                                                        ),
                                                    textColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).accent3,
                                                    icon: Icons
                                                        .thumb_up_alt_rounded,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 12.0)),
                                        ),
                                      ].divide(SizedBox(height: 16.0)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Container(
                                    height: 240.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).divider,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                metricTitle,
                                                style:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).labelLarge.override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                          ).primaryText,
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .labelLarge
                                                              .fontStyle,
                                                      lineHeight: 1.3,
                                                    ),
                                              ),
                                              Icon(
                                                Icons.trending_up_rounded,
                                                color: activeColor,
                                                size: 20.0,
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final isWeekly =
                                                    _selectedTimeFilter ==
                                                    'Неделя';
                                                final isMonthly =
                                                    _selectedTimeFilter ==
                                                    'Месяц';
                                                final weeklyBarWidth =
                                                    ((constraints.maxWidth -
                                                                36.0) /
                                                            7.0)
                                                        .clamp(18.0, 44.0)
                                                        .toDouble();
                                                final labelAreaHeight = isWeekly
                                                    ? 44.0
                                                    : 32.0;
                                                final plotHeight =
                                                    (constraints.maxHeight -
                                                            labelAreaHeight)
                                                        .clamp(
                                                          1.0,
                                                          double.infinity,
                                                        );
                                                final minimumBarValue =
                                                    maxY * (3.0 / plotHeight);
                                                final chartYData =
                                                    isWeekly || isMonthly
                                                    ? yData
                                                          .map(
                                                            (value) =>
                                                                value == 0.0
                                                                ? minimumBarValue
                                                                : value,
                                                          )
                                                          .toList()
                                                    : yData;
                                                final barValueLabels = yData
                                                    .map<String?>(
                                                      (value) => value > 0.0
                                                          ? value
                                                                .toInt()
                                                                .toString()
                                                          : null,
                                                    )
                                                    .toList();
                                                final barRadii = yData
                                                    .map(
                                                      (value) =>
                                                          BorderRadius.circular(
                                                            value == 0.0
                                                                ? 1.5
                                                                : isWeekly
                                                                ? 8.0
                                                                : 2.0,
                                                          ),
                                                    )
                                                    .toList();
                                                return FlutterFlowBarChart(
                                                  barData: [
                                                    FFBarChartData(
                                                      yData: chartYData,
                                                      color: activeColor,
                                                    ),
                                                  ],
                                                  xLabels: xLabels,
                                                  barWidth: isWeekly
                                                      ? weeklyBarWidth
                                                      : 6.0,
                                                  barValueLabels:
                                                      barValueLabels,
                                                  barValueTextStyle: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).secondaryText,
                                                    fontSize: isWeekly
                                                        ? 11.0
                                                        : 9.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  barBorderRadius:
                                                      BorderRadius.circular(
                                                        isWeekly ? 8.0 : 2.0,
                                                      ),
                                                  barBorderRadii: barRadii,
                                                  groupSpace: isWeekly
                                                      ? 6.0
                                                      : 4.0,
                                                  alignment: isWeekly
                                                      ? BarChartAlignment
                                                            .spaceAround
                                                      : BarChartAlignment
                                                            .spaceEvenly,
                                                  chartStylingInfo:
                                                      ChartStylingInfo(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        showBorder: false,
                                                      ),
                                                  axisBounds: AxisBounds(
                                                    minY: 0.0,
                                                    maxY: maxY,
                                                  ),
                                                  xAxisLabelInfo: AxisLabelInfo(
                                                    showLabels: true,
                                                    labelTextStyle: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).secondaryText,
                                                      fontSize: isWeekly
                                                          ? 11.0
                                                          : 9.0,
                                                      height: isWeekly
                                                          ? 1.3
                                                          : 1.0,
                                                    ),
                                                    reservedSize: isWeekly
                                                        ? 44.0
                                                        : 32.0,
                                                    labelSpace: isWeekly
                                                        ? 5.0
                                                        : 4.0,
                                                  ),
                                                  yAxisLabelInfo:
                                                      AxisLabelInfo(),
                                                );
                                              },
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 16.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0,
                                      0.0,
                                      24.0,
                                      0.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  0.0,
                                                  0.0,
                                                  0.0,
                                                  16.0,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  FFLocalizations.of(
                                                    context,
                                                  ).getText(
                                                    'w21i75dq' /* Мои услуги */,
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).headlineMedium.override(
                                                        font: GoogleFonts.interTight(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .headlineMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .headlineMedium
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
                                                                .headlineMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .headlineMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            border: Border.all(
                                              color: Color(0xFFDBEAFE),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.info_outline_rounded,
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).primary,
                                                  size: 20.0,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    FFLocalizations.of(
                                                      context,
                                                    ).getText(
                                                      'cj35joe3' /* Вы можете добавить до 5 услуг ... */,
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
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).primary,
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
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 16.0)),
                                            ),
                                          ),
                                        ),
                                        if (servicesList.isEmpty)
                                          NoServiceWidget()
                                        else
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: servicesList
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                                  final index = entry.key;
                                                  final service = entry.value;
                                                  return SpecialistServiceCardWidget(
                                                    key: Key(
                                                      'Keyz2r_${index}_of_${servicesList.length}',
                                                    ),
                                                    servDoc: service,
                                                    filterStartDate:
                                                        filterStartDate,
                                                    allCompletedRecords:
                                                        recordsList,
                                                  );
                                                })
                                                .toList()
                                                .divide(SizedBox(height: 12.0)),
                                          ),
                                        if (servicesList.length < 6)
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                EditServiceWidget.routeName,
                                              );
                                            },
                                            child: Container(
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).divider,
                                                  width: 1.0,
                                                ),
                                              ),
                                              alignment: AlignmentDirectional(
                                                0.0,
                                                0.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_rounded,
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).hint,
                                                    size: 24.0,
                                                  ),
                                                  Text(
                                                    FFLocalizations.of(
                                                      context,
                                                    ).getText(
                                                      'ml7tjxuu' /* Создать новую услугу */,
                                                    ),
                                                    style:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelLarge.override(
                                                          font: GoogleFonts.jetBrainsMono(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontWeight,
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
                                                              ).hint,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(height: 4.0)),
                                              ),
                                            ),
                                          ),
                                      ].divide(SizedBox(height: 16.0)),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            );
                          },
                        );
                      },
                    ),
                    Container(height: 100.0),
                  ],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.menuModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuWidget(currentPage: Menu.dashboard),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
