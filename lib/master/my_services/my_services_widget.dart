import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import '/master/no_service/no_service_widget.dart';
import '/master/specialist_service_card/specialist_service_card_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'my_services_model.dart';
export 'my_services_model.dart';

class MyServicesWidget extends StatefulWidget {
  const MyServicesWidget({super.key});

  static String routeName = 'myServices';
  static String routePath = '/myServices';

  @override
  State<MyServicesWidget> createState() => _MyServicesWidgetState();
}

class _MyServicesWidgetState extends State<MyServicesWidget> {
  late MyServicesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyServicesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ServiceRecord>>(
      stream: queryServiceRecord(
        queryBuilder: (serviceRecord) => serviceRecord.where(
          'owner',
          isEqualTo: currentUserReference,
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
        List<ServiceRecord> myServicesServiceRecordList = snapshot.data!;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).divider,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            24.0, 24.0, 24.0, 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'w21i75dq' /* Мои услуги */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                            if (myServicesServiceRecordList.length < 6)
                              FlutterFlowIconButton(
                                buttonSize: 44.0,
                                icon: Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 28.0,
                                ),
                                onPressed: () async {
                                  context
                                      .pushNamed(EditServiceWidget.routeName);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: SingleChildScrollView(
                            primary: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8.0),
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
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            FFLocalizations.of(context).getText(
                                              'cj35joe3' /* Вы можете добавить до 5 услуг ... */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font:
                                                      GoogleFonts.jetBrainsMono(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final myServicesVar =
                                        myServicesServiceRecordList.toList();
                                    if (myServicesVar.isEmpty) {
                                      return NoServiceWidget();
                                    }

                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: myServicesVar.length,
                                      itemBuilder:
                                          (context, myServicesVarIndex) {
                                        final myServicesVarItem =
                                            myServicesVar[myServicesVarIndex];
                                        return SpecialistServiceCardWidget(
                                          key: Key(
                                              'Keyz2r_${myServicesVarIndex}_of_${myServicesVar.length}'),
                                          servDoc: myServicesVarItem,
                                        );
                                      },
                                    );
                                  },
                                ),
                                if (myServicesServiceRecordList.length < 6)
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed(
                                          EditServiceWidget.routeName);
                                    },
                                    child: Container(
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .divider,
                                          width: 1.0,
                                        ),
                                      ),
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .hint,
                                            size: 24.0,
                                          ),
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'ml7tjxuu' /* Создать новую услугу */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .labelLarge
                                                .override(
                                                  font:
                                                      GoogleFonts.jetBrainsMono(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelLarge
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .hint,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 4.0)),
                                      ),
                                    ),
                                  ),
                                Container(
                                  height: 80.0,
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.menuModel,
                    updateCallback: () => safeSetState(() {}),
                    child: MenuWidget(
                      currentPage: Menu.myService,
                    ),
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
