import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum AppUpdateRequirement { none, optional, required }

AppUpdateRequirement resolveAppUpdateRequirement({
  required int currentBuild,
  required int latestBuild,
  required int minimumBuild,
}) => currentBuild < minimumBuild
    ? AppUpdateRequirement.required
    : currentBuild < latestBuild
    ? AppUpdateRequirement.optional
    : AppUpdateRequirement.none;

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.requirement,
    required this.currentBuild,
    required this.latestBuild,
    required this.minimumBuild,
    required this.storeUrl,
    required this.title,
    required this.message,
  });

  final AppUpdateRequirement requirement;
  final int currentBuild;
  final int latestBuild;
  final int minimumBuild;
  final String storeUrl;
  final String title;
  final String message;
}

class AppUpdateService {
  AppUpdateService._();

  static final instance = AppUpdateService._();

  static const _androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.mycompany.trusty';
  static const _iosStoreUrl = 'https://apps.apple.com/app/id6785482036';

  bool _initialized = false;

  Future<AppUpdateInfo?> check() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return null;
    }

    final remoteConfig = FirebaseRemoteConfig.instance;
    if (!_initialized) {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 8),
          minimumFetchInterval: const Duration(minutes: 15),
        ),
      );
      await remoteConfig.setDefaults(const {
        'update_check_enabled': false,
        'android_latest_build': 19,
        'android_minimum_build': 19,
        'android_store_url': _androidStoreUrl,
        'ios_latest_build': 19,
        'ios_minimum_build': 19,
        'ios_store_url': _iosStoreUrl,
        'optional_update_title': 'Доступна новая версия',
        'optional_update_message':
            'Обновите приложение, чтобы получить новые возможности и улучшения.',
        'required_update_title': 'Необходимо обновление',
        'required_update_message':
            'Эта версия больше не поддерживается. Обновите приложение, чтобы продолжить.',
      });
      _initialized = true;
    }

    try {
      await remoteConfig.fetchAndActivate();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Remote Config update check failed: $error');
      }
    }

    if (!remoteConfig.getBool('update_check_enabled')) {
      return null;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final platformKey = isAndroid ? 'android' : 'ios';
    final latestBuild = remoteConfig.getInt('${platformKey}_latest_build');
    final minimumBuild = remoteConfig.getInt('${platformKey}_minimum_build');
    final storeUrl = remoteConfig.getString('${platformKey}_store_url').trim();

    final requirement = resolveAppUpdateRequirement(
      currentBuild: currentBuild,
      latestBuild: latestBuild,
      minimumBuild: minimumBuild,
    );
    if (requirement == AppUpdateRequirement.none || storeUrl.isEmpty) {
      return null;
    }

    final required = requirement == AppUpdateRequirement.required;
    return AppUpdateInfo(
      requirement: requirement,
      currentBuild: currentBuild,
      latestBuild: latestBuild,
      minimumBuild: minimumBuild,
      storeUrl: storeUrl,
      title: remoteConfig.getString(
        required ? 'required_update_title' : 'optional_update_title',
      ),
      message: remoteConfig.getString(
        required ? 'required_update_message' : 'optional_update_message',
      ),
    );
  }
}
