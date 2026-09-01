import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/analytics/analytics_service.dart';
import '/backend/guest/guest_access.dart';
import '/backend/public_master_profile.dart';
import '/backend/referral/your_master_highlight.dart';
import '/backend/schema/enums/enums.dart';
import '/components/contact_recommendation_widget.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/contacts_sync_prompt/contacts_sync_prompt_widget.dart';
import '/global_comp/master_contact_badge/master_contact_badge_widget.dart';
import '/global_comp/recommendation_metrics/recommendation_metrics_widget.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '/init/sync_contacts.dart';
import '/user/recommend_dialog/recommend_dialog_widget.dart';
import 'service_detail_model.dart';
export 'service_detail_model.dart';

class ServiceDetailWidget extends StatefulWidget {
  const ServiceDetailWidget({super.key, this.serviceDoc});

  final ServiceRecord? serviceDoc;

  static String routeName = 'ServiceDetail';
  static String routePath = '/serviceDetail';

  @override
  State<ServiceDetailWidget> createState() => _ServiceDetailWidgetState();
}

class _ServiceDetailWidgetState extends State<ServiceDetailWidget> {
  late ServiceDetailModel _model;
  ServiceRecord? _currentServiceDoc;
  UserRecord? _publicMasterProfile;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasCompletedService = false;
  bool _isOpeningMasterPage = false;
  final math.Random _random = math.Random();
  int? _randomRecommendationIndex;

  String _legacyPhoneHash(String rawPhone) {
    final normalized = normalizePhone(rawPhone);
    return normalized.isEmpty ? '' : phoneHash(normalized);
  }

  String _recommendationHash(RecommendationStruct recommendation) {
    final savedHash = recommendation.phoneHash.trim().toLowerCase();
    return savedHash.isNotEmpty
        ? savedHash
        : _legacyPhoneHash(recommendation.phone);
  }

  Set<String> _recommendationHashes(ServiceRecord? service) {
    if (service == null) return <String>{};
    return <String>{
      ...service.recommenderPhoneHashes.map(
        (hash) => hash.trim().toLowerCase(),
      ),
      ...service.recommenderPhones.map(_legacyPhoneHash),
      ...service.recommendations.map(_recommendationHash),
    }..removeWhere((hash) => hash.isEmpty);
  }

  List<RecommendationStruct> _textRecommendations(ServiceRecord? service) =>
      service?.recommendations
          .where((recommendation) => recommendation.comment.trim().isNotEmpty)
          .toList() ??
      const <RecommendationStruct>[];

  int? _initialRandomRecommendationIndex(ServiceRecord? service) {
    final recommendations = _textRecommendations(service);
    return recommendations.isEmpty
        ? null
        : _random.nextInt(recommendations.length);
  }

  void _refreshRandomRecommendation() {
    final recommendations = _textRecommendations(_currentServiceDoc);
    if (recommendations.isEmpty) return;
    final current = _randomRecommendationIndex;
    if (recommendations.length == 1) {
      safeSetState(() => _randomRecommendationIndex = 0);
      return;
    }

    var next = _random.nextInt(recommendations.length - 1);
    if (current != null && current >= 0 && current < recommendations.length) {
      if (next >= current) next += 1;
    }
    safeSetState(() => _randomRecommendationIndex = next);
  }

  Future<void> _checkCompletedService() async {
    final clientRef = currentUserReference;
    final serviceRef = widget.serviceDoc?.reference;
    if (clientRef == null || serviceRef == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('records')
          .where('client', isEqualTo: clientRef)
          .get();
      final hasCompletedService = query.docs.any((recordSnapshot) {
        final recordData = recordSnapshot.data();
        return recordData['service'] == serviceRef &&
            recordData['status'] == RecordStatus.complite.serialize();
      });

      if (mounted) {
        setState(() {
          _hasCompletedService = hasCompletedService;
        });
      }
    } catch (e) {
      print('Error checking completed service: $e');
    }
  }

  String _getPeopleNoun(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) {
      return 'человек';
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'человека';
    } else {
      return 'человек';
    }
  }

  String _getContactsNoun(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) {
      return 'контакт';
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'контакта';
    } else {
      return 'контактов';
    }
  }

  Future<void> _callRecommender(String recommenderHash) async {
    final normalizedPhone = contactPhoneForPhoneHash(recommenderHash);
    if (normalizedPhone == null || normalizedPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Номер не найден в контактах')),
        );
      }
      return;
    }
    final phone =
        normalizedPhone.length == 11 && normalizedPhone.startsWith('7')
        ? '+$normalizedPhone'
        : normalizedPhone;
    try {
      final opened = await launchUrl(
        Uri(scheme: 'tel', path: phone),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть приложение телефона'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть приложение телефона'),
          ),
        );
      }
    }
  }

  Future<void> _openOrCreateChat() async {
    if (!await requireRegisteredUser(
      context,
      reason: 'Чтобы написать мастеру, подтвердите номер телефона.',
    )) {
      return;
    }
    final currentUserRef = currentUserReference;
    final masterRef = widget.serviceDoc?.owner;
    if (currentUserRef == null || masterRef == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось открыть чат')));
      return;
    }
    if (currentUserRef == masterRef) {
      context.pushNamed(
        EditServiceWidget.routeName,
        queryParameters: {
          'servDoc': serializeParam(widget.serviceDoc, ParamType.Document),
        }.withoutNulls,
        extra: <String, dynamic>{'servDoc': widget.serviceDoc},
      );
      return;
    }

    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc('client_${currentUserRef.id}_master_${masterRef.id}');
      final now = getCurrentTimestamp;
      await chatRef.set({
        'client': currentUserRef,
        'master': masterRef,
        'participants': [currentUserRef, masterRef],
        'participantIds': [currentUserRef.id, masterRef.id],
        'clientName': currentUserDisplayName,
        'clientPhoto': currentUserPhoto,
        'clientPhone': currentPhoneNumber,
        'masterName': widget.serviceDoc?.masterTitle ?? '',
        'masterPhoto': widget.serviceDoc?.masterPhoto ?? '',
        'created_time': now,
        'updated_time': now,
        'context': 'service',
        'service': widget.serviceDoc?.reference,
      }, SetOptions(merge: true));

      final service = widget.serviceDoc;
      if (service != null) {
        AnalyticsService.instance.logMasterContact(
          serviceId: service.reference.id,
          category: service.categoryKey,
          price: service.price,
        );
      }

      if (!mounted) {
        return;
      }
      context.pushNamed(
        ChatWidget.routeName,
        queryParameters: {
          'chatId': serializeParam(chatRef.id, ParamType.String),
        }.withoutNulls,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка открытия чата: $error')));
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServiceDetailModel());
    _currentServiceDoc = widget.serviceDoc;
    _randomRecommendationIndex = _initialRandomRecommendationIndex(
      _currentServiceDoc,
    );

    final service = widget.serviceDoc;
    if (service != null) {
      AnalyticsService.instance.logServiceView(
        serviceId: service.reference.id,
        title: service.title,
        category: service.categoryKey,
        price: service.price,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await syncContacts();
      if (mounted) safeSetState(() {});
    });
    _checkCompletedService();
    final ownerRef = widget.serviceDoc?.owner;
    if (ownerRef != null) {
      unawaited(
        loadPublicMasterProfile(ownerRef).then((profile) {
          if (mounted && profile != null) {
            safeSetState(() => _publicMasterProfile = profile);
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final recommendationHashes = _recommendationHashes(_currentServiceDoc);
    final recommenderContacts =
        recommendationHashes
            .map((hash) {
              final name = contactNameForPhoneHash(hash)?.trim();
              return name == null || name.isEmpty
                  ? null
                  : MapEntry<String, String>(hash, name);
            })
            .whereType<MapEntry<String, String>>()
            .toList()
          ..sort((first, second) => first.value.compareTo(second.value));
    final userRecommendations = _textRecommendations(_currentServiceDoc);
    final selectedRecommendation = userRecommendations.isEmpty
        ? null
        : userRecommendations[(_randomRecommendationIndex ?? 0).clamp(
            0,
            userRecommendations.length - 1,
          )];
    final contactRecommendationsCount = recommendationHashes
        .where((hash) => contactNameForPhoneHash(hash) != null)
        .length;

    final isOwnService =
        _currentServiceDoc?.owner != null &&
        _currentServiceDoc?.owner == currentUserReference;

    final rawUserPhone = currentPhoneNumber.isNotEmpty
        ? currentPhoneNumber
        : (currentUserDocument?.phoneNumber ?? '');
    final normalizedUserPhone = normalizePhone(rawUserPhone);
    final normalizedUserPhoneHash = normalizedUserPhone.isEmpty
        ? ''
        : phoneHash(normalizedUserPhone);
    final hasAlreadyRecommended =
        normalizedUserPhoneHash.isNotEmpty &&
        recommendationHashes.contains(normalizedUserPhoneHash);
    final masterContactName = contactNameForPhoneHash(
      _publicMasterProfile?.contactPhoneHash ?? '',
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            border: Border.all(
              color: FlutterFlowTheme.of(context).divider,
              width: 1.0,
            ),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(
                      context,
                    ).getText('r2v4ytku' /* Response time */),
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.jetBrainsMono(
                        fontWeight: FlutterFlowTheme.of(
                          context,
                        ).labelSmall.fontWeight,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).labelSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(
                        context,
                      ).labelSmall.fontWeight,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).labelSmall.fontStyle,
                    ),
                  ),
                  Text(
                    FFLocalizations.of(
                      context,
                    ).getText('lawnsui4' /* ~15 mins */),
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.jetBrainsMono(
                        fontWeight: FlutterFlowTheme.of(
                          context,
                        ).labelMedium.fontWeight,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).labelMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).success,
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(
                        context,
                      ).labelMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).labelMedium.fontStyle,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (isOwnService) {
                      context.pushNamed(
                        EditServiceWidget.routeName,
                        queryParameters: {
                          'servDoc': serializeParam(
                            widget.serviceDoc,
                            ParamType.Document,
                          ),
                        }.withoutNulls,
                        extra: <String, dynamic>{'servDoc': widget.serviceDoc},
                      );
                      return;
                    }
                    await _openOrCreateChat();
                  },
                  child: Container(
                    height: 52.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      14.0,
                      0.0,
                      14.0,
                      0.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isOwnService
                              ? Icons.edit_rounded
                              : Icons.chat_bubble_outline_rounded,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          size: 18.0,
                        ),
                        Flexible(
                          child: Text(
                            isOwnService ? 'Редактировать' : 'Написать',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).labelMedium
                                .override(
                                  font: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).labelMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryBackground,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).labelMedium.fontStyle,
                                ),
                          ),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
                  ),
                ),
              ),
            ].divide(SizedBox(width: 16.0)),
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          primary: false,
          padding: EdgeInsets.only(bottom: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 340.0,
                child: Stack(
                  children: [
                    Container(
                      height: 400.0,
                      child: Builder(
                        builder: (context) {
                          final loadImages =
                              widget!.serviceDoc?.image?.toList() ?? [];

                          return Container(
                            width: double.infinity,
                            height: 400.0,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _model.pageViewController ??=
                                      PageController(
                                        initialPage: max(
                                          0,
                                          min(0, loadImages.length - 1),
                                        ),
                                      ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: loadImages.length,
                                  itemBuilder: (context, loadImagesIndex) {
                                    final loadImagesItem =
                                        loadImages[loadImagesIndex];
                                    return InkWell(
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
                                                fadeInDuration: Duration(
                                                  milliseconds: 0,
                                                ),
                                                fadeOutDuration: Duration(
                                                  milliseconds: 0,
                                                ),
                                                imageUrl: loadImagesItem,
                                                fit: BoxFit.contain,
                                              ),
                                              allowRotation: false,
                                              tag: loadImagesItem,
                                              useHeroAnimation: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: loadImagesItem,
                                        transitionOnUserGestures: true,
                                        child: CachedNetworkImage(
                                          fadeInDuration: Duration(
                                            milliseconds: 0,
                                          ),
                                          fadeOutDuration: Duration(
                                            milliseconds: 0,
                                          ),
                                          imageUrl: loadImagesItem,
                                          height: 400.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0,
                                      0.0,
                                      0.0,
                                      16.0,
                                    ),
                                    child:
                                        smooth_page_indicator.SmoothPageIndicator(
                                          controller:
                                              _model.pageViewController ??=
                                                  PageController(
                                                    initialPage: max(
                                                      0,
                                                      min(
                                                        0,
                                                        loadImages.length - 1,
                                                      ),
                                                    ),
                                                  ),
                                          count: loadImages.length,
                                          axisDirection: Axis.horizontal,
                                          onDotClicked: (i) async {
                                            await _model.pageViewController!
                                                .animateToPage(
                                                  i,
                                                  duration: Duration(
                                                    milliseconds: 500,
                                                  ),
                                                  curve: Curves.ease,
                                                );
                                            safeSetState(() {});
                                          },
                                          effect:
                                              smooth_page_indicator.SlideEffect(
                                                spacing: 8.0,
                                                radius: 8.0,
                                                dotWidth: 8.0,
                                                dotHeight: 8.0,
                                                dotColor: FlutterFlowTheme.of(
                                                  context,
                                                ).secondary,
                                                activeDotColor:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                paintStyle: PaintingStyle.fill,
                                              ),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, -1.0),
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              wrapWithModel(
                                model: _model.navBackModel,
                                updateCallback: () => safeSetState(() {}),
                                child: NavBackWidget(),
                              ),
                              AuthUserStreamWidget(
                                builder: (context) => FlutterFlowIconButton(
                                  borderRadius: 12.0,
                                  buttonSize: 40.0,
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
                                              widget!.serviceDoc?.reference,
                                            )
                                        ? FlutterFlowTheme.of(context).error
                                        : FlutterFlowTheme.of(
                                            context,
                                          ).secondaryText,
                                    size: 24.0,
                                  ),
                                  showLoadingIndicator: true,
                                  onPressed: () async {
                                    if (!await requireRegisteredUser(
                                      context,
                                      reason:
                                          'Чтобы сохранять услуги в избранное, подтвердите номер телефона.',
                                    )) {
                                      return;
                                    }
                                    final wasFavorite =
                                        (currentUserDocument?.favoriteServices
                                                    ?.toList() ??
                                                [])
                                            .contains(
                                              widget!.serviceDoc?.reference,
                                            );
                                    if (wasFavorite) {
                                      await currentUserReference!.update({
                                        ...mapToFirestore({
                                          'favoriteServices':
                                              FieldValue.arrayRemove([
                                                widget!.serviceDoc?.reference,
                                              ]),
                                        }),
                                      });
                                    } else {
                                      await currentUserReference!.update({
                                        ...mapToFirestore({
                                          'favoriteServices':
                                              FieldValue.arrayUnion([
                                                widget!.serviceDoc?.reference,
                                              ]),
                                        }),
                                      });

                                      final service = widget.serviceDoc;
                                      if (service != null) {
                                        AnalyticsService.instance
                                            .logFavoriteAdded(
                                              serviceId: service.reference.id,
                                              title: service.title,
                                              category: service.categoryKey,
                                              price: service.price,
                                            );
                                      }
                                    }

                                    safeSetState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isOwnService)
                        Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(
                              context,
                            ).primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(
                                context,
                              ).primary.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 21.0,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Так вашу услугу видят другие пользователи',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 3.0),
                                    Text(
                                      'Ниже показан обычный вид страницы услуги. Для изменений используйте кнопку «Редактировать».',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_currentServiceDoc != null)
                        YourMasterServiceBadge(service: _currentServiceDoc!),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            valueOrDefault<String>(
                              widget!.serviceDoc?.title,
                              'Без названия',
                            ),
                            style: FlutterFlowTheme.of(context).headlineMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).headlineMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryText,
                                  fontSize: 26.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).headlineMedium.fontStyle,
                                  lineHeight: 1.25,
                                ),
                          ),
                          Text(
                            valueOrDefault<String>(
                              widget!.serviceDoc?.description,
                              'Без описания',
                            ),
                            style: FlutterFlowTheme.of(context).bodyLarge
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodyLarge.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).bodyLarge.fontStyle,
                                  lineHeight: 1.5,
                                ),
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
                                    ).primaryText,
                                    size: 18.0,
                                  ),
                                  Text(
                                    valueOrDefault<String>(
                                      formatPrice(widget!.serviceDoc?.price),
                                      '0',
                                    ),
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
                                          ).primaryText,
                                          fontSize: 14.0,
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
                              if ((widget.serviceDoc?.time ?? 0) > 0)
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if ((widget.serviceDoc?.time ?? 0) > 0)
                                      Icon(
                                        Icons.access_time,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 18.0,
                                      ),
                                    Text(
                                      widget.serviceDoc!.formattedDuration,
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
                                            ).primaryText,
                                            fontSize: 14.0,
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
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          Text(
                            valueOrDefault<String>(
                              FFAppState().presetCategory
                                  .where(
                                    (e) =>
                                        widget!.serviceDoc?.categoryKey ==
                                        e.key,
                                  )
                                  .toList()
                                  .firstOrNull
                                  ?.titleRU,
                              'Без категории',
                            ),
                            style: FlutterFlowTheme.of(context).bodySmall
                                .override(
                                  font: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodySmall.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).bodySmall.fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                          Text(
                            valueOrDefault<String>(
                              widget!.serviceDoc?.place?.title,
                              'Адрес не указан',
                            ),
                            style: FlutterFlowTheme.of(context).bodySmall
                                .override(
                                  font: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodySmall.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).bodySmall.fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                        ].divide(SizedBox(height: 8.0)),
                      ),
                      ContactsSyncPromptWidget(
                        onSynchronized: () => safeSetState(() {}),
                      ),
                      if (!isOwnService && masterContactName != null)
                        const MasterContactBadgeWidget(),
                      RecommendationMetricsWidget(
                        totalCount: recommendationHashes.length,
                        contactsCount: contactRecommendationsCount,
                        scopeDescription: 'эту услугу',
                      ),
                      if (recommenderContacts.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(
                              context,
                            ).primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Рекомендуют ваши контакты:',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              ...recommenderContacts.map(
                                (contact) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '• ${contact.value}',
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _callRecommender(contact.key),
                                        icon: const Icon(
                                          Icons.phone_outlined,
                                          size: 18.0,
                                        ),
                                        label: const Text('Позвонить'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (selectedRecommendation != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12.0),
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            12.0,
                            16.0,
                            0.0,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(
                              context,
                            ).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).divider,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Рекомендация пользователя',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _refreshRandomRecommendation,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 18.0,
                                    ),
                                    label: const Text('Обновить'),
                                  ),
                                ],
                              ),
                              Builder(
                                builder: (context) {
                                  final selectedHash = _recommendationHash(
                                    selectedRecommendation,
                                  );
                                  final contactName = contactNameForPhoneHash(
                                    selectedHash,
                                  )?.trim();
                                  final displayName =
                                      contactName?.isNotEmpty == true
                                      ? contactName!
                                      : 'Пользователь Сарафана';
                                  final initials = displayName
                                      .split(' ')
                                      .where((part) => part.isNotEmpty)
                                      .map((part) => part[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase();
                                  return ContactRecommendationWidget(
                                    key: ValueKey(
                                      '${selectedRecommendation.phone}_${selectedRecommendation.date}_$_randomRecommendationIndex',
                                    ),
                                    initials: initials,
                                    name: displayName,
                                    comment: selectedRecommendation.comment,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      Divider(color: FlutterFlowTheme.of(context).divider),
                      Builder(
                        builder: (context) {
                          final containerUserRecord = _publicMasterProfile;
                          final masterPhoto =
                              containerUserRecord?.masterData.mainPhoto
                                      .trim()
                                      .isNotEmpty ==
                                  true
                              ? containerUserRecord!.masterData.mainPhoto
                              : widget.serviceDoc?.masterPhoto ?? '';
                          final masterTitle =
                              containerUserRecord?.masterData.title
                                      .trim()
                                      .isNotEmpty ==
                                  true
                              ? containerUserRecord!.masterData.title
                              : (widget.serviceDoc?.masterTitle
                                            .trim()
                                            .isNotEmpty ==
                                        true
                                    ? widget.serviceDoc!.masterTitle
                                    : 'Мастер');
                          Future<void> openMasterPage() async {
                            if (_isOpeningMasterPage) return;
                            safeSetState(() => _isOpeningMasterPage = true);
                            final ownerRef = widget.serviceDoc?.owner;
                            try {
                              final masterDoc =
                                  containerUserRecord ??
                                  (ownerRef == null
                                      ? null
                                      : UserRecord.getDocumentFromData({
                                          'masterData': {
                                            'title': masterTitle,
                                            'mainPhoto': masterPhoto,
                                            'descrip': '',
                                          },
                                        }, ownerRef));
                              if (masterDoc == null) return;
                              context.pushNamed(
                                MasterPageWidget.routeName,
                                queryParameters: {
                                  'masterDoc': serializeParam(
                                    masterDoc,
                                    ParamType.Document,
                                  ),
                                  'sourceCategoryKey': serializeParam(
                                    widget.serviceDoc?.categoryKey,
                                    ParamType.String,
                                  ),
                                }.withoutNulls,
                                extra: <String, dynamic>{
                                  'masterDoc': masterDoc,
                                },
                              );
                              await Future<void>.delayed(
                                const Duration(milliseconds: 300),
                              );
                            } finally {
                              if (mounted) {
                                safeSetState(
                                  () => _isOpeningMasterPage = false,
                                );
                              }
                            }
                          }

                          return Container(
                            decoration: BoxDecoration(),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: _isOpeningMasterPage
                                  ? null
                                  : openMasterPage,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56.0,
                                    height: 56.0,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: CachedNetworkImage(
                                      fadeInDuration: Duration(milliseconds: 0),
                                      fadeOutDuration: Duration(
                                        milliseconds: 0,
                                      ),
                                      imageUrl: masterPhoto,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 168,
                                      memCacheHeight: 168,
                                      maxWidthDiskCache: 336,
                                      maxHeightDiskCache: 336,
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.person_rounded,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                            size: 28.0,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          masterTitle,
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleMedium.fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            'zksodwlb' /* Перейти в профиль */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.jetBrainsMono(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodySmall.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).bodySmall.fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 4.0)),
                                    ),
                                  ),
                                  FlutterFlowIconButton(
                                    buttonSize: 40.0,
                                    icon: _isOpeningMasterPage
                                        ? SizedBox(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                            ),
                                          )
                                        : Icon(
                                            Icons.chevron_right_rounded,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondaryText,
                                            size: 24.0,
                                          ),
                                    onPressed: _isOpeningMasterPage
                                        ? null
                                        : openMasterPage,
                                  ),
                                ].divide(SizedBox(width: 16.0)),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(
                            context,
                          ).secondaryBackground,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).accent3,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'et46gnxj' /* Social Trust */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleMedium.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).titleMedium.fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.group_rounded,
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).accent3,
                                            size: 16.0,
                                          ),
                                          Text(
                                            'Рекомендуют ${recommendationHashes.length} ${_getPeopleNoun(recommendationHashes.length)}',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelMedium.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).accent3,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelMedium.fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 4.0)),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEBF2FF),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0,
                                        4.0,
                                        8.0,
                                        4.0,
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final count = recommendationHashes
                                              .where(
                                                (hash) =>
                                                    contactNameForPhoneHash(
                                                      hash,
                                                    ) !=
                                                    null,
                                              )
                                              .length;
                                          return Text(
                                            '$count ${_getContactsNoun(count)}',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font:
                                                      GoogleFonts.jetBrainsMono(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                  context,
                                                                )
                                                                .labelSmall
                                                                .fontStyle,
                                                      ),
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).accent3,
                                                  fontSize: 10.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 0.5,
                                color: FlutterFlowTheme.of(context).divider,
                              ),
                              Builder(
                                builder: (context) {
                                  final contactRecs =
                                      _currentServiceDoc?.recommendations
                                          .where(
                                            (rec) =>
                                                contactNameForPhoneHash(
                                                  _recommendationHash(rec),
                                                ) !=
                                                null,
                                          )
                                          .toList() ??
                                      [];

                                  if (contactRecs.isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).alternate,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.people_outline_rounded,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondaryText,
                                              size: 32.0,
                                            ),
                                            SizedBox(height: 8.0),
                                            Text(
                                              'Никто из Ваших знакомых еще не рекомендовал эту услугу.',
                                              textAlign: TextAlign.center,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodyMedium.override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryText,
                                                    fontSize: 14.0,
                                                  ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              'Будьте первым, кто оставит рекомендацию после визита!',
                                              textAlign: TextAlign.center,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodySmall.override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).bodySmall.fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).secondaryText,
                                                    fontSize: 12.0,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    children: contactRecs.map((rec) {
                                      final recommendationHash =
                                          _recommendationHash(rec);
                                      final localName =
                                          contactNameForPhoneHash(
                                            recommendationHash,
                                          ) ??
                                          'Пользователь Сарафана';
                                      final initials = localName.isNotEmpty
                                          ? localName
                                                .split(' ')
                                                .map(
                                                  (e) =>
                                                      e.isNotEmpty ? e[0] : '',
                                                )
                                                .take(2)
                                                .join()
                                                .toUpperCase()
                                          : '';
                                      return ContactRecommendationWidget(
                                        key: ValueKey(
                                          '${recommendationHash}_${rec.date?.millisecondsSinceEpoch ?? 0}',
                                        ),
                                        initials: initials,
                                        name: localName,
                                        comment: rec.comment,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_hasCompletedService)
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(
                                  context,
                                ).primaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).divider,
                                  width: 1.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                        size: 20.0,
                                      ),
                                      Text(
                                        FFLocalizations.of(
                                          context,
                                        ).getText('o255lgwn' /* I visited */),
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).labelLarge.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelLarge.fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ].divide(SizedBox(width: 8.0)),
                                  ),
                                ),
                              ),
                            ),
                          if (_hasCompletedService &&
                              !isOwnService &&
                              !hasAlreadyRecommended)
                            InkWell(
                              onTap: () async {
                                if (normalizedUserPhone.isNotEmpty &&
                                    _currentServiceDoc != null) {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: RecommendDialogWidget(
                                        serviceDoc: _currentServiceDoc!,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    final updatedDoc =
                                        await ServiceRecord.getDocumentOnce(
                                          _currentServiceDoc!.reference,
                                        );
                                    safeSetState(() {
                                      _currentServiceDoc = updatedDoc;
                                    });
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).success,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(0.0, 2.0),
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.thumb_up_alt_rounded,
                                        color: Colors.white,
                                        size: 22.0,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Порекомендовать услугу знакомым',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleMedium.fontStyle,
                                                ),
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleMedium.fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 8.0)),
                                  ),
                                ),
                              ),
                            ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ].divide(SizedBox(height: 16.0)),
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
