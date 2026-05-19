import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/phone_call/phone_call_widget.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'record_page_client_model.dart';
export 'record_page_client_model.dart';

class RecordPageClientWidget extends StatefulWidget {
  const RecordPageClientWidget({
    super.key,
    required this.serviceDoc,
  });

  final ServiceRecord? serviceDoc;

  static String routeName = 'recordPageClient';
  static String routePath = '/recordPageClient';

  @override
  State<RecordPageClientWidget> createState() => _RecordPageClientWidgetState();
}

class _RecordPageClientWidgetState extends State<RecordPageClientWidget> {
  late RecordPageClientModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLocallyBooked = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecordPageClientModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
        child: StreamBuilder<UserRecord>(
          stream: widget!.serviceDoc?.owner != null
              ? UserRecord.getDocument(widget!.serviceDoc!.owner!)
              : Stream.empty(),
          builder: (context, snapshot) {
            // Customize what your widget looks like when it's loading.
            if (!snapshot.hasData && !snapshot.hasError && widget!.serviceDoc?.owner != null) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SpinKitPulse(
                    color: FlutterFlowTheme.of(context).primary,
                    size: 50.0,
                  ),
                ),
              );
            }

            final containerUserRecord = snapshot.data ??
                UserRecord.getDocumentFromData({
                  'phone_number': '+7 999 000-00-00',
                  'masterData': {
                    'title': 'Специалист (Тест)',
                    'mainPhoto': '',
                  },
                }, UserRecord.collection.doc('dummy'));

            return Container(
              decoration: BoxDecoration(),
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 280.0,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 0),
                            fadeOutDuration: Duration(milliseconds: 0),
                            imageUrl: widget!.serviceDoc?.image.firstOrNull ?? '',
                            height: 280.0,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: FlutterFlowTheme.of(context).divider,
                                size: 40.0,
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Container(
                              alignment: AlignmentDirectional(-1.0, -1.0),
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: wrapWithModel(
                                  model: _model.navBackModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: NavBackWidget(),
                                ),
                              ),
                            ),
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valueOrDefault<String>(
                                    widget!.serviceDoc?.title,
                                    'noTitle',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 26.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                        lineHeight: 1.25,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 32.0,
                                      height: 32.0,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: CachedNetworkImage(
                                        fadeInDuration:
                                            Duration(milliseconds: 0),
                                        fadeOutDuration:
                                            Duration(milliseconds: 0),
                                        imageUrl: containerUserRecord
                                            .masterData.mainPhoto,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.person_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          containerUserRecord.masterData.title,
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            'h6p8h33h' /* Certified Specialist */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                            StreamBuilder<List<RecordsRecord>>(
                              stream: currentUserReference != null
                                  ? queryRecordsRecord(
                                      queryBuilder: (recordsRecord) => recordsRecord
                                          .where('client', isEqualTo: currentUserReference)
                                          .where('service', isEqualTo: widget!.serviceDoc?.reference),
                                      singleRecord: true,
                                    )
                                  : Stream.empty(),
                              builder: (context, recordsSnapshot) {
                                final hasRecord = _isLocallyBooked || (recordsSnapshot.hasData && recordsSnapshot.data!.isNotEmpty);
                                final recordDoc = (recordsSnapshot.hasData && recordsSnapshot.data!.isNotEmpty) ? recordsSnapshot.data!.first : null;

                                if (!hasRecord) {
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        safeSetState(() {
                                          _isLocallyBooked = true;
                                        });
                                        try {
                                          await RecordsRecord.collection.add({
                                            ...createRecordsRecordData(
                                              master: widget!.serviceDoc?.owner ?? UserRecord.collection.doc('dummy_master'),
                                              client: currentUserReference ?? UserRecord.collection.doc('dummy_client'),
                                              service: widget!.serviceDoc?.reference ?? ServiceRecord.collection.doc('dummy_service'),
                                              date: getCurrentTimestamp,
                                              status: RecordStatus.newRec,
                                            ),
                                          });
                                        } catch (e) {
                                          print('Error adding record: $e');
                                        }
                                      },
                                      text: 'Записаться',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.0,
                                        ),
                                        elevation: 3.0,
                                        borderRadius: BorderRadius.circular(28.0),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Divider(
                              color: FlutterFlowTheme.of(context).divider,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 2.0,
                                    color: Color(0x1A000000),
                                    offset: Offset(
                                      0.0,
                                      1.0,
                                    ),
                                    spreadRadius: 0.0,
                                  )
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
                                        '55h32fio' /* Ожидаем подтверждения от масте... */,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleLarge
                                                    .fontStyle,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'o2i1e6l0' /* Когда мастер подтвердит запись... */,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.5,
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
                                  FFLocalizations.of(context).getText(
                                    'y794wibd' /* Контакты */,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 20.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .fontStyle,
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
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: PhoneCallWidget(
                                            phone: '',
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 2.0,
                                          color: Color(0x1A000000),
                                          offset: Offset(
                                            0.0,
                                            1.0,
                                          ),
                                          spreadRadius: 0.0,
                                        )
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
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(12.0),
                                                  child: Icon(
                                                    Icons.phone,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  containerUserRecord
                                                      .phoneNumber,
                                                  textAlign: TextAlign.end,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleLarge
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleLarge
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                            FFButtonWidget(
                              onPressed: () async {
                                safeSetState(() {
                                  _isLocallyBooked = false;
                                });
                                if (recordDoc != null) {
                                  try {
                                    await recordDoc.reference.delete();
                                  } catch (e) {
                                    print('Error deleting record: $e');
                                  }
                                }
                              },
                              text: FFLocalizations.of(context).getText(
                                'nbkyfex5' /* Отменить запись */,
                              ),
                              icon: Icon(
                                Icons.close,
                                size: 15.0,
                              ),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
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
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 2.0,
                                    color: Color(0x1A000000),
                                    offset: Offset(
                                      0.0,
                                      1.0,
                                    ),
                                    spreadRadius: 0.0,
                                  )
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
                                        'sn3tia7r' /* Confirm your visit */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleLarge
                                                    .fontStyle,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'aje49qg4' /* Help your contacts find truste... */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.5,
                                          ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      size: 20.0,
                                                    ),
                                                    Text(
                                                      FFLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'uzag11r2' /* I visited this specialist */,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelLarge
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                            lineHeight: 1.3,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.thumb_up_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      size: 20.0,
                                                    ),
                                                    Text(
                                                      FFLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'wnpbmppk' /* I recommend this specialist */,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelLarge
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                            lineHeight: 1.3,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'i5s1yrix' /* Share more details */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                TextFormField(
                                  controller: _model.textController,
                                  focusNode: _model.textFieldFocusNode,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText:
                                        FFLocalizations.of(context).getText(
                                      '0z0h72zp' /* Leave a short comment (optiona... */,
                                    ),
                                    hintStyle: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                  ),
                                  style: TextStyle(),
                                  maxLines: 4,
                                  validator: _model.textControllerValidator
                                      .asValidator(context),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'da4eqoaw' /* Your recommendation will be vi... */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.jetBrainsMono(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .fontStyle,
                                        ),
                                        color:
                                            FlutterFlowTheme.of(context).hint,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            Container(
                              height: 24.0,
                            ),
                            Container(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: FFButtonWidget(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  text: FFLocalizations.of(context).getText(
                                    'z78kn659' /* Cancel */,
                                  ),
                                  options: FFButtonOptions(
                                    height: 44.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.transparent,
                                    textStyle: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(22.0),
                                  ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 24.0)),
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
            );
          },
        ),
      ),
    );
  }
}
