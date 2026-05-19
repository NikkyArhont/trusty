import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/components/service_item_widget.dart';
import '/components/stat_card_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import 'dart:ui';
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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpecialistDashboardModel());

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
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 32.0, 24.0, 16.0),
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
                                  'ms588699' /* Панель */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                              AuthUserStreamWidget(
                                builder: (context) => Text(
                                  valueOrDefault<String>(
                                    currentUserDocument?.masterData?.title,
                                    'noTitle',
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
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ),
                            ].divide(SizedBox(height: 4.0)),
                          ),
                          AuthUserStreamWidget(
                            builder: (context) => Container(
                              width: 48.0,
                              height: 48.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 0),
                                fadeOutDuration: Duration(milliseconds: 0),
                                imageUrl:
                                    currentUserDocument!.masterData.mainPhoto,
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/images/error_image.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.statCardModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    value: 124.0,
                                    label: 'Recommendations',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.statCardModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    value: 48.0,
                                    label: 'Clients',
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.statCardModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    value: 12.0,
                                    label: 'Regulars',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.statCardModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    value: 9.0,
                                    label: FFLocalizations.of(context).getText(
                                      'xhclap64' /* Network Reach */,
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
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
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).divider,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'fruc1nxh' /* Monthly Recommendations */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                ),
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: FlutterFlowTheme.of(context).success,
                                  size: 20.0,
                                ),
                              ],
                            ),
                            Expanded(
                              flex: 1,
                              child: FlutterFlowBarChart(
                                barData: [
                                  FFBarChartData(
                                    yData: ([12, 18, 15, 22, 30, 28])!,
                                    color: FlutterFlowTheme.of(context).primary,
                                  )
                                ],
                                xLabels: ([
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun'
                                ])!,
                                barWidth: 16.0,
                                barBorderRadius: BorderRadius.circular(4.0),
                                groupSpace: 12.0,
                                alignment: BarChartAlignment.spaceEvenly,
                                chartStylingInfo: ChartStylingInfo(
                                  backgroundColor: Colors.transparent,
                                  showBorder: false,
                                ),
                                axisBounds: AxisBounds(
                                  minY: 0.0,
                                  maxY: 36.0,
                                ),
                                xAxisLabelInfo: AxisLabelInfo(
                                  showLabels: true,
                                  labelTextStyle: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                  reservedSize: 28.0,
                                ),
                                yAxisLabelInfo: AxisLabelInfo(),
                              ),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      '8zhzfoeg' /* My Services */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                                  FFButtonWidget(
                                    onPressed: () {
                                      print('Button pressed ...');
                                    },
                                    text: FFLocalizations.of(context).getText(
                                      '4nwcz0lg' /* Add New */,
                                    ),
                                    icon: Icon(
                                      Icons.add_rounded,
                                      size: 15.0,
                                    ),
                                    options: FFButtonOptions(
                                      height: 44.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      iconColor:
                                          FlutterFlowTheme.of(context).primary,
                                      color: Colors.transparent,
                                      textStyle: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0,
                                      ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(22.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          wrapWithModel(
                            model: _model.serviceItemModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: ServiceItemWidget(
                              img_desc: 'massage therapy session',
                              name: 'Deep Tissue Massage',
                              duration: '60 min',
                              price: '\$85',
                            ),
                          ),
                          wrapWithModel(
                            model: _model.serviceItemModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: ServiceItemWidget(
                              img_desc: 'physiotherapy room',
                              name: 'Sports Recovery',
                              duration: '90 min',
                              price: '\$120',
                            ),
                          ),
                          wrapWithModel(
                            model: _model.serviceItemModel3,
                            updateCallback: () => safeSetState(() {}),
                            child: ServiceItemWidget(
                              img_desc: 'essential oils and spa',
                              name: 'Aromatherapy',
                              duration: '45 min',
                              price: '\$65',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'uh8ukhin' /* Quick Actions */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).divider,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
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
                                            Icons.person_outline_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'd5dbixsc' /* Edit Specialist Profile */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .divider,
                                          ),
                                        ].divide(SizedBox(width: 16.0)),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    indent: 48.0,
                                    color: FlutterFlowTheme.of(context).divider,
                                  ),
                                  Container(
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
                                            Icons.archive_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              '1y7dswkx' /* Archived Services */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .divider,
                                          ),
                                        ].divide(SizedBox(width: 16.0)),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    indent: 48.0,
                                    color: FlutterFlowTheme.of(context).divider,
                                  ),
                                  Container(
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
                                            Icons.share_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'bmiabt4i' /* Share Booking Link */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .divider,
                                          ),
                                        ].divide(SizedBox(width: 16.0)),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 0.0)),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Color(0xFFDBEAFE),
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      '55g0q9gl' /* Switch to Client Mode */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelLarge
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      'eozakv5a' /* Browse and book other services */,
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
                                          color: FlutterFlowTheme.of(context)
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
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                          ].divide(SizedBox(width: 16.0)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 32.0,
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.menuModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuWidget(
                  currentPage: Menu.dashboard,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
