import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'menu_model.dart';
export 'menu_model.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key, required this.currentPage});

  final Menu? currentPage;

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late MenuModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  void _handleTabAreaTap(TapUpDetails details, double menuWidth) {
    if (menuWidth <= 0.0) return;

    final tabIndex = (details.localPosition.dx / (menuWidth / 4.0))
        .floor()
        .clamp(0, 3);
    final tabs = FFAppState().specialistMode
        ? const [Menu.dashboard, Menu.records, Menu.masterChats, Menu.profile]
        : const [Menu.main, Menu.cabinet, Menu.chats, Menu.profile];
    final target = tabs[tabIndex];
    if (target == widget.currentPage) return;

    final routeName = switch (target) {
      Menu.dashboard => SpecialistDashboardWidget.routeName,
      Menu.records => RecordsWidget.routeName,
      Menu.masterChats => MasterChatsWidget.routeName,
      Menu.main => MainWidget.routeName,
      Menu.cabinet => CabinetWidget.routeName,
      Menu.chats => ChatsWidget.routeName,
      Menu.profile => UserProfileWidget.routeName,
      _ => null,
    };
    if (routeName == null) return;

    context.goNamed(
      routeName,
      extra: <String, dynamic>{
        '__transition_info__': const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _handleTabAreaTap(details, constraints.maxWidth),
        child: Container(
          height: 96.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 16.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, -8.0),
                spreadRadius: 0.0,
              ),
            ],
            border: Border.all(color: Colors.transparent, width: 1.0),
          ),
          child: Builder(
            builder: (context) {
              if (FFAppState().specialistMode) {
                return Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 16.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    disabledColor: FlutterFlowTheme.of(
                                      context,
                                    ).primary,
                                    disabledIconColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    icon: Icon(
                                      Icons.bar_chart,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 24.0,
                                    ),
                                    onPressed:
                                        (widget!.currentPage == Menu.dashboard)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              SpecialistDashboardWidget
                                                  .routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap:
                                        (widget!.currentPage == Menu.dashboard)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              SpecialistDashboardWidget
                                                  .routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('7auwom16' /* Панель */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage ==
                                                    Menu.dashboard
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 16.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    disabledColor: FlutterFlowTheme.of(
                                      context,
                                    ).primary,
                                    disabledIconColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    icon: Icon(
                                      Icons.calendar_today,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 24.0,
                                    ),
                                    onPressed:
                                        (widget!.currentPage == Menu.records)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              RecordsWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: (widget!.currentPage == Menu.records)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              RecordsWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('w34zbn3q' /* Записи */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage ==
                                                    Menu.records
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: currentUserReference == null
                                        ? const Stream.empty()
                                        : FirebaseFirestore.instance
                                              .collection('notifications')
                                              .where(
                                                'user',
                                                isEqualTo: currentUserReference,
                                              )
                                              .where('read', isEqualTo: false)
                                              .where(
                                                'type',
                                                isEqualTo: 'chat_message',
                                              )
                                              .snapshots(),
                                    builder: (context, snapshot) {
                                      final hasUnread =
                                          snapshot.hasData &&
                                          snapshot.data!.docs.any((doc) {
                                            final data =
                                                doc.data()
                                                    as Map<String, dynamic>?;
                                            if (data == null) return false;
                                            final role =
                                                data['recipientRole']
                                                    as String?;
                                            if (role != null) {
                                              return role == 'master';
                                            }
                                            final chatRef =
                                                data['chat']
                                                    as DocumentReference?;
                                            final chatId = chatRef?.id ?? '';
                                            return chatId.endsWith(
                                              '_master_$currentUserUid',
                                            );
                                          });

                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          FlutterFlowIconButton(
                                            borderRadius: 16.0,
                                            buttonSize: 40.0,
                                            fillColor: FlutterFlowTheme.of(
                                              context,
                                            ).primaryBackground,
                                            disabledColor: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                            disabledIconColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                            icon: Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondaryText,
                                              size: 24.0,
                                            ),
                                            onPressed:
                                                (widget!.currentPage ==
                                                    Menu.masterChats)
                                                ? null
                                                : () async {
                                                    context.goNamed(
                                                      MasterChatsWidget
                                                          .routeName,
                                                      extra: <String, dynamic>{
                                                        '__transition_info__':
                                                            TransitionInfo(
                                                              hasTransition:
                                                                  true,
                                                              transitionType:
                                                                  PageTransitionType
                                                                      .fade,
                                                            ),
                                                      },
                                                    );
                                                  },
                                          ),
                                          if (hasUnread)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                width: 10.0,
                                                height: 10.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryBackground,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap:
                                        (widget!.currentPage ==
                                            Menu.masterChats)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              MasterChatsWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('bxvure6x' /* Чаты */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage ==
                                                    Menu.masterChats
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 16.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    disabledColor: FlutterFlowTheme.of(
                                      context,
                                    ).primary,
                                    disabledIconColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    icon: Icon(
                                      Icons.person,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 24.0,
                                    ),
                                    onPressed:
                                        (widget!.currentPage == Menu.profile)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              UserProfileWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: (widget!.currentPage == Menu.profile)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              UserProfileWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('j9tiuuk9' /* Профиль */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage ==
                                                    Menu.profile
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 16.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    disabledColor: FlutterFlowTheme.of(
                                      context,
                                    ).primary,
                                    disabledIconColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    icon: Icon(
                                      Icons.home,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 24.0,
                                    ),
                                    onPressed:
                                        (widget!.currentPage == Menu.main)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              MainWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: (widget!.currentPage == Menu.main)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              MainWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('zrgx6a00' /* Главная */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage == Menu.main
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 16.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    disabledColor: FlutterFlowTheme.of(
                                      context,
                                    ).primary,
                                    disabledIconColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    icon: Icon(
                                      Icons.calendar_month,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 24.0,
                                    ),
                                    onPressed:
                                        (widget!.currentPage == Menu.cabinet)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              CabinetWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: (widget!.currentPage == Menu.cabinet)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              CabinetWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('ilmtj8go' /* Кабинет */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage ==
                                                    Menu.cabinet
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: currentUserReference == null
                                        ? const Stream.empty()
                                        : FirebaseFirestore.instance
                                              .collection('notifications')
                                              .where(
                                                'user',
                                                isEqualTo: currentUserReference,
                                              )
                                              .where('read', isEqualTo: false)
                                              .where(
                                                'type',
                                                isEqualTo: 'chat_message',
                                              )
                                              .snapshots(),
                                    builder: (context, snapshot) {
                                      final hasUnread =
                                          snapshot.hasData &&
                                          snapshot.data!.docs.any((doc) {
                                            final data =
                                                doc.data()
                                                    as Map<String, dynamic>?;
                                            if (data == null) return false;
                                            final role =
                                                data['recipientRole']
                                                    as String?;
                                            if (role != null) {
                                              return role == 'client';
                                            }
                                            final chatRef =
                                                data['chat']
                                                    as DocumentReference?;
                                            final chatId = chatRef?.id ?? '';
                                            return chatId.startsWith(
                                              'client_${currentUserUid}_',
                                            );
                                          });

                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          FlutterFlowIconButton(
                                            borderRadius: 16.0,
                                            buttonSize: 40.0,
                                            fillColor: FlutterFlowTheme.of(
                                              context,
                                            ).primaryBackground,
                                            disabledColor: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                            disabledIconColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                            icon: Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: FlutterFlowTheme.of(
                                                context,
                                              ).secondaryText,
                                              size: 24.0,
                                            ),
                                            onPressed:
                                                (widget!.currentPage ==
                                                    Menu.chats)
                                                ? null
                                                : () async {
                                                    context.goNamed(
                                                      ChatsWidget.routeName,
                                                      extra: <String, dynamic>{
                                                        '__transition_info__':
                                                            TransitionInfo(
                                                              hasTransition:
                                                                  true,
                                                              transitionType:
                                                                  PageTransitionType
                                                                      .fade,
                                                            ),
                                                      },
                                                    );
                                                  },
                                          ),
                                          if (hasUnread)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                width: 10.0,
                                                height: 10.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primaryBackground,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: (widget!.currentPage == Menu.chats)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              ChatsWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('bxvure6x' /* Чаты */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage ==
                                                    Menu.chats
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                8.0,
                                0.0,
                                8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 16.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    disabledColor: FlutterFlowTheme.of(
                                      context,
                                    ).primary,
                                    disabledIconColor: FlutterFlowTheme.of(
                                      context,
                                    ).primaryBackground,
                                    icon: Icon(
                                      Icons.person,
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).secondaryText,
                                      size: 24.0,
                                    ),
                                    onPressed:
                                        (widget!.currentPage == Menu.profile)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              UserProfileWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: (widget!.currentPage == Menu.profile)
                                        ? null
                                        : () async {
                                            context.goNamed(
                                              UserProfileWidget.routeName,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                              },
                                            );
                                          },
                                    child: Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('ihylkvry' /* Профиль */),
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(
                                                context,
                                              ).labelSmall.fontStyle,
                                            ),
                                            color:
                                                widget!.currentPage ==
                                                    Menu.profile
                                                ? FlutterFlowTheme.of(
                                                    context,
                                                  ).primary
                                                : FlutterFlowTheme.of(
                                                    context,
                                                  ).secondary,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelSmall.fontStyle,
                                            lineHeight: 1.2,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
