import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'backend/push_notifications/push_notifications_util.dart';
import 'backend/share_prompt/share_prompt_service.dart';
import 'backend/app_update/app_update_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'flutter_flow/nav/nav.dart';
import 'init/sync_contacts.dart';
import 'index.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  await FlutterFlowTheme.initialize();

  await FFLocalizations.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(ChangeNotifierProvider(create: (context) => appState, child: MyApp()));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({required this.child, super.key});

  static const double maxContentWidth = 720.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth.clamp(0.0, maxContentWidth);

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Makes mobile text fields follow the common app behavior of dismissing the
/// keyboard whenever the user taps outside the active field.
class DismissKeyboardOnTapOutside extends StatelessWidget {
  const DismissKeyboardOnTapOutside({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        EditableTextTapOutsideIntent:
            CallbackAction<EditableTextTapOutsideIntent>(
              onInvoke: (intent) {
                intent.focusNode.unfocus();
                return null;
              },
            ),
      },
      child: child,
    );
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale _locale = const Locale('ru');

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() => _router
      .routerDelegate
      .currentConfiguration
      .matches
      .map((e) => getRoute(e))
      .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});
  final Set<int> _optionalUpdatePrompts = {};
  bool _updateDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = trustyFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        if (user.loggedIn) {
          initPushNotificationsForCurrentUser();
          syncContacts();
          Future.delayed(const Duration(seconds: 2), showSharePromptIfEligible);
          Future.delayed(
            const Duration(seconds: 3),
            initPushNotificationsForCurrentUser,
          );
        } else {
          resetSharePromptState();
        }
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    authUserSub.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdate();
    }
  }

  Future<void> _checkForUpdate() async {
    if (_updateDialogVisible) return;

    final update = await AppUpdateService.instance.check();
    if (!mounted || update == null || _updateDialogVisible) return;
    if (update.requirement == AppUpdateRequirement.optional &&
        _optionalUpdatePrompts.contains(update.latestBuild)) {
      return;
    }

    BuildContext? dialogContext;
    for (var attempt = 0; attempt < 20; attempt++) {
      dialogContext = appNavigatorKey.currentContext;
      if (dialogContext != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted || dialogContext == null || !dialogContext.mounted) return;

    final required = update.requirement == AppUpdateRequirement.required;
    if (!required) {
      _optionalUpdatePrompts.add(update.latestBuild);
    }
    _updateDialogVisible = true;
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: !required,
      builder: (context) => PopScope(
        canPop: !required,
        child: AlertDialog(
          icon: Icon(
            Icons.system_update_rounded,
            color: FlutterFlowTheme.of(context).primary,
            size: 40.0,
          ),
          title: Text(update.title, textAlign: TextAlign.center),
          content: Text(update.message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            if (!required)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Позже'),
              ),
            FilledButton.icon(
              onPressed: () async {
                final opened = await launchUrl(
                  Uri.parse(update.storeUrl),
                  mode: LaunchMode.externalApplication,
                );
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Не удалось открыть магазин приложений'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
    _updateDialogVisible = false;
  }

  void setLocale(String language) {
    const supportedLanguage = 'ru';
    safeSetState(() => _locale = const Locale(supportedLanguage));
    FFLocalizations.storeLocale(supportedLanguage);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
    _themeMode = mode;
    FlutterFlowTheme.saveThemeMode(mode);
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Сарафан',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [Locale('ru')],
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      builder: (context, child) =>
          DismissKeyboardOnTapOutside(child: ResponsiveAppFrame(child: child!)),
      routerConfig: _router,
    );
  }
}
