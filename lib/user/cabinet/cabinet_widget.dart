import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/app_page_header/app_page_header.dart';
import '/global_comp/menu/menu_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cabinet_model.dart';
export 'cabinet_model.dart';

class CabinetWidget extends StatefulWidget {
  const CabinetWidget({super.key});

  static String routeName = 'Cabinet';
  static String routePath = '/cabinet';

  @override
  State<CabinetWidget> createState() => _CabinetWidgetState();
}

class _CabinetWidgetState extends State<CabinetWidget> {
  late CabinetModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CabinetModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _statusLabel(RecordStatus? status) {
    switch (status) {
      case RecordStatus.confirmed:
        return 'Подтверждено';
      case RecordStatus.denied:
        return 'Отменено';
      case RecordStatus.complite:
        return 'Завершено';
      case RecordStatus.newRec:
      default:
        return 'Ожидает подтверждения';
    }
  }

  Color _statusColor(BuildContext context, RecordStatus? status) {
    switch (status) {
      case RecordStatus.confirmed:
        return Color(0xFF16803C);
      case RecordStatus.denied:
        return FlutterFlowTheme.of(context).error;
      case RecordStatus.complite:
        return FlutterFlowTheme.of(context).secondaryText;
      case RecordStatus.newRec:
      default:
        return Color(0xFFB45309);
    }
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
            SingleChildScrollView(
              primary: false,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  16.0,
                  16.0,
                  16.0,
                  120.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppPageHeader(
                      title: 'Кабинет',
                      padding: EdgeInsets.zero,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () {
                        context.pushNamed(VisitHistoryWidget.routeName);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).divider,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'История посещений',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    'Завершённые визиты и рекомендации',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Мои записи',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    StreamBuilder<List<RecordsRecord>>(
                      stream: currentUserReference != null
                          ? queryRecordsRecord(
                              queryBuilder: (recordsRecord) =>
                                  recordsRecord.where(
                                    'client',
                                    isEqualTo: currentUserReference,
                                  ),
                            )
                          : Stream.value([]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: SpinKitPulse(
                                color: FlutterFlowTheme.of(context).primary,
                                size: 50.0,
                              ),
                            ),
                          );
                        }

                        final records = snapshot.data!.toList()
                          ..sort(
                            (a, b) => (b.date ?? DateTime(0)).compareTo(
                              a.date ?? DateTime(0),
                            ),
                          );

                        if (records.isEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).divider,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 32.0,
                                  ),
                                  Text(
                                    'Записей пока нет',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    'После записи на услугу информация появится здесь.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                            ),
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: records
                              .map(
                                (record) => _RecordCard(
                                  record: record,
                                  statusLabel: _statusLabel(record.status),
                                  statusColor: _statusColor(
                                    context,
                                    record.status,
                                  ),
                                ),
                              )
                              .toList()
                              .divide(SizedBox(height: 12.0)),
                        );
                      },
                    ),
                  ].divide(SizedBox(height: 16.0)),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.menuModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuWidget(currentPage: Menu.cabinet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.statusLabel,
    required this.statusColor,
  });

  final RecordsRecord record;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    if (record.service == null) {
      return _buildCard(context, 'Услуга', '', null);
    }

    return StreamBuilder<ServiceRecord>(
      stream: ServiceRecord.getDocument(record.service!),
      builder: (context, snapshot) {
        return _buildCard(
          context,
          snapshot.data?.title ?? 'Услуга',
          snapshot.data?.place.title ?? '',
          snapshot.data,
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    String serviceTitle,
    String city,
    ServiceRecord? serviceDoc,
  ) {
    final card = Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).divider),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    serviceTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 120.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      statusLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: statusColor,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(width: 12.0)),
            ),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                Expanded(
                  child: Text(
                    dateTimeFormat(
                      'd MMMM y, HH:mm',
                      record.date,
                      locale: 'ru',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ].divide(SizedBox(width: 8.0)),
            ),
            if (city.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 16.0,
                  ),
                  Expanded(
                    child: Text(
                      city,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
          ].divide(SizedBox(height: 12.0)),
        ),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: () async {
        context.pushNamed(
          RecordPageClientWidget.routeName,
          queryParameters: {
            'serviceDoc': serializeParam(serviceDoc, ParamType.Document),
            'recordDoc': serializeParam(record, ParamType.Document),
          }.withoutNulls,
          extra: <String, dynamic>{
            if (serviceDoc != null) 'serviceDoc': serviceDoc,
            'recordDoc': record,
          },
        );
      },
      child: card,
    );
  }
}
