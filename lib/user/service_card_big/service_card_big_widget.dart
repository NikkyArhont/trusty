import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/contact_avatars_widget.dart';
import '/components/trust_badge_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'service_card_big_model.dart';
export 'service_card_big_model.dart';

class ServiceCardBigWidget extends StatefulWidget {
  const ServiceCardBigWidget({super.key, required this.servDoc});

  final ServiceRecord? servDoc;

  @override
  State<ServiceCardBigWidget> createState() => _ServiceCardBigWidgetState();
}

class _ServiceCardBigWidgetState extends State<ServiceCardBigWidget> {
  late ServiceCardBigModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServiceCardBigModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 2.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 1.0),
                spreadRadius: 0.0,
              ),
            ],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: 180.0,
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 1000),
                      fadeOutDuration: Duration(milliseconds: 1000),
                      imageUrl: widget!.servDoc!.image.firstOrNull!,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => Image.asset(
                        'assets/images/error_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(1.0, -1.0),
                    child: wrapWithModel(
                      model: _model.trustBadgeModel,
                      updateCallback: () => safeSetState(() {}),
                      child: TrustBadgeWidget(score: '0'),
                    ),
                  ),
                ],
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valueOrDefault<String>(
                                    widget!.servDoc?.title,
                                    'Без названия',
                                  ),
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context).titleLarge
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).titleLarge.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).titleLarge.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(
                                          context,
                                        ).titleLarge.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).titleLarge.fontStyle,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    widget!.servDoc?.description,
                                    'Без описания',
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyMedium
                                      .override(
                                        font: GoogleFonts.jetBrainsMono(
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(
                                          context,
                                        ).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).bodyMedium.fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                          ),
                          Text(
                            formatNumber(
                              widget!.servDoc!.price,
                              formatType: FormatType.decimal,
                              decimalType: DecimalType.automatic,
                              currency: '₽',
                            ),
                            style: FlutterFlowTheme.of(context).titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(
                                      context,
                                    ).titleMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).titleMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(
                                    context,
                                  ).titleMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).titleMedium.fontStyle,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if ((widget.servDoc?.time ?? 0) > 0)
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                  size: 16.0,
                                ),
                                Text(
                                  widget.servDoc!.formattedDuration,
                                  style: FlutterFlowTheme.of(context).bodySmall
                                      .override(
                                        font: GoogleFonts.jetBrainsMono(
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).bodySmall.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodySmall.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(
                                          context,
                                        ).bodySmall.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).bodySmall.fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(width: 4.0)),
                            ),
                          Text(
                            valueOrDefault<String>(
                              FFAppState().presetCategory
                                  .where(
                                    (e) =>
                                        e.key == widget!.servDoc?.categoryKey,
                                  )
                                  .toList()
                                  .firstOrNull
                                  ?.titleRU,
                              'Без категории',
                            ),
                            style: FlutterFlowTheme.of(context).bodySmall
                                .override(
                                  font: GoogleFonts.jetBrainsMono(
                                    fontWeight: FlutterFlowTheme.of(
                                      context,
                                    ).bodySmall.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodySmall.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(
                                    context,
                                  ).bodySmall.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).bodySmall.fontStyle,
                                ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          8.0,
                          0.0,
                          8.0,
                        ),
                        child: Divider(
                          color: FlutterFlowTheme.of(context).divider,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          wrapWithModel(
                            model: _model.contactAvatarsModel,
                            updateCallback: () => safeSetState(() {}),
                            child: ContactAvatarsWidget(),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'egijd7bc' /* Recommended by 48 people */,
                              ),
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context).labelMedium
                                  .override(
                                    font: GoogleFonts.jetBrainsMono(
                                      fontWeight: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(
                                      context,
                                    ).labelMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).labelMedium.fontStyle,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                      Container(height: 8.0),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Stack(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryBackground,
                                          size: 16.0,
                                        ),
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            '7cyqb1tx' /* Book Session */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelMedium.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).labelMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).labelMedium.fontStyle,
                                              ),
                                        ),
                                        Container(width: 0.0, height: 0.0),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                    Container(width: 0.0, height: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AuthUserStreamWidget(
                            builder: (context) => FlutterFlowIconButton(
                              borderRadius: 12.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context).tertiary,
                              icon: Icon(
                                Icons.favorite,
                                color:
                                    (currentUserDocument?.favoriteServices
                                                ?.toList() ??
                                            [])
                                        .contains(widget!.servDoc?.reference)
                                    ? FlutterFlowTheme.of(context).error
                                    : FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                size: 24.0,
                              ),
                              showLoadingIndicator: true,
                              onPressed: () async {
                                if ((currentUserDocument?.favoriteServices
                                            ?.toList() ??
                                        [])
                                    .contains(widget!.servDoc?.reference)) {
                                  await currentUserReference!.update({
                                    ...mapToFirestore({
                                      'favoriteServices':
                                          FieldValue.arrayRemove([
                                            widget!.servDoc?.reference,
                                          ]),
                                    }),
                                  });
                                } else {
                                  await currentUserReference!.update({
                                    ...mapToFirestore({
                                      'favoriteServices': FieldValue.arrayUnion(
                                        [widget!.servDoc?.reference],
                                      ),
                                    }),
                                  });
                                }

                                safeSetState(() {});
                              },
                            ),
                          ),
                        ].divide(SizedBox(width: 16.0)),
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
