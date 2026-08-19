import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/serv_status_widget.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/master/del_serv/del_serv_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '/init/sync_contacts.dart';
import 'specialist_service_card_model.dart';
export 'specialist_service_card_model.dart';

class SpecialistServiceCardWidget extends StatefulWidget {
  const SpecialistServiceCardWidget({
    super.key,
    required this.servDoc,
    this.filterStartDate,
    this.allCompletedRecords,
  });

  final ServiceRecord? servDoc;
  final DateTime? filterStartDate;
  final List<RecordsRecord>? allCompletedRecords;

  @override
  State<SpecialistServiceCardWidget> createState() =>
      _SpecialistServiceCardWidgetState();
}

class _SpecialistServiceCardWidgetState
    extends State<SpecialistServiceCardWidget> {
  late SpecialistServiceCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpecialistServiceCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16.0),
              Text(
                '$count',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                ),
              ),
            ].divide(const SizedBox(width: 5.0)),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).labelSmall.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.w500),
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
            ),
          ),
        ].divide(const SizedBox(height: 2.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Calculate stats specifically for this service
    final serviceRef = widget.servDoc?.reference;
    final serviceRecords =
        widget.allCompletedRecords
            ?.where((r) => r.service == serviceRef)
            .toList() ??
        [];
    final filteredServiceRecords = widget.filterStartDate == null
        ? serviceRecords
        : serviceRecords
              .where(
                (r) =>
                    r.date != null && r.date!.isAfter(widget.filterStartDate!),
              )
              .toList();

    final int visitsCount = filteredServiceRecords.length;

    final Set<String> uniqueClients = {};
    for (var r in filteredServiceRecords) {
      final clientId = r.clientPhone.isNotEmpty
          ? r.clientPhone
          : (r.client?.path ?? '');
      if (clientId.isNotEmpty) {
        uniqueClients.add(clientId);
      }
    }
    final int clientsCount = uniqueClients.length;

    final Set<String> filteredRecommenders = {};
    final Set<String> structPhones = {};
    if (widget.servDoc != null) {
      for (var rec in widget.servDoc!.recommendations) {
        if (rec.phone.isNotEmpty) {
          structPhones.add(rec.phone);
          if (widget.filterStartDate != null && rec.date != null) {
            if (rec.date!.isAfter(widget.filterStartDate!)) {
              filteredRecommenders.add(rec.phone);
            }
          } else {
            filteredRecommenders.add(rec.phone);
          }
        }
      }
      for (var phone in widget.servDoc!.recommenderPhones) {
        if (phone.isNotEmpty && !structPhones.contains(phone)) {
          filteredRecommenders.add(phone);
        }
      }
    }
    final int recommendationsCount = filteredRecommenders.length;

    final serviceImages = widget.servDoc?.image.toList() ?? <String>[];
    final previewImage = serviceImages.isNotEmpty ? serviceImages.first : null;
    final categoryTitle = valueOrDefault<String>(
      FFAppState().presetCategory
          .where((e) => e.key == widget.servDoc?.categoryKey)
          .toList()
          .firstOrNull
          ?.titleRU,
      'Без категории',
    );

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: widget.servDoc == null
            ? null
            : () {
                context.pushNamed(
                  ServiceDetailWidget.routeName,
                  queryParameters: {
                    'serviceDoc': serializeParam(
                      widget.servDoc,
                      ParamType.Document,
                    ),
                  }.withoutNulls,
                  extra: <String, dynamic>{'serviceDoc': widget.servDoc},
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (previewImage != null)
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: FlutterFlowExpandedImageView(
                                image: CachedNetworkImage(
                                  fadeInDuration: Duration(milliseconds: 0),
                                  fadeOutDuration: Duration(milliseconds: 0),
                                  imageUrl: previewImage,
                                  fit: BoxFit.contain,
                                ),
                                allowRotation: false,
                                tag: previewImage,
                                useHeroAnimation: true,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Hero(
                            tag: previewImage,
                            transitionOnUserGestures: true,
                            child: CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 0),
                              fadeOutDuration: Duration(milliseconds: 0),
                              imageUrl: previewImage,
                              width: 124.0,
                              height: 124.0,
                              fit: BoxFit.cover,
                              memCacheWidth: 372,
                              memCacheHeight: 372,
                              maxWidthDiskCache: 744,
                              maxHeightDiskCache: 744,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 124.0,
                        height: 124.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent4,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 32.0,
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    valueOrDefault<String>(
                                      widget.servDoc?.title,
                                      'Без названия',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FlutterFlowTheme.of(
                                              context,
                                            ).titleMedium.fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).titleMedium.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(
                                            context,
                                          ).titleMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).titleMedium.fontStyle,
                                        ),
                                  ),
                                  Text(
                                    categoryTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
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
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
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
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .labelSmall
                                                                .fontStyle,
                                                      ),
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).primary,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if ((widget.servDoc?.time ?? 0) > 0)
                                            Text(
                                              FFLocalizations.of(
                                                context,
                                              ).getText('19y85y6g' /* • */),
                                              maxLines: 1,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).labelSmall.override(
                                                    font: GoogleFonts.jetBrainsMono(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .labelSmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelSmall.fontStyle,
                                                    lineHeight: 1.2,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ].divide(SizedBox(width: 4.0)),
                                      ),
                                      if ((widget.servDoc?.time ?? 0) > 0)
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                              size: 16.0,
                                            ),
                                            Text(
                                              widget.servDoc!.formattedDuration,
                                              maxLines: 1,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).labelSmall.override(
                                                    font: GoogleFonts.jetBrainsMono(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .labelSmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
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
                                ].divide(SizedBox(height: 4.0)),
                              ),
                              if (widget.servDoc?.hasStatus() ?? false)
                                wrapWithModel(
                                  model: _model.servStatusModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ServStatusWidget(
                                    status: widget.servDoc!.status!,
                                  ),
                                ),
                            ],
                          ),
                        ].divide(SizedBox(height: 4.0)),
                      ),
                    ),
                  ].divide(SizedBox(width: 16.0)),
                ),

                Text(
                  valueOrDefault<String>(
                    widget!.servDoc?.description,
                    'Без описания',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.jetBrainsMono(
                      fontWeight: FlutterFlowTheme.of(
                        context,
                      ).bodySmall.fontWeight,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).bodySmall.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(
                      context,
                    ).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
                ),
                Row(
                  children: [
                    _buildMetric(
                      context,
                      icon: Icons.thumb_up_alt_rounded,
                      color: FlutterFlowTheme.of(context).accent3,
                      count: recommendationsCount,
                      label: 'Рекомендации',
                    ),
                    _buildMetric(
                      context,
                      icon: Icons.people_alt_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      count: clientsCount,
                      label: 'Клиенты',
                    ),
                    _buildMetric(
                      context,
                      icon: Icons.event_available_rounded,
                      color: FlutterFlowTheme.of(context).success,
                      count: visitsCount,
                      label: 'Посещения',
                    ),
                  ],
                ),
                if (widget.servDoc?.status == ServiceStatus.denied &&
                    widget.servDoc!.moderationReason.trim().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(
                        context,
                      ).error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FlutterFlowTheme.of(
                          context,
                        ).error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: FlutterFlowTheme.of(context).error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Причина отклонения',
                                style: FlutterFlowTheme.of(context).labelMedium
                                    .override(
                                      color: FlutterFlowTheme.of(context).error,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.servDoc!.moderationReason,
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) => FFButtonWidget(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: 36.0,
                                ),
                                backgroundColor: Colors.transparent,
                                alignment: AlignmentDirectional(
                                  0.0,
                                  0.0,
                                ).resolve(Directionality.of(context)),
                                child: DelServWidget(
                                  servTodel: widget!.servDoc!,
                                ),
                              );
                            },
                          );
                        },
                        text: FFLocalizations.of(
                          context,
                        ).getText('048gzdbj' /* Удалить */),
                        icon: Icon(Icons.archive_rounded, size: 15.0),
                        options: FFButtonOptions(
                          height: 36.0,
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
                          iconColor: FlutterFlowTheme.of(context).error,
                          color: Colors.transparent,
                          textStyle: TextStyle(
                            color: FlutterFlowTheme.of(context).error,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: () async {
                          context.pushNamed(
                            EditServiceWidget.routeName,
                            queryParameters: {
                              'servDoc': serializeParam(
                                widget!.servDoc,
                                ParamType.Document,
                              ),
                            }.withoutNulls,
                            extra: <String, dynamic>{
                              'servDoc': widget!.servDoc,
                            },
                          );
                        },
                        text: FFLocalizations.of(
                          context,
                        ).getText('h1eckqjc' /* Редактировать */),
                        icon: Icon(Icons.edit_rounded, size: 15.0),
                        options: FFButtonOptions(
                          height: 44.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                            10.0,
                            0.0,
                            10.0,
                            0.0,
                          ),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            0.0,
                            4.0,
                            0.0,
                          ),
                          iconColor: FlutterFlowTheme.of(
                            context,
                          ).primaryBackground,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: TextStyle(
                            color: FlutterFlowTheme.of(
                              context,
                            ).primaryBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                  ].divide(SizedBox(width: 8.0)),
                ),
              ].divide(SizedBox(height: 4.0)),
            ),
          ),
        ),
      ),
    );
  }
}
