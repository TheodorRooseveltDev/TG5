import 'dart:async';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import 'package:flutter/material.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_parameters.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_service.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

dynamic appCrashStatsConversionData;
String? appCrashStatsTrackingStatus;
String? appCrashStatsAdvertisingId;
String? appCrashStatsLink;

String? appCrashStatsAppsflyerId;
String? appCrashStatsExternalId;

late SharedPreferences appCrashStatsCheckSharedPreferences;

class AppCrashStatsCheck extends StatefulWidget {
  const AppCrashStatsCheck({super.key});

  @override
  State<AppCrashStatsCheck> createState() => _AppCrashStatsCheckState();
}

class _AppCrashStatsCheckState extends State<AppCrashStatsCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appCrashStatsCheckSharedPreferences =
          await SharedPreferences.getInstance();
      await Future.delayed(const Duration(milliseconds: 500));

      initAll();
    });
  }

  initAll() async {
    await Future.delayed(Duration(milliseconds: 10));
    bool appCrashStatsSent =
        appCrashStatsCheckSharedPreferences.getBool("appCrashStatsSent") ??
        false;
    appCrashStatsLink = appCrashStatsCheckSharedPreferences.getString("link");

    if (appCrashStatsLink != null &&
        appCrashStatsLink != "" &&
        !appCrashStatsSent) {
      AppCrashStatsService().navigateToAppCrashStatsWebView(context);
    } else {
      if (appCrashStatsSent) {
        AppCrashStatsService().navigateToAppCrashStatsSplash(context);
      } else {
        initializeMainPart();
      }
    }
  }

  void initializeMainPart() async {
    await AppCrashStatsService().requestUserSafeTrackingPermission();
    await AppCrashStatsService().initializeOneSignal();
    await takeAppCrashStatsParams();
  }

  Future<void> createAppCrashStatsLink() async {
    Map<dynamic, dynamic> parameters = appCrashStatsConversionData;

    parameters.addAll({
      "track_status": appCrashStatsTrackingStatus,
      "${appCrashStatsParameter}_id": appCrashStatsAdvertisingId,
      "appsflyer_id": appCrashStatsAppsflyerId,
      "external_id": appCrashStatsExternalId,
    });

    String? link = await AppCrashStatsService().sendAppCrashStatsRequest(
      parameters,
    );

    appCrashStatsLink = link;

    if (appCrashStatsLink == "" || appCrashStatsLink == null) {
      AppCrashStatsService().navigateToAppCrashStatsSplash(context);
    } else {
      appCrashStatsCheckSharedPreferences.setString(
        "link",
        appCrashStatsLink.toString(),
      );
      appCrashStatsCheckSharedPreferences.setBool("success", true);
      AppCrashStatsService().navigateToAppCrashStatsWebView(context);
    }
  }

  Future<void> takeAppCrashStatsParams() async {
    final appsFlyerOptions = AppCrashStatsService()
        .createAppCrashStatsAppsFlyerOptions();
    AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);
    appCrashStatsAppsflyerId = await appsFlyerSdk.getAppsFlyerUID();
    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    appsFlyerSdk.onInstallConversionData((res) async {
      appCrashStatsConversionData = res;
      await createAppCrashStatsLink();
    });

    appsFlyerSdk.startSDK(
      onError: (errorCode, errorMessage) {
        AppCrashStatsService().navigateToAppCrashStatsSplash(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppCrashStatsSplash();
  }
}
