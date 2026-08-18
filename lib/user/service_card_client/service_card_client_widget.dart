import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/init/sync_contacts.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'service_card_client_model.dart';
export 'service_card_client_model.dart';

class ServiceCardClientWidget extends StatefulWidget {
  const ServiceCardClientWidget({super.key, required this.servicedoc});

  final ServiceRecord? servicedoc;

  @override
  State<ServiceCardClientWidget> createState() =>
      _ServiceCardClientWidgetState();
}

class _ServiceCardClientWidgetState extends State<ServiceCardClientWidget> {
  static const double _titleHeight = 14.0 * 1.3 * 2;

  late ServiceCardClientModel _model;

  Set<String> get _serviceRecommenderPhones {
    final phones = <String>{};
    final service = widget.servicedoc;
    if (service == null) return phones;
    for (final phone in service.recommenderPhones) {
      final normalized = normalizePhone(phone);
      if (normalized.isNotEmpty) phones.add(normalized);
    }
    for (final recommendation in service.recommendations) {
      final normalized = normalizePhone(recommendation.phone);
      if (normalized.isNotEmpty) phones.add(normalized);
    }
    return phones;
  }

  int get _serviceRecommendationsCount => _serviceRecommenderPhones.length;

  int get _contactRecommendationsCount =>
      _serviceRecommenderPhones.where(globalContactsMap.containsKey).length;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServiceCardClientModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.servicedoc?.status != ServiceStatus.show) {
      return const SizedBox.shrink();
    }

    final imageCacheWidth = (200 * MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(320, 800)
        .toInt();

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        context.pushNamed(
          ServiceDetailWidget.routeName,
          queryParameters: {
            'serviceDoc': serializeParam(
              widget!.servicedoc,
              ParamType.Document,
            ),
          }.withoutNulls,
          extra: <String, dynamic>{'serviceDoc': widget!.servicedoc},
        );
      },
      child: Material(
        color: Colors.transparent,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            height: 280.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160.0,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 0),
                        fadeOutDuration: Duration(milliseconds: 0),
                        imageUrl: widget!.servicedoc?.image.firstOrNull ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: imageCacheWidth,
                        memCacheHeight: imageCacheWidth,
                        maxWidthDiskCache: imageCacheWidth * 2,
                        maxHeightDiskCache: imageCacheWidth * 2,
                        errorWidget: (context, url, error) => Container(
                          color: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: FlutterFlowTheme.of(context).divider,
                            size: 40.0,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: AuthUserStreamWidget(
                              builder: (context) => FlutterFlowIconButton(
                                borderRadius: 12.0,
                                buttonSize: 32.0,
                                fillColor: FlutterFlowTheme.of(
                                  context,
                                ).tertiary,
                                icon: Icon(
                                  Icons.favorite,
                                  color:
                                      (currentUserDocument?.favoriteServices
                                                  ?.toList() ??
                                              [])
                                          .contains(
                                            widget!.servicedoc?.reference,
                                          )
                                      ? FlutterFlowTheme.of(context).error
                                      : FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                  size: 16.0,
                                ),
                                showLoadingIndicator: true,
                                onPressed: () async {
                                  if ((currentUserDocument?.favoriteServices
                                              ?.toList() ??
                                          [])
                                      .contains(
                                        widget!.servicedoc?.reference,
                                      )) {
                                    await currentUserReference!.update({
                                      ...mapToFirestore({
                                        'favoriteServices':
                                            FieldValue.arrayRemove([
                                              widget!.servicedoc?.reference,
                                            ]),
                                      }),
                                    });
                                  } else {
                                    await currentUserReference!.update({
                                      ...mapToFirestore({
                                        'favoriteServices':
                                            FieldValue.arrayUnion([
                                              widget!.servicedoc?.reference,
                                            ]),
                                      }),
                                    });
                                  }

                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
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
                            SizedBox(
                              width: double.infinity,
                              height: _titleHeight,
                              child: Align(
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  valueOrDefault<String>(
                                    widget!.servicedoc?.title,
                                    'Без названия',
                                  ),
                                  maxLines: 2,
                                  style: FlutterFlowTheme.of(context).labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).labelLarge.fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payment_rounded,
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                  size: 14.0,
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    formatNumber(
                                      widget!.servicedoc?.price,
                                      formatType: FormatType.decimal,
                                      decimalType: DecimalType.automatic,
                                      currency: '₽',
                                    ),
                                    'Цена не указана',
                                  ),
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context).labelSmall
                                      .override(
                                        font: GoogleFonts.jetBrainsMono(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelSmall.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).labelSmall.fontStyle,
                                        lineHeight: 1.2,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((widget.servicedoc?.time ?? 0) > 0)
                                  Text(
                                    FFLocalizations.of(
                                      context,
                                    ).getText('yxlz56k4' /* • */),
                                    maxLines: 1,
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.jetBrainsMono(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryText,
                                          fontSize: 10.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelSmall.fontStyle,
                                          lineHeight: 1.2,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ].divide(SizedBox(width: 4.0)),
                            ),
                            if ((widget.servicedoc?.time ?? 0) > 0)
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).secondaryText,
                                    size: 14.0,
                                  ),
                                  Text(
                                    widget.servicedoc!.formattedDuration,
                                    maxLines: 1,
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.jetBrainsMono(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryText,
                                          fontSize: 10.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelSmall.fontStyle,
                                          lineHeight: 1.2,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ].divide(SizedBox(width: 4.0)),
                              ),
                          ].divide(SizedBox(width: 4.0)),
                        ),
                        if (_serviceRecommendationsCount > 0)
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2.0,
                                        color: Color(0x1A000000),
                                        offset: Offset(0.0, 1.0),
                                        spreadRadius: 0.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0,
                                      4.0,
                                      8.0,
                                      4.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.thumb_up_alt_rounded,
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryBackground,
                                          size: 14.0,
                                        ),
                                        Text(
                                          '$_serviceRecommendationsCount',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                                fontSize: 10.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).labelSmall.fontStyle,
                                                lineHeight: 1.2,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 4.0)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).accent3,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2.0,
                                        color: Color(0x1A000000),
                                        offset: Offset(0.0, 1.0),
                                        spreadRadius: 0.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0,
                                      4.0,
                                      8.0,
                                      4.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people,
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryBackground,
                                          size: 14.0,
                                        ),
                                        Text(
                                          '$_contactRecommendationsCount',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                                fontSize: 10.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).labelSmall.fontStyle,
                                                lineHeight: 1.2,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 4.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                      ].divide(SizedBox(height: 4.0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
