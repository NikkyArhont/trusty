import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/menu/menu_widget.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'records_model.dart';
export 'records_model.dart';

class RecordsWidget extends StatefulWidget {
  const RecordsWidget({super.key});

  static String routeName = 'records';
  static String routePath = '/records';

  @override
  State<RecordsWidget> createState() => _RecordsWidgetState();
}

class _RecordsWidgetState extends State<RecordsWidget> {
  late RecordsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showSchedule = false;
  late final Stream<List<RecordsRecord>> _recordsStream;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecordsModel());
    _recordsStream = currentUserReference != null
        ? queryRecordsRecord(
            queryBuilder: (recordsRecord) =>
                recordsRecord.where('master', isEqualTo: currentUserReference),
          )
        : Stream.value(const <RecordsRecord>[]);
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
            SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.0,
                        24.0,
                        16.0,
                        24.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            FFLocalizations.of(
                              context,
                            ).getText('jfsw63vl' /* Записи */),
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
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: _RecordsTabButton(
                                  label: FFLocalizations.of(
                                    context,
                                  ).getText('gnoanfnv' /* Запросы */),
                                  selected: !_showSchedule,
                                  onTap: () {
                                    safeSetState(() => _showSchedule = false);
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: _RecordsTabButton(
                                  label: FFLocalizations.of(
                                    context,
                                  ).getText('da9kktub' /* Расписание */),
                                  selected: _showSchedule,
                                  onTap: () {
                                    safeSetState(() => _showSchedule = true);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 112.0),
                    child: StreamBuilder<List<RecordsRecord>>(
                      stream: _recordsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _EmptyRecordsState(
                            title: 'Не удалось загрузить записи',
                            subtitle:
                                'Проверьте подключение к интернету и откройте экран ещё раз.',
                          );
                        }
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

                        final now = getCurrentTimestamp;
                        final allRecords = snapshot.data!.toList();
                        final requestRecords =
                            allRecords
                                .where(
                                  (record) =>
                                      record.status == RecordStatus.newRec,
                                )
                                .toList()
                              ..sort(
                                (a, b) => (b.date ?? DateTime(0)).compareTo(
                                  a.date ?? DateTime(0),
                                ),
                              );
                        final upcomingRecords = allRecords.where((record) {
                          final recordDate = record.date;
                          return record.status == RecordStatus.confirmed &&
                              recordDate != null &&
                              recordDate.isAfter(now);
                        }).toList()..sort((a, b) => a.date!.compareTo(b.date!));
                        final completedRecords =
                            allRecords.where((record) {
                              final recordDate = record.date;
                              return record.status == RecordStatus.complite ||
                                  (record.status == RecordStatus.confirmed &&
                                      recordDate != null &&
                                      !recordDate.isAfter(now));
                            }).toList()..sort(
                              (a, b) => (b.date ?? DateTime(0)).compareTo(
                                a.date ?? DateTime(0),
                              ),
                            );

                        if (!_showSchedule && requestRecords.isEmpty) {
                          return _EmptyRecordsState(
                            title: 'Новых запросов нет',
                            subtitle:
                                'Когда клиент отправит новую заявку, она появится здесь.',
                          );
                        }
                        if (_showSchedule &&
                            upcomingRecords.isEmpty &&
                            completedRecords.isEmpty) {
                          return _EmptyRecordsState(
                            title: 'Расписание пустое',
                            subtitle:
                                'Подтвержденные и завершенные записи появятся здесь.',
                          );
                        }

                        if (!_showSchedule) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: requestRecords
                                .map(
                                  (record) => _MasterRecordCard(
                                    key: ValueKey(record.reference.path),
                                    record: record,
                                  ),
                                )
                                .toList()
                                .divide(SizedBox(height: 12.0)),
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (upcomingRecords.isNotEmpty)
                              _RecordsSection(
                                title: 'Предстоящие',
                                records: upcomingRecords,
                              ),
                            if (completedRecords.isNotEmpty)
                              _RecordsSection(
                                title: 'Завершенные',
                                records: completedRecords,
                              ),
                          ].divide(SizedBox(height: 20.0)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.menuModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuWidget(currentPage: Menu.records),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordsTabButton extends StatelessWidget {
  const _RecordsTabButton({
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
              ? FlutterFlowTheme.of(context).primaryBackground
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
                ? FlutterFlowTheme.of(context).primaryText
                : FlutterFlowTheme.of(context).secondaryText,
            letterSpacing: 0.0,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RecordsSection extends StatelessWidget {
  const _RecordsSection({required this.title, required this.records});

  final String title;
  final List<RecordsRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: FlutterFlowTheme.of(context).titleMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w700),
            color: FlutterFlowTheme.of(context).primaryText,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        ...records
            .map(
              (record) => _MasterRecordCard(
                key: ValueKey(record.reference.path),
                record: record,
              ),
            )
            .toList()
            .divide(SizedBox(height: 12.0)),
      ].divide(SizedBox(height: 12.0)),
    );
  }
}

class _MasterRecordCard extends StatefulWidget {
  const _MasterRecordCard({super.key, required this.record});

  final RecordsRecord record;

  @override
  State<_MasterRecordCard> createState() => _MasterRecordCardState();
}

class _MasterRecordCardState extends State<_MasterRecordCard> {
  late final Future<ServiceRecord?> _serviceFuture;

  RecordsRecord get record => widget.record;

  @override
  void initState() {
    super.initState();
    _serviceFuture = record.service != null
        ? ServiceRecord.getDocumentOnce(record.service!)
        : Future.value(null);
  }

  String _statusLabel(RecordStatus? status) {
    switch (status) {
      case RecordStatus.newRec:
        return 'Новая заявка';
      case RecordStatus.confirmed:
        return 'Подтверждена';
      case RecordStatus.denied:
        return 'Отклонена';
      case RecordStatus.complite:
        return 'Завершена';
      default:
        return 'Без статуса';
    }
  }

  Color _statusColor(BuildContext context, RecordStatus? status) {
    switch (status) {
      case RecordStatus.newRec:
        return FlutterFlowTheme.of(context).primary;
      case RecordStatus.confirmed:
      case RecordStatus.complite:
        return FlutterFlowTheme.of(context).success;
      case RecordStatus.denied:
        return FlutterFlowTheme.of(context).error;
      default:
        return FlutterFlowTheme.of(context).secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceRecord?>(
      future: _serviceFuture,
      builder: (context, serviceSnapshot) {
        final service = serviceSnapshot.data;
        final serviceTitle = service?.title.trim().isNotEmpty == true
            ? service!.title
            : 'Услуга';
        final dateLabel = record.date != null
            ? dateTimeFormat('d MMMM y, HH:mm', record.date, locale: 'ru')
            : 'Дата не назначена';

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            context.pushNamed(
              RecordPageMasterWidget.routeName,
              queryParameters: {
                'recordDoc': serializeParam(record, ParamType.Document),
              }.withoutNulls,
              extra: <String, dynamic>{'recordDoc': record},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).divider,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ClientIdentity(
                        clientRef: record.client,
                        recordClientName: record.clientName,
                        recordClientPhoto: record.clientPhoto,
                        serviceTitle: serviceTitle,
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.0, 0.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 140.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _statusColor(
                                context,
                                record.status,
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(9999.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                12.0,
                                6.0,
                                12.0,
                                6.0,
                              ),
                              child: Text(
                                _statusLabel(record.status),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).labelSmall
                                    .override(
                                      font: GoogleFonts.jetBrainsMono(),
                                      color: _statusColor(
                                        context,
                                        record.status,
                                      ),
                                      letterSpacing: 0.0,
                                    ),
                              ),
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
                          dateLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FlutterFlowTheme.of(context).bodySmall
                              .override(
                                font: GoogleFonts.jetBrainsMono(),
                                color: FlutterFlowTheme.of(
                                  context,
                                ).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                ].divide(SizedBox(height: 14.0)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClientIdentity extends StatefulWidget {
  const _ClientIdentity({
    required this.clientRef,
    required this.recordClientName,
    required this.recordClientPhoto,
    required this.serviceTitle,
  });

  final DocumentReference? clientRef;
  final String recordClientName;
  final String recordClientPhoto;
  final String serviceTitle;

  @override
  State<_ClientIdentity> createState() => _ClientIdentityState();
}

class _ClientIdentityState extends State<_ClientIdentity> {
  late final Future<DocumentSnapshot?> _clientFuture;

  DocumentReference? get clientRef => widget.clientRef;
  String get recordClientName => widget.recordClientName;
  String get recordClientPhoto => widget.recordClientPhoto;
  String get serviceTitle => widget.serviceTitle;

  @override
  void initState() {
    super.initState();
    _clientFuture = clientRef != null ? clientRef!.get() : Future.value(null);
  }

  String _stringField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'КЛ';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: _clientFuture,
      builder: (context, snapshot) {
        final rawData = snapshot.data?.data();
        final data = rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : <String, dynamic>{};
        var clientName = _stringField(data, [
          'display_name',
          'displayName',
          'name',
          'full_name',
          'fullName',
          'title',
        ]);
        if (clientName.isEmpty) {
          clientName = _stringField(data, ['phone_number', 'phoneNumber']);
        }
        final resolvedName = recordClientName.trim().isNotEmpty
            ? recordClientName.trim()
            : (clientName.isNotEmpty ? clientName : 'Клиент');
        final clientPhoto = recordClientPhoto.trim().isNotEmpty
            ? recordClientPhoto.trim()
            : _stringField(data, ['photo_url', 'photoUrl']);

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  shape: BoxShape.circle,
                ),
                alignment: AlignmentDirectional(0.0, 0.0),
                child: clientPhoto.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: clientPhoto,
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 0),
                        fadeOutDuration: Duration(milliseconds: 0),
                        errorWidget: (context, error, stackTrace) => Center(
                          child: Text(
                            _initials(resolvedName),
                            style: TextStyle(
                              color: FlutterFlowTheme.of(
                                context,
                              ).primaryBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _initials(resolvedName),
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      serviceTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.jetBrainsMono(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ].divide(SizedBox(height: 4.0)),
                ),
              ),
            ].divide(SizedBox(width: 12.0)),
          ),
        );
      },
    );
  }
}

class _EmptyRecordsState extends StatelessWidget {
  const _EmptyRecordsState({
    this.title = 'Записей пока нет',
    this.subtitle = 'Когда клиенты запишутся на услуги, заявки появятся здесь.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: FlutterFlowTheme.of(context).divider),
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
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.jetBrainsMono(),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ].divide(SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
