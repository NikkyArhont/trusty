import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/analytics/analytics_service.dart';
import '/backend/guest/guest_access.dart';

import '/auth/base_auth_user_provider.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get isAnonymous => user?.isAnonymous ?? false;
  bool get registered => loggedIn && !isAnonymous;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: appStateNotifier,
  navigatorKey: appNavigatorKey,
  observers: [AnalyticsService.instance.navigationObserver],
  errorBuilder: (context, state) =>
      appStateNotifier.loggedIn ? MainWidget() : LoginWidget(),
  routes: [
    FFRoute(
      name: '_initialize',
      path: '/',
      builder: (context, _) =>
          FFAppState().firstTime ? AppOnboardingWidget() : InitpageWidget(),
    ),
    FFRoute(
      name: AppOnboardingWidget.routeName,
      path: AppOnboardingWidget.routePath,
      builder: (context, params) => AppOnboardingWidget(
        returnToProfile:
            params.getParam('returnToProfile', ParamType.bool) ?? false,
      ),
    ),
    FFRoute(
      name: ClientProfileSetupWidget.routeName,
      path: ClientProfileSetupWidget.routePath,
      builder: (context, params) => ClientProfileSetupWidget(),
      requireRegistered: true,
    ),
    FFRoute(
      name: LoginWidget.routeName,
      path: LoginWidget.routePath,
      builder: (context, params) => LoginWidget(),
    ),
    FFRoute(
      name: MainWidget.routeName,
      path: MainWidget.routePath,
      builder: (context, params) => MainWidget(),
    ),
    FFRoute(
      name: SearchWidget.routeName,
      path: SearchWidget.routePath,
      builder: (context, params) => SearchWidget(),
    ),
    FFRoute(
      name: CategoriesWidget.routeName,
      path: CategoriesWidget.routePath,
      builder: (context, params) => CategoriesWidget(),
    ),
    FFRoute(
      name: FavoritesWidget.routeName,
      path: FavoritesWidget.routePath,
      builder: (context, params) => FavoritesWidget(),
      requireRegistered: true,
      guestReason: 'Чтобы сохранять услуги, подтвердите номер телефона.',
    ),
    FFRoute(
      name: CabinetWidget.routeName,
      path: CabinetWidget.routePath,
      builder: (context, params) => CabinetWidget(),
      requireRegistered: true,
      guestReason: 'Кабинет и история записей доступны после регистрации.',
    ),
    FFRoute(
      name: ChatsWidget.routeName,
      path: ChatsWidget.routePath,
      builder: (context, params) => ChatsWidget(),
      requireRegistered: true,
      guestReason:
          'Чтобы переписываться с мастерами, подтвердите номер телефона.',
    ),
    FFRoute(
      name: ChatWidget.routeName,
      path: ChatWidget.routePath,
      builder: (context, params) =>
          ChatWidget(chatId: params.getParam('chatId', ParamType.String)),
      requireRegistered: true,
      guestReason:
          'Чтобы переписываться с мастерами, подтвердите номер телефона.',
    ),
    FFRoute(
      name: VisitHistoryWidget.routeName,
      path: VisitHistoryWidget.routePath,
      builder: (context, params) => VisitHistoryWidget(
        chatId: params.getParam('chatId', ParamType.String),
      ),
      requireRegistered: true,
    ),
    FFRoute(
      name: ServiceDetailWidget.routeName,
      path: ServiceDetailWidget.routePath,
      asyncParams: {
        'serviceDoc': getDoc(['service'], ServiceRecord.fromSnapshot),
      },
      builder: (context, params) => ServiceDetailWidget(
        serviceDoc: params.getParam('serviceDoc', ParamType.Document),
      ),
    ),
    FFRoute(
      name: UserProfileWidget.routeName,
      path: UserProfileWidget.routePath,
      builder: (context, params) => UserProfileWidget(),
      requireRegistered: true,
      guestReason:
          'Создайте профиль, чтобы сохранять данные и пользоваться всеми возможностями Сарафана.',
    ),
    FFRoute(
      name: SpecialistDashboardWidget.routeName,
      path: SpecialistDashboardWidget.routePath,
      builder: (context, params) => SpecialistDashboardWidget(),
      requireRegistered: true,
    ),
    FFRoute(
      name: RecordPageClientWidget.routeName,
      path: RecordPageClientWidget.routePath,
      asyncParams: {
        'serviceDoc': getDoc(['service'], ServiceRecord.fromSnapshot),
        'recordDoc': getDoc(['records'], RecordsRecord.fromSnapshot),
      },
      builder: (context, params) => RecordPageClientWidget(
        serviceDoc: params.getParam('serviceDoc', ParamType.Document),
        recordDoc: params.getParam('recordDoc', ParamType.Document),
      ),
      requireRegistered: true,
    ),
    FFRoute(
      name: EditServiceWidget.routeName,
      path: EditServiceWidget.routePath,
      asyncParams: {
        'servDoc': getDoc(['service'], ServiceRecord.fromSnapshot),
      },
      builder: (context, params) => EditServiceWidget(
        servDoc: params.getParam('servDoc', ParamType.Document),
      ),
      requireRegistered: true,
    ),
    FFRoute(
      name: SmsWidget.routeName,
      path: SmsWidget.routePath,
      builder: (context, params) => SmsWidget(
        phone: params.getParam('phone', ParamType.String),
        verificationId: params.getParam('verificationId', ParamType.String),
      ),
    ),
    FFRoute(
      name: RecordsWidget.routeName,
      path: RecordsWidget.routePath,
      builder: (context, params) => RecordsWidget(),
      requireRegistered: true,
    ),
    FFRoute(
      name: MasterChatsWidget.routeName,
      path: MasterChatsWidget.routePath,
      builder: (context, params) => MasterChatsWidget(),
      requireRegistered: true,
    ),
    FFRoute(
      name: MasterOnboardingWidget.routeName,
      path: MasterOnboardingWidget.routePath,
      builder: (context, params) => MasterOnboardingWidget(
        returnToProfile:
            params.getParam('returnToProfile', ParamType.bool) ?? false,
      ),
      requireRegistered: true,
    ),
    FFRoute(
      name: ChooseLocationCityWidget.routeName,
      path: ChooseLocationCityWidget.routePath,
      builder: (context, params) => ChooseLocationCityWidget(
        edit: params.getParam('edit', ParamType.bool),
        addressMode: params.getParam('addressMode', ParamType.bool) ?? false,
        initialPlace: params.getParam<PlaceStruct>(
          'initialPlace',
          ParamType.DataStruct,
          structBuilder: PlaceStruct.fromSerializableMap,
        ),
      ),
    ),
    FFRoute(
      name: EditProfileWidget.routeName,
      path: EditProfileWidget.routePath,
      builder: (context, params) => EditProfileWidget(),
      requireRegistered: true,
    ),
    FFRoute(
      name: AdminStatsWidget.routeName,
      path: AdminStatsWidget.routePath,
      builder: (context, params) => const AdminStatsWidget(),
      requireAuth: true,
      requireRegistered: true,
    ),
    FFRoute(
      name: AdminSupportChatsWidget.routeName,
      path: AdminSupportChatsWidget.routePath,
      builder: (context, params) => const AdminSupportChatsWidget(),
      requireAuth: true,
      requireRegistered: true,
    ),
    FFRoute(
      name: AdminUsersWidget.routeName,
      path: AdminUsersWidget.routePath,
      builder: (context, params) => const AdminUsersWidget(),
      requireAuth: true,
      requireRegistered: true,
    ),
    FFRoute(
      name: AdminUserDetailWidget.routeName,
      path: AdminUserDetailWidget.routePath,
      builder: (context, params) => AdminUserDetailWidget(
        userId: params.getParam('userId', ParamType.String) ?? '',
        initialView:
            params.getParam('initialView', ParamType.String) ?? 'client',
      ),
      requireAuth: true,
      requireRegistered: true,
    ),
    FFRoute(
      name: AdminMemeBuilderWidget.routeName,
      path: AdminMemeBuilderWidget.routePath,
      builder: (context, params) => const AdminMemeBuilderWidget(),
      requireAuth: true,
      requireRegistered: true,
    ),
    FFRoute(
      name: ReferralOnboardingWidget.routeName,
      path: ReferralOnboardingWidget.routePath,
      builder: (context, params) => ReferralOnboardingWidget(
        previewMode: params.getParam('previewMode', ParamType.bool) ?? false,
        profileMode: params.getParam('profileMode', ParamType.bool) ?? false,
      ),
      requireAuth: true,
      requireRegistered: true,
    ),
    FFRoute(
      name: InitpageWidget.routeName,
      path: InitpageWidget.routePath,
      builder: (context, params) => InitpageWidget(),
    ),
    FFRoute(
      name: SearchResultWidget.routeName,
      path: SearchResultWidget.routePath,
      asyncParams: {
        'listResult': getDocList(['service'], ServiceRecord.fromSnapshot),
      },
      builder: (context, params) => SearchResultWidget(
        listResult: params.getParam<ServiceRecord>(
          'listResult',
          ParamType.Document,
          isList: true,
        ),
        showCategories:
            params.getParam('showCategories', ParamType.bool) ?? false,
      ),
    ),
    FFRoute(
      name: EditProfileMasterWidget.routeName,
      path: EditProfileMasterWidget.routePath,
      builder: (context, params) => EditProfileMasterWidget(
        setupMode: params.getParam('setupMode', ParamType.bool) ?? false,
      ),
      requireRegistered: true,
    ),
    FFRoute(
      name: MasterPageWidget.routeName,
      path: MasterPageWidget.routePath,
      asyncParams: {
        'masterDoc': getDoc(['user'], UserRecord.fromSnapshot),
      },
      builder: (context, params) => MasterPageWidget(
        masterDoc: params.getParam('masterDoc', ParamType.Document),
        sourceCategoryKey: params.getParam(
          'sourceCategoryKey',
          ParamType.String,
        ),
      ),
    ),
    FFRoute(
      name: RecordPageMasterWidget.routeName,
      path: RecordPageMasterWidget.routePath,
      asyncParams: {
        'recordDoc': getDoc(['records'], RecordsRecord.fromSnapshot),
      },
      builder: (context, params) => RecordPageMasterWidget(
        recordDoc: params.getParam('recordDoc', ParamType.Document),
      ),
      requireRegistered: true,
    ),
    FFRoute(
      name: MasterNotificationsWidget.routeName,
      path: MasterNotificationsWidget.routePath,
      builder: (context, params) => MasterNotificationsWidget(),
      requireRegistered: true,
    ),
  ].map((r) => r.toRoute(appStateNotifier)).toList(),
);

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
    entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)),
  );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
      ? null
      : goNamed(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
        );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
      ? null
      : pushNamed(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
        );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
      ? null
      : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
    state.allParams.entries.where(isAsyncParam).map((param) async {
      final doc = await asyncParams[param.key]!(
        param.value,
      ).onError((_, __) => null);
      if (doc != null) {
        futureParamValues[param.key] = doc;
        return true;
      }
      return false;
    }),
  ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.requireRegistered = false,
    this.guestReason = 'Чтобы продолжить, подтвердите номер телефона.',
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final bool requireRegistered;
  final String guestReason;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
    name: name,
    path: path,
    redirect: (context, state) {
      if (appStateNotifier.shouldRedirect) {
        final redirectLocation = appStateNotifier.getRedirectLocation();
        appStateNotifier.clearRedirectLocation();
        return redirectLocation;
      }

      if ((requireAuth || requireRegistered) && !appStateNotifier.loggedIn) {
        appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
        return '/login';
      }
      return null;
    },
    pageBuilder: (context, state) {
      fixStatusBarOniOS16AndBelow(context);
      final ffParams = FFParameters(state, asyncParams);
      final page = requireRegistered && appStateNotifier.isAnonymous
          ? GuestRegistrationPage(reason: guestReason)
          : ffParams.hasFutures
          ? FutureBuilder(
              future: ffParams.completeFutures(),
              builder: (context, _) => builder(context, ffParams),
            )
          : builder(context, ffParams);
      final isLoading = appStateNotifier.loading;
      final child = isLoading
          ? ColoredBox(color: FlutterFlowTheme.of(context).primaryBackground)
          : _RootTabSwipeRegion(routeName: name, child: page);

      if (!isLoading && page is! InitpageWidget) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => FlutterNativeSplash.remove(),
        );
      }

      final transitionInfo = state.transitionInfo;
      return transitionInfo.hasTransition
          ? CustomTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: child,
              transitionDuration: transitionInfo.duration,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      PageTransition(
                        type: transitionInfo.transitionType,
                        duration: transitionInfo.duration,
                        reverseDuration: transitionInfo.duration,
                        alignment: transitionInfo.alignment,
                        child: child,
                      ).buildTransitions(
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ),
            )
          : MaterialPage(key: state.pageKey, name: state.name, child: child);
    },
    routes: routes,
  );
}

class _RootTabSwipeRegion extends StatefulWidget {
  const _RootTabSwipeRegion({required this.routeName, required this.child});

  final String routeName;
  final Widget child;

  @override
  State<_RootTabSwipeRegion> createState() => _RootTabSwipeRegionState();
}

class _RootTabSwipeRegionState extends State<_RootTabSwipeRegion> {
  static const double _distanceThreshold = 56.0;
  static const double _velocityThreshold = 450.0;

  double _dragDistance = 0.0;
  bool _isNavigating = false;

  List<String> get _routeOrder => FFAppState().specialistMode
      ? [
          SpecialistDashboardWidget.routeName,
          RecordsWidget.routeName,
          MasterChatsWidget.routeName,
          UserProfileWidget.routeName,
        ]
      : [
          MainWidget.routeName,
          CabinetWidget.routeName,
          ChatsWidget.routeName,
          UserProfileWidget.routeName,
        ];

  void _handleDragStart(DragStartDetails details) {
    _dragDistance = 0.0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.primaryDelta ?? 0.0;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isNavigating) return;

    final velocity = details.primaryVelocity ?? 0.0;
    final hasEnoughDistance = _dragDistance.abs() >= _distanceThreshold;
    final hasEnoughVelocity = velocity.abs() >= _velocityThreshold;
    if (!hasEnoughDistance && !hasEnoughVelocity) return;

    final routes = _routeOrder;
    final currentIndex = routes.indexOf(widget.routeName);
    if (currentIndex == -1) return;

    final direction = hasEnoughDistance ? _dragDistance : velocity;
    final targetIndex = direction < 0 ? currentIndex + 1 : currentIndex - 1;
    if (targetIndex < 0 || targetIndex >= routes.length) return;

    _isNavigating = true;
    context.goNamed(
      routes[targetIndex],
      extra: <String, dynamic>{
        kTransitionInfoKey: TransitionInfo(
          hasTransition: true,
          transitionType: direction < 0
              ? PageTransitionType.rightToLeft
              : PageTransitionType.leftToRight,
          duration: const Duration(milliseconds: 220),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_routeOrder.contains(widget.routeName)) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: widget.child,
    );
  }
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) =>
      Provider.value(value: RootPageContext(true, errorRoute), child: child);
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
