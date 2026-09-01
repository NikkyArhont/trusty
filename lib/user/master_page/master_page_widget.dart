import '/backend/backend.dart';
import '/backend/guest/guest_access.dart';
import '/backend/public_master_profile.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/contacts_sync_prompt/contacts_sync_prompt_widget.dart';
import '/global_comp/master_contact_badge/master_contact_badge_widget.dart';
import '/global_comp/recommendation_metrics/recommendation_metrics_widget.dart';
import '/init/sync_contacts.dart';
import '/user/chat/chat_widget.dart';
import '/user/service_card_client/service_card_client_widget.dart';
import '/master/client_invite_guide_dialog.dart';
import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'master_page_model.dart';
export 'master_page_model.dart';

class MasterPageWidget extends StatefulWidget {
  const MasterPageWidget({
    super.key,
    required this.masterDoc,
    this.sourceCategoryKey,
  });

  final UserRecord? masterDoc;
  final String? sourceCategoryKey;

  static String routeName = 'masterPage';
  static String routePath = '/masterPage';

  @override
  State<MasterPageWidget> createState() => _MasterPageWidgetState();
}

class _MasterPageWidgetState extends State<MasterPageWidget> {
  late MasterPageModel _model;
  UserRecord? _loadedPublicMasterDoc;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  UserRecord? get _masterDoc => _loadedPublicMasterDoc ?? widget.masterDoc;

  String get _specializationTitle {
    final profileCategoryKey = _masterDoc?.masterData.initCat.trim() ?? '';
    final sourceCategoryKey = widget.sourceCategoryKey?.trim() ?? '';
    final categoryKeys = [
      profileCategoryKey,
      sourceCategoryKey,
    ].where((key) => key.isNotEmpty && key.toLowerCase() != 'null');

    for (final categoryKey in categoryKeys) {
      final category = FFAppState().presetCategory
          .where((candidate) => candidate.key == categoryKey)
          .firstOrNull;
      final title = category?.titleRU.trim() ?? '';
      if (title.isNotEmpty) {
        return title;
      }
    }
    return 'Не указана';
  }

  String _contactsNoun(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) {
      return 'контакт';
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'контакта';
    }
    return 'контактов';
  }

  Set<String> _recommendationHashes(List<ServiceRecord> services) =>
      services.expand(recommendationPhoneHashesForService).toSet();

  List<String> _contactRecommenderNames(Set<String> hashes) {
    final names = hashes
        .map((hash) => contactNameForPhoneHash(hash)?.trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    names.sort(
      (first, second) => first.toLowerCase().compareTo(second.toLowerCase()),
    );
    return names;
  }

  String _recommendationSummary(List<String> names) {
    if (names.length == 1) {
      return '${names.first} рекомендует';
    }
    final remainingCount = names.length - 1;
    return '${names.first} и ещё $remainingCount '
        '${_contactsNoun(remainingCount)} рекомендуют';
  }

  Future<void> _showRecommendersSheet(List<String> names) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = FlutterFlowTheme.of(sheetContext);
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.65,
            ),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: theme.alternate,
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Рекомендуют ваши контакты',
                    style: theme.titleMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: names.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1.0, color: theme.divider),
                      itemBuilder: (context, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.primary.withValues(
                            alpha: 0.14,
                          ),
                          foregroundColor: theme.primary,
                          child: Text(
                            names[index].characters.first.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(
                          names[index],
                          style: theme.bodyLarge.override(
                            font: GoogleFonts.jetBrainsMono(),
                            color: theme.primaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openOrCreateChat() async {
    if (!await requireRegisteredUser(
      context,
      reason: 'Чтобы написать мастеру, подтвердите номер телефона.',
    )) {
      return;
    }
    final currentUserRef = currentUserReference;
    final masterRef = _masterDoc?.reference;
    if (currentUserRef == null || masterRef == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось открыть чат')));
      return;
    }
    if (currentUserRef == masterRef) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Это ваш профиль мастера')));
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
        'masterName': _masterDoc?.masterData.title ?? '',
        'masterPhoto': _masterDoc?.masterData.mainPhoto ?? '',
        'created_time': now,
        'updated_time': now,
        'context': 'client_master',
      }, SetOptions(merge: true));

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
    _model = createModel(context, () => MasterPageModel());

    final masterRef = widget.masterDoc?.reference;
    if (masterRef != null) {
      unawaited(
        loadPublicMasterProfile(masterRef).then((profile) {
          if (mounted && profile != null) {
            safeSetState(() => _loadedPublicMasterDoc = profile);
          }
        }),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await syncContacts();
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final masterContactName = contactNameForPhoneHash(
      _masterDoc?.contactPhoneHash ?? '',
    );
    final isOwnProfile = _masterDoc?.reference == currentUserReference;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                primary: false,
                padding: EdgeInsets.only(bottom: 24.0),
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
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () async {
                                context.safePop();
                              },
                              child: SizedBox(
                                width: 48.0,
                                height: 48.0,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryText,
                                  size: 24.0,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64.0,
                                  height: 64.0,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: CachedNetworkImage(
                                    fadeInDuration: Duration(milliseconds: 0),
                                    fadeOutDuration: Duration(milliseconds: 0),
                                    imageUrl: _masterDoc!.masterData.mainPhoto,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 192,
                                    memCacheHeight: 192,
                                    maxWidthDiskCache: 384,
                                    maxHeightDiskCache: 384,
                                    errorWidget: (context, error, stackTrace) =>
                                        Image.asset(
                                          'assets/images/error_image.png',
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        valueOrDefault<String>(
                                          _masterDoc?.masterData.title,
                                          'Без названия',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).headlineMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).headlineMedium.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FlutterFlowTheme.of(
                                                context,
                                              ).headlineMedium.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).headlineMedium.fontStyle,
                                            ),
                                      ),
                                      Text(
                                        'Основная специализация: $_specializationTitle',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
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
                              ].divide(SizedBox(width: 16.0)),
                            ),
                            if (_masterDoc?.masterData.descrip
                                    .trim()
                                    .isNotEmpty ??
                                false)
                              Text(
                                valueOrDefault<String>(
                                  _masterDoc?.masterData.descrip,
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
                            ContactsSyncPromptWidget(
                              onSynchronized: () => safeSetState(() {}),
                            ),
                            if (!isOwnProfile && masterContactName != null)
                              MasterContactBadgeWidget(
                                contactName: masterContactName,
                              ),
                            StreamBuilder<List<ServiceRecord>>(
                              stream: queryServiceRecord(
                                queryBuilder: (serviceRecord) =>
                                    serviceRecord.where(
                                      'owner',
                                      isEqualTo: _masterDoc?.reference,
                                    ),
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final visibleServices = snapshot.data!
                                    .where(
                                      (service) =>
                                          service.status == ServiceStatus.show,
                                    )
                                    .toList();
                                final recommendationHashes =
                                    _recommendationHashes(visibleServices);
                                final names = _contactRecommenderNames(
                                  recommendationHashes,
                                );
                                final contactsCount = recommendationHashes
                                    .where(
                                      (hash) =>
                                          contactNameForPhoneHash(hash) != null,
                                    )
                                    .length;

                                final theme = FlutterFlowTheme.of(context);
                                final borderRadius = BorderRadius.circular(
                                  16.0,
                                );
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    RecommendationMetricsWidget(
                                      totalCount: recommendationHashes.length,
                                      contactsCount: contactsCount,
                                      scopeDescription: 'услуги этого мастера',
                                    ),
                                    if (names.isNotEmpty) ...[
                                      const SizedBox(height: 16.0),
                                      Material(
                                        color: Color.alphaBlend(
                                          theme.primary.withValues(alpha: 0.10),
                                          theme.secondaryBackground,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadius,
                                          side: BorderSide(
                                            color: theme.primary.withValues(
                                              alpha: 0.28,
                                            ),
                                            width: 1.0,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          borderRadius: borderRadius,
                                          onTap: () =>
                                              _showRecommendersSheet(names),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.thumb_up_rounded,
                                                  color: theme.primary,
                                                  size: 20.0,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children:
                                                        [
                                                          Text(
                                                            _recommendationSummary(
                                                              names,
                                                            ),
                                                            style: theme
                                                                .labelLarge
                                                                .override(
                                                                  font:
                                                                      GoogleFonts.jetBrainsMono(),
                                                                  color: theme
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          Text(
                                                            FFLocalizations.of(
                                                              context,
                                                            ).getText(
                                                              'iz458npx' /* High trust score based on your... */,
                                                            ),
                                                            style: theme
                                                                .bodySmall
                                                                .override(
                                                                  font:
                                                                      GoogleFonts.jetBrainsMono(),
                                                                  color: theme
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ].divide(
                                                          const SizedBox(
                                                            height: 4.0,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: theme.secondaryText,
                                                  size: 22.0,
                                                ),
                                              ].divide(const SizedBox(width: 16.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                    ),
                    if (isOwnProfile)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: OutlinedButton.icon(
                          onPressed: () => showClientInviteGuideDialog(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            side: BorderSide(
                              color: FlutterFlowTheme.of(
                                context,
                              ).primary.withValues(alpha: 0.45),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.school_rounded),
                          label: const Text(
                            'Как пригласить клиентов в Сарафан для первых рекомендаций',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    Container(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          24.0,
                          0.0,
                          24.0,
                          24.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                0.0,
                                0.0,
                                16.0,
                              ),
                              child: Text(
                                FFLocalizations.of(
                                  context,
                                ).getText('nol6k5x3' /* Услуги */),
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
                              ),
                            ),
                            StreamBuilder<List<ServiceRecord>>(
                              stream: queryServiceRecord(
                                queryBuilder: (serviceRecord) =>
                                    serviceRecord.where(
                                      'owner',
                                      isEqualTo: _masterDoc?.reference,
                                    ),
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
                                List<ServiceRecord> listViewServiceRecordList =
                                    snapshot.data!
                                        .where(
                                          (service) =>
                                              service.status ==
                                              ServiceStatus.show,
                                        )
                                        .toList();

                                return MasonryGridView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                      ),
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: listViewServiceRecordList.length,
                                  itemBuilder: (context, listViewIndex) {
                                    final listViewServiceRecord =
                                        listViewServiceRecordList[listViewIndex];
                                    return ServiceCardClientWidget(
                                      key: Key(
                                        'Keyo19_${listViewIndex}_of_${listViewServiceRecordList.length}',
                                      ),
                                      servicedoc: listViewServiceRecord,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                border: Border.all(
                  color: FlutterFlowTheme.of(context).divider,
                  width: 1.0,
                ),
              ),
              child: Padding(
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
                          style: FlutterFlowTheme.of(context).labelSmall
                              .override(
                                font: GoogleFonts.jetBrainsMono(
                                  fontWeight: FlutterFlowTheme.of(
                                    context,
                                  ).labelSmall.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).labelSmall.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(
                                  context,
                                ).secondaryText,
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
                      flex: 1,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: _openOrCreateChat,
                        child: Container(
                          height: 52.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(26.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Padding(
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
                                  Icons.chat_bubble_outline_rounded,
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).primaryBackground,
                                  size: 18.0,
                                ),
                                Flexible(
                                  child: Text(
                                    'Связаться',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
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
                    ),
                  ].divide(SizedBox(width: 16.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
