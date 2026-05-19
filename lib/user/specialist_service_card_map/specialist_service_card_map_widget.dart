import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'specialist_service_card_map_model.dart';
export 'specialist_service_card_map_model.dart';

class SpecialistServiceCardMapWidget extends StatefulWidget {
  const SpecialistServiceCardMapWidget({
    super.key,
    required this.servDoc,
  });

  final ServiceRecord? servDoc;

  @override
  State<SpecialistServiceCardMapWidget> createState() =>
      _SpecialistServiceCardMapWidgetState();
}

class _SpecialistServiceCardMapWidgetState
    extends State<SpecialistServiceCardMapWidget> {
  late SpecialistServiceCardMapModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpecialistServiceCardMapModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).secondaryText,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 0),
                              fadeOutDuration: Duration(milliseconds: 0),
                              imageUrl: widget!.servDoc!.image.firstOrNull!,
                              width: 64.0,
                              height: 64.0,
                              fit: BoxFit.cover,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    valueOrDefault<String>(
                                      widget!.servDoc?.title,
                                      'noTitle',
                                    ),
                                    maxLines: 1,
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    valueOrDefault<String>(
                                      FFAppState()
                                          .presetCategory
                                          .where((e) =>
                                              e.key ==
                                              widget!.servDoc?.categoryKey)
                                          .toList()
                                          .firstOrNull
                                          ?.titleRU,
                                      'noCat',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.jetBrainsMono(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .fontStyle,
                                        ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                          Icon(
                                            Icons.payment_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 16.0,
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              formatNumber(
                                                widget!.servDoc?.price,
                                                formatType: FormatType.decimal,
                                                decimalType:
                                                    DecimalType.automatic,
                                                currency: '₽',
                                              ),
                                              '0',
                                            ),
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font:
                                                      GoogleFonts.jetBrainsMono(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (widget!.servDoc?.hasTime() ??
                                              true)
                                            Text(
                                              FFLocalizations.of(context)
                                                  .getText(
                                                'ckzmreej' /* • */,
                                              ),
                                              maxLines: 1,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .override(
                                                    font: GoogleFonts
                                                        .jetBrainsMono(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                    lineHeight: 1.2,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ].divide(SizedBox(width: 4.0)),
                                      ),
                                      if (widget!.servDoc?.hasTime() ?? true)
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 16.0,
                                            ),
                                            Text(
                                              valueOrDefault<String>(
                                                widget!.servDoc?.time
                                                    ?.toString(),
                                                '0',
                                              ),
                                              maxLines: 1,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .override(
                                                    font: GoogleFonts
                                                        .jetBrainsMono(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                    lineHeight: 1.2,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ].divide(SizedBox(width: 4.0)),
                                        ),
                                    ].divide(SizedBox(width: 2.0)),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.thumb_up_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 14.0,
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        '7ghk9fw8' /* 12 Recs */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.jetBrainsMono(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 14.0,
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'hborns68' /* 24 Clients */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.jetBrainsMono(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 4.0)),
                    ),
                  ),
                ].divide(SizedBox(width: 16.0)),
              ),
            ].divide(SizedBox(height: 4.0)),
          ),
        ),
      ),
    );
  }
}
