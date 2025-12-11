import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_crash_stats_parameters.dart';
import 'app_crash_stats_service.dart';
import 'app_crash_stats_splash.dart';

late SharedPreferences appCrashStatsSharedPreferences;

dynamic appCrashStatsConversionData;
String? appCrashStatsTrackingPermissionStatus;
String? appCrashStatsAdvertisingId;
String? appCrashStatsLink;

String? appCrashStatsAppsflyerId;
String? appCrashStatsExternalId;

int appCrashStatsWebViewType = 1;
bool appCrashStatsConversionHandled = false;

class AppCrashStats extends StatefulWidget {
  const AppCrashStats({super.key});

  @override
  State<AppCrashStats> createState() => _AppCrashStatsState();
}

class _AppCrashStatsState extends State<AppCrashStats> {
  @override
  void initState() {
    super.initState();
    appCrashStatsInitAll();
  }

  Future<void> appCrashStatsInitAll() async {
    await Future.delayed(const Duration(milliseconds: 10));
    appCrashStatsSharedPreferences = await SharedPreferences.getInstance();
    final bool sentAnalytics =
        appCrashStatsSharedPreferences.getBool(appCrashStatsSentFlagKey) ??
            false;
    appCrashStatsLink =
        appCrashStatsSharedPreferences.getString(appCrashStatsLinkKey);
    appCrashStatsWebViewType = appCrashStatsSharedPreferences
            .getInt(appCrashStatsWebViewTypeKey) ??
        1;

    if (appCrashStatsLink != null && appCrashStatsLink!.isNotEmpty) {
      appCrashStatsWebViewType =
          appCrashStatsDetectWebViewType(appCrashStatsLink!);
      appCrashStatsSharedPreferences.setInt(
        appCrashStatsWebViewTypeKey,
        appCrashStatsWebViewType,
      );
    }

    if (appCrashStatsLink != null &&
        appCrashStatsLink!.isNotEmpty &&
        !sentAnalytics) {
      AppCrashStatsService().navigateToWebView(context);
    } else if (sentAnalytics) {
      await AppCrashStatsService().navigateToStandardApp(context);
    } else {
      await appCrashStatsInitializeMainPart();
    }
  }

  Future<void> appCrashStatsInitializeMainPart() async {
    final attRequest = AppCrashStatsService().requestTrackingPermission();
    final oneSignalInit = AppCrashStatsService().initializeOneSignal();

    await attRequest;
    await appCrashStatsTakeParams();
    await oneSignalInit;
  }

  int appCrashStatsDetectWebViewType(String link) {
    try {
      final uri = Uri.parse(link);
      final params = uri.queryParameters;
      return int.tryParse(params['wtype'] ?? '') ?? 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> appCrashStatsCreateLink() async {
    final Map<dynamic, dynamic> parameters = appCrashStatsConversionData;

    parameters.addAll({
      "tracking_status": appCrashStatsTrackingPermissionStatus,
      "${appCrashStatsKeyword}_id": appCrashStatsAdvertisingId,
      "external_id": appCrashStatsExternalId,
      "appsflyer_id": appCrashStatsAppsflyerId,
    });

    final String? link =
        await AppCrashStatsService().sendAppCrashStatsRequest(parameters);

    appCrashStatsLink = link;

    if (appCrashStatsLink == null || appCrashStatsLink!.isEmpty) {
      await AppCrashStatsService().navigateToStandardApp(context);
    } else {
      appCrashStatsWebViewType =
          appCrashStatsDetectWebViewType(appCrashStatsLink!);
      appCrashStatsSharedPreferences.setInt(
        appCrashStatsWebViewTypeKey,
        appCrashStatsWebViewType,
      );
      appCrashStatsSharedPreferences.setString(
        appCrashStatsLinkKey,
        appCrashStatsLink!,
      );
      appCrashStatsSharedPreferences.setBool(appCrashStatsSuccessKey, true);
      AppCrashStatsService().navigateToWebView(context);
    }
  }

  Future<void> appCrashStatsTakeParams() async {
    final appsFlyerOptions = AppCrashStatsService().createAppsFlyerOptions();
    final AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    appCrashStatsAppsflyerId = await appsFlyerSdk.getAppsFlyerUID();

    appsFlyerSdk.onInstallConversionData((res) async {
      if (appCrashStatsConversionHandled) {
        return;
      }
      appCrashStatsConversionHandled = true;
      appCrashStatsConversionData = res;
      await appCrashStatsCreateLink();
    });

    appsFlyerSdk.startSDK(
      onError: (errorCode, errorMessage) {
        AppCrashStatsService().navigateToStandardApp(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppCrashStatsSplash();
  }
}
