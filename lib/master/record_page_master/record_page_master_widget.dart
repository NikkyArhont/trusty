import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/phone_call/phone_call_widget.dart';
import '/global_comp/record_qr/record_qr_widget.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/init/sync_contacts.dart';
import '/user/recommend_dialog/recommend_dialog_widget.dart';
import 'record_page_master_model.dart';
import 'dart:async';
export 'record_page_master_model.dart';

class RecordPageMasterWidget extends StatefulWidget {
  const RecordPageMasterWidget({
    super.key,
    required this.recordDoc,
    this.clientView = false,
    this.serviceDoc,
  });

  final RecordsRecord? recordDoc;
  final bool clientView;
  final ServiceRecord? serviceDoc;

  static String routeName = 'recordPageMaster';
  static String routePath = '/recordPageMaster';

  @override
  State<RecordPageMasterWidget> createState() => _RecordPageMasterWidgetState();
}

class _RecordPageMasterWidgetState extends State<RecordPageMasterWidget> {
  late RecordPageMasterModel _model;
  String _resolvedClientPhone = '';
  Timer? _visitAvailabilityTimer;
  DateTime? _visitAvailabilityTarget;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _loadClientPhone() async {
    final record = widget.recordDoc;
    final storedPhone = record?.clientPhone.trim() ?? '';
    if (!widget.clientView && storedPhone.isNotEmpty) {
      _resolvedClientPhone = storedPhone;
      return;
    }

    final clientRef = record?.client;
    final masterRef = record?.master;
    if (clientRef == null || masterRef == null) {
      return;
    }

    final chatSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc('client_${clientRef.id}_master_${masterRef.id}')
        .get();
    final phone =
        (chatSnapshot.data()?[widget.clientView ? 'masterPhone' : 'clientPhone']
                    as String? ??
                '')
            .trim();
    if (mounted && phone.isNotEmpty) {
      safeSetState(() => _resolvedClientPhone = phone);
    }
  }

  Future<void> _setRecordStatus({
    required RecordStatus status,
    DateTime? date,
  }) async {
    final record = widget.recordDoc;
    if (record == null) {
      return;
    }

    final isConfirmed = status == RecordStatus.confirmed;
    final confirmedDate = isConfirmed ? date : null;
    if (isConfirmed && confirmedDate == null) {
      return;
    }
    final notificationTitle = isConfirmed
        ? 'Запись подтверждена'
        : 'Запись отменена';
    final notificationBody = isConfirmed
        ? 'Мастер подтвердил вашу запись.'
        : widget.clientView
        ? 'Клиент отменил запись.'
        : 'Мастер отменил вашу запись.';

    await record.reference.update(
      createRecordsRecordData(status: status, date: confirmedDate),
    );

    final notificationUser = widget.clientView ? record.master : record.client;
    if (notificationUser != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'user': notificationUser,
        'record': record.reference,
        'title': notificationTitle,
        'body': notificationBody,
        'type': isConfirmed ? 'record_confirmed' : 'record_denied',
        'created_time': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  void _scheduleVisitAvailabilityRefresh(DateTime? visitTime) {
    if (_visitAvailabilityTarget == visitTime) {
      return;
    }

    _visitAvailabilityTimer?.cancel();
    _visitAvailabilityTarget = visitTime;
    if (visitTime == null) {
      return;
    }

    final delay = visitTime.difference(getCurrentTimestamp);
    if (delay <= Duration.zero) {
      return;
    }

    _visitAvailabilityTimer = Timer(delay, () {
      if (!mounted) {
        return;
      }
      _visitAvailabilityTarget = null;
      safeSetState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecordPageMasterModel());
    _model.presetTime = widget.recordDoc?.date;
    _resolvedClientPhone = widget.clientView
        ? ''
        : widget.recordDoc?.clientPhone.trim() ?? '';
    _loadClientPhone();

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _visitAvailabilityTimer?.cancel();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RecordsRecord>(
      stream: RecordsRecord.getDocument(widget.recordDoc!.reference),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final record = snapshot.data!;
        final clientName = record.clientName.trim().isNotEmpty
            ? record.clientName.trim()
            : 'Клиент';
        final clientPhoto = record.clientPhoto.trim();
        final clientPhone = _resolvedClientPhone;
        final displayRole = widget.clientView ? 'Специалист' : 'Клиент';
        final displayName = widget.clientView
            ? (widget.serviceDoc?.masterTitle.trim().isNotEmpty == true
                  ? widget.serviceDoc!.masterTitle.trim()
                  : 'Специалист')
            : clientName;
        final displayPhoto = widget.clientView
            ? widget.serviceDoc?.masterPhoto.trim() ?? ''
            : clientPhoto;
        final displayedRecordTime = record.status == RecordStatus.newRec
            ? (_model.presetTime ?? record.date)
            : record.date;
        _scheduleVisitAvailabilityRefresh(record.date);
        final canConfirmVisit =
            record.status == RecordStatus.confirmed &&
            record.date != null &&
            !record.date!.isAfter(getCurrentTimestamp);
        final statusTitle = switch (record.status) {
          RecordStatus.confirmed => 'Запись подтверждена',
          RecordStatus.complite => 'Услуга оказана',
          RecordStatus.denied => 'Запись отменена',
          _ =>
            widget.clientView
                ? 'Ожидает подтверждения мастера'
                : 'Клиент ждет подтверждения',
        };
        final statusDescription = switch (record.status) {
          RecordStatus.confirmed => 'Дата и время записи установлены',
          RecordStatus.complite => 'Посещение подтверждено по QR-коду',
          RecordStatus.denied => 'Эта запись была отменена',
          _ =>
            widget.clientView
                ? 'Мастер назначит дату и подтвердит запись'
                : 'Согласуйте с клиентом дату и время записи',
        };

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Container(
              decoration: BoxDecoration(),
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          wrapWithModel(
                            model: _model.navBackModel,
                            updateCallback: () => safeSetState(() {}),
                            child: NavBackWidget(),
                          ),
                          Text(
                            FFLocalizations.of(
                              context,
                            ).getText('uzsowjzi' /* Запись */),
                            style: FlutterFlowTheme.of(context).headlineMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).headlineMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryText,
                                  fontSize: 26.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).headlineMedium.fontStyle,
                                  lineHeight: 1.25,
                                ),
                          ),
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(color: Color(0x001E293B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0,
                                  8.0,
                                  12.0,
                                  8.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayRole,
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                            context,
                                                          )
                                                          .headlineMedium
                                                          .fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                fontSize: 26.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).headlineMedium.fontStyle,
                                                lineHeight: 1.25,
                                              ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 32.0,
                                              height: 32.0,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: CachedNetworkImage(
                                                fadeInDuration: Duration(
                                                  milliseconds: 0,
                                                ),
                                                fadeOutDuration: Duration(
                                                  milliseconds: 0,
                                                ),
                                                imageUrl: displayPhoto,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Image.asset(
                                                      'assets/images/error_image.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    displayName,
                                                    maxLines: 3,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).titleMedium.override(
                                                          font: GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).primaryText,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .titleMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.4,
                                                        ),
                                                  ),
                                                  Text(
                                                    clientPhone.isNotEmpty
                                                        ? clientPhone
                                                        : 'Телефон не указан',
                                                    style:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).bodySmall.override(
                                                          font: GoogleFonts.jetBrainsMono(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .bodySmall
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).secondaryText,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodySmall
                                                                  .fontStyle,
                                                          lineHeight: 1.4,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        ),
                                        StreamBuilder<ServiceRecord>(
                                          stream: ServiceRecord.getDocument(
                                            widget.recordDoc!.service!,
                                          ),
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
                                              return Center(
                                                child: SizedBox(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  child: SpinKitPulse(
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                    size: 50.0,
                                                  ),
                                                ),
                                              );
                                            }

                                            final containerServiceRecord =
                                                snapshot.data!;

                                            return Container(
                                              decoration: BoxDecoration(),
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
                                                    ).getText(
                                                      'kc0n4r96' /* Услуга */,
                                                    ),
                                                    style:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).headlineMedium.override(
                                                          font: GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                          fontSize: 26.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .headlineMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.25,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 32.0,
                                                        height: 32.0,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: CachedNetworkImage(
                                                          fadeInDuration:
                                                              Duration(
                                                                milliseconds: 0,
                                                              ),
                                                          fadeOutDuration:
                                                              Duration(
                                                                milliseconds: 0,
                                                              ),
                                                          imageUrl:
                                                              containerServiceRecord
                                                                  .image
                                                                  .firstOrNull!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              containerServiceRecord
                                                                  .title,
                                                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                font: GoogleFonts.inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).titleMedium.fontStyle,
                                                                ),
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).primaryText,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                            ),
                                                            Text(
                                                              containerServiceRecord
                                                                  .place
                                                                  .title,
                                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                font: GoogleFonts.jetBrainsMono(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodySmall.fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                  context,
                                                                ).secondaryText,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontStyle:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodySmall
                                                                        .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ].divide(SizedBox(width: 8.0)),
                                                  ),
                                                ].divide(SizedBox(height: 4.0)),
                                              ),
                                            );
                                          },
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: FlutterFlowTheme.of(context).divider,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(
                                  context,
                                ).secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 2.0,
                                    color: Color(0x1A000000),
                                    offset: Offset(0.0, 1.0),
                                    spreadRadius: 0.0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      statusTitle,
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).titleLarge.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).titleLarge.fontStyle,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                    Text(
                                      statusDescription,
                                      textAlign: TextAlign.center,
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
                                    if (displayedRecordTime != null)
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              '4tl4bbzl' /* Выбранное время: */,
                                            ),
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).titleLarge.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleLarge.fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    12.0,
                                                    4.0,
                                                    12.0,
                                                    4.0,
                                                  ),
                                              child: Text(
                                                dateTimeFormat(
                                                  record.status ==
                                                          RecordStatus.complite
                                                      ? 'HH:mm dd.MM.yy'
                                                      : 'HH:mm dd MMMM',
                                                  displayedRecordTime,
                                                  locale: 'ru',
                                                ),
                                                textAlign: TextAlign.end,
                                                style:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).titleLarge.override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .titleLarge
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).primaryBackground,
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .titleLarge
                                                              .fontStyle,
                                                      lineHeight: 1.3,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (!widget.clientView &&
                                        record.status !=
                                            RecordStatus.complite &&
                                        record.status != RecordStatus.denied)
                                      FFButtonWidget(
                                        onPressed: () async {
                                          final _datePickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: getCurrentTimestamp,
                                            firstDate: getCurrentTimestamp,
                                            lastDate: DateTime(2050),
                                            builder: (context, child) {
                                              return wrapInMaterialDatePickerTheme(
                                                context,
                                                child!,
                                                headerBackgroundColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                headerForegroundColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).info,
                                                headerTextStyle:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).headlineLarge.override(
                                                      font: GoogleFonts.interTight(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .headlineLarge
                                                                .fontStyle,
                                                      ),
                                                      fontSize: 32.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .headlineLarge
                                                              .fontStyle,
                                                    ),
                                                pickerBackgroundColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).secondaryBackground,
                                                pickerForegroundColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryText,
                                                selectedDateTimeBackgroundColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                selectedDateTimeForegroundColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).info,
                                                actionButtonForegroundColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryText,
                                                iconSize: 24.0,
                                              );
                                            },
                                          );

                                          TimeOfDay? _datePickedTime;
                                          if (_datePickedDate != null) {
                                            _datePickedTime = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  TimeOfDay.fromDateTime(
                                                    getCurrentTimestamp,
                                                  ),
                                              builder: (context, child) {
                                                return wrapInMaterialTimePickerTheme(
                                                  context,
                                                  child!,
                                                  headerBackgroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primary,
                                                  headerForegroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).info,
                                                  headerTextStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).headlineLarge.override(
                                                        font: GoogleFonts.interTight(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .headlineLarge
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 32.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .headlineLarge
                                                                .fontStyle,
                                                      ),
                                                  pickerBackgroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).secondaryBackground,
                                                  pickerForegroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primaryText,
                                                  selectedDateTimeBackgroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primary,
                                                  selectedDateTimeForegroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).info,
                                                  actionButtonForegroundColor:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).primaryText,
                                                  iconSize: 24.0,
                                                );
                                              },
                                            );
                                          }

                                          if (_datePickedDate == null ||
                                              _datePickedTime == null) {
                                            return;
                                          }

                                          final selectedDateTime = DateTime(
                                            _datePickedDate.year,
                                            _datePickedDate.month,
                                            _datePickedDate.day,
                                            _datePickedTime.hour,
                                            _datePickedTime.minute,
                                          );
                                          safeSetState(() {
                                            _model.datePicked =
                                                selectedDateTime;
                                            _model.presetTime =
                                                selectedDateTime;
                                          });
                                          if (record.status ==
                                              RecordStatus.confirmed) {
                                            await record.reference.update(
                                              createRecordsRecordData(
                                                date: selectedDateTime,
                                              ),
                                            );
                                          }
                                        },
                                        text: FFLocalizations.of(context)
                                            .getText(
                                              'dv4879am' /* Выбрать дату */,
                                            ),
                                        icon: Icon(
                                          Icons.calendar_today,
                                          size: 15.0,
                                        ),
                                        options: FFButtonOptions(
                                          width: double.infinity,
                                          height: 56.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                0.0,
                                                0.0,
                                                0.0,
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
                                          textStyle: TextStyle(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0,
                                          ),
                                          elevation: 0.0,
                                          borderRadius: BorderRadius.circular(
                                            28.0,
                                          ),
                                        ),
                                      ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FFLocalizations.of(
                                    context,
                                  ).getText('wue3q6u6' /* Контакты */),
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context).titleLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).titleLarge.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        fontSize: 20.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).titleLarge.fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: MediaQuery.viewInsetsOf(
                                            context,
                                          ),
                                          child: PhoneCallWidget(
                                            phone: clientPhone,
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 2.0,
                                          color: Color(0x1A000000),
                                          offset: Offset(0.0, 1.0),
                                          spreadRadius: 0.0,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        16.0,
                                                      ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Icon(
                                                    Icons.phone,
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryText,
                                                    size: 24.0,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  clientPhone.isNotEmpty
                                                      ? clientPhone
                                                      : 'Телефон не указан',
                                                  textAlign: TextAlign.end,
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleLarge.override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                    context,
                                                                  )
                                                                  .titleLarge
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primaryText,
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .titleLarge
                                                                .fontStyle,
                                                        lineHeight: 1.3,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ].divide(SizedBox(height: 16.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            if (!widget.clientView &&
                                record.status == RecordStatus.newRec)
                              FFButtonWidget(
                                onPressed: () async {
                                  if (_model.presetTime == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Сначала выберите дату и время записи',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  await _setRecordStatus(
                                    status: RecordStatus.confirmed,
                                    date: _model.presetTime,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Запись подтверждена'),
                                      ),
                                    );
                                  }
                                },
                                text: FFLocalizations.of(
                                  context,
                                ).getText('p550d5wr' /* Подтвердить запись */),
                                icon: Icon(Icons.check, size: 15.0),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: TextStyle(
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).secondaryBackground,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                  ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(28.0),
                                  disabledColor: FlutterFlowTheme.of(
                                    context,
                                  ).secondary,
                                ),
                              ),
                            if (record.status != RecordStatus.complite &&
                                record.status != RecordStatus.denied)
                              FFButtonWidget(
                                onPressed: () async {
                                  await _setRecordStatus(
                                    status: RecordStatus.denied,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Запись отменена'),
                                      ),
                                    );
                                  }
                                },
                                text: FFLocalizations.of(
                                  context,
                                ).getText('zxlm7xkx' /* Отменить запись */),
                                icon: Icon(Icons.close, size: 15.0),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                  color: Colors.white,
                                  textStyle: TextStyle(
                                    color: FlutterFlowTheme.of(context).error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                  ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                              ),
                            if (canConfirmVisit)
                              Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 2.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(0.0, 1.0),
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'j74og9am' /* Confirm your visit */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleLarge.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).titleLarge.fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'jlpnmsy5' /* Help your contacts find truste... */,
                                        ),
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
                                      if (canConfirmVisit)
                                        RecordQrWidget(
                                          recordReference: record.reference,
                                        ),
                                    ].divide(SizedBox(height: 16.0)),
                                  ),
                                ),
                              ),
                            if (widget.clientView &&
                                record.status == RecordStatus.complite)
                              StreamBuilder<ServiceRecord>(
                                stream: widget.serviceDoc != null
                                    ? ServiceRecord.getDocument(
                                        widget.serviceDoc!.reference,
                                      )
                                    : (record.service != null
                                          ? ServiceRecord.getDocument(
                                              record.service!,
                                            )
                                          : Stream.empty()),
                                builder: (context, serviceSnapshot) {
                                  if (!serviceSnapshot.hasData) {
                                    return SizedBox.shrink();
                                  }
                                  final serviceDoc = serviceSnapshot.data!;

                                  final rawUserPhone =
                                      currentPhoneNumber.isNotEmpty
                                      ? currentPhoneNumber
                                      : (currentUserDocument?.phoneNumber ??
                                            '');
                                  final normalizedUserPhone = normalizePhone(
                                    rawUserPhone,
                                  );
                                  final hasAlreadyRecommended =
                                      normalizedUserPhone.isNotEmpty &&
                                      serviceDoc.recommenderPhones.contains(
                                        normalizedUserPhone,
                                      );

                                  if (hasAlreadyRecommended) {
                                    return SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0,
                                      16.0,
                                      0.0,
                                      0.0,
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        if (normalizedUserPhone.isNotEmpty) {
                                          final result = await showDialog<bool>(
                                            context: context,
                                            builder: (dialogContext) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                  ),
                                              child: RecommendDialogWidget(
                                                serviceDoc: serviceDoc,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            safeSetState(() {});
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Для рекомендации необходим номер телефона. Заполните его в профиле.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 56.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).success,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 4.0,
                                              color: Color(0x1A000000),
                                              offset: Offset(0.0, 2.0),
                                              spreadRadius: 0.0,
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            28.0,
                                          ),
                                        ),
                                        alignment: AlignmentDirectional(
                                          0.0,
                                          0.0,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.thumb_up_alt_rounded,
                                                color: Colors.white,
                                                size: 22.0,
                                              ),
                                              SizedBox(width: 8.0),
                                              Expanded(
                                                child: Text(
                                                  'Порекомендовать услугу знакомым',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleMedium.override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ].divide(SizedBox(height: 24.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
