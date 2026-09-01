import '/backend/backend.dart';
import '/backend/referral/your_master_highlight.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/init/sync_contacts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'specialist_service_card_map_model.dart';
export 'specialist_service_card_map_model.dart';

class SpecialistServiceCardMapWidget extends StatefulWidget {
  const SpecialistServiceCardMapWidget({super.key, required this.servDoc});

  final ServiceRecord? servDoc;

  @override
  State<SpecialistServiceCardMapWidget> createState() =>
      _SpecialistServiceCardMapWidgetState();
}

class _SpecialistServiceCardMapWidgetState
    extends State<SpecialistServiceCardMapWidget> {
  static const double _cardHeight = 112.0;
  static const double _titleHeight = 16.0 * 1.25 * 2;

  late SpecialistServiceCardMapModel _model;

  Set<String> get _serviceRecommenderHashes {
    final service = widget.servDoc;
    return service == null
        ? <String>{}
        : recommendationPhoneHashesForService(service);
  }

  int get _serviceRecommendationsCount => _serviceRecommenderHashes.length;

  int get _contactRecommendationsCount => _serviceRecommenderHashes
      .where((hash) => contactNameForPhoneHash(hash) != null)
      .length;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpecialistServiceCardMapModel());
  }

  Widget _metricBadge({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String value,
  }) {
    return Container(
      height: 24.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 2.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 1.0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: FlutterFlowTheme.of(context).primaryBackground,
            size: 14.0,
          ),
          const SizedBox(width: 4.0),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              color: FlutterFlowTheme.of(context).primaryBackground,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final service = widget.servDoc;
    if (service?.status != ServiceStatus.show) {
      return const SizedBox.shrink();
    }

    final categoryTitle = FFAppState().presetCategory
        .where((category) => category.key == service?.categoryKey)
        .firstOrNull
        ?.titleRU;
    final imageUrl = service?.image.firstOrNull ?? '';
    final imageCacheSize = (88 * MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(176, 528);

    final card = SizedBox(
      height: _cardHeight,
      child: Material(
        color: Colors.transparent,
        elevation: 4.0,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: FlutterFlowTheme.of(context).divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 88.0,
                  height: 88.0,
                  fit: BoxFit.cover,
                  memCacheWidth: imageCacheSize,
                  memCacheHeight: imageCacheSize,
                  maxWidthDiskCache: imageCacheSize * 2,
                  maxHeightDiskCache: imageCacheSize * 2,
                  errorWidget: (context, url, error) => Container(
                    width: 88.0,
                    height: 88.0,
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: FlutterFlowTheme.of(context).divider,
                      size: 30.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryTitle ?? 'Без категории',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 11.0,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    SizedBox(
                      height: _titleHeight,
                      width: double.infinity,
                      child: Text(
                        service?.title ?? 'Без названия',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.payment_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            formatPrice(service?.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if ((service?.time ?? 0) > 0) ...[
                          const SizedBox(width: 8.0),
                          Icon(
                            Icons.access_time,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 14.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            service!.formattedDuration,
                            maxLines: 1,
                            style: GoogleFonts.jetBrainsMono(
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (_serviceRecommendationsCount > 0) ...[
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 72.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _metricBadge(
                        context: context,
                        color: FlutterFlowTheme.of(context).primary,
                        icon: Icons.thumb_up_alt_rounded,
                        value: '$_serviceRecommendationsCount',
                      ),
                      const SizedBox(height: 6.0),
                      _metricBadge(
                        context: context,
                        color: FlutterFlowTheme.of(context).accent3,
                        icon: Icons.people,
                        value: '$_contactRecommendationsCount',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return YourMasterServiceFrame(
      service: service!,
      borderRadius: 16.0,
      child: card,
    );
  }
}
