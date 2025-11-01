import 'dart:convert';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_check.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_parameters.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_web_view.dart';
import 'package:uuid/uuid.dart';

class AppCrashStatsService {
  Future<void> initializeOneSignal() async {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    await OneSignal.Location.setShared(false);
    OneSignal.initialize(appCrashStatsOneSignalString);
    await Future.delayed(const Duration(seconds: 1));
    await OneSignal.Notifications.requestPermission(true);
    appCrashStatsExternalId = Uuid().v1();
    try {
      OneSignal.login(appCrashStatsExternalId!);
    } catch (_) {}
  }

  Future navigateToAppCrashStatsSplash(BuildContext context) async {
    appCrashStatsCheckSharedPreferences.setBool("appCrashStatsSent", true);
    openStandartAppLogic(context);
  }

  void navigateToAppCrashStatsWebView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppCrashStatsWebView(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  AppsFlyerOptions createAppCrashStatsAppsFlyerOptions() {
    return AppsFlyerOptions(
      afDevKey: (afDevKey1 + afDevKey2),
      appId: devKeypndAppId,
      timeToWaitForATTUserAuthorization: 7,
      showDebug: true,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
      manualStart: true,
    );
  }

  Future<void> requestUserSafeTrackingPermission() async {
    if (Platform.isIOS) {
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(seconds: 2));
        final status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        appCrashStatsTrackingStatus = status.toString();

        if (status == TrackingStatus.authorized) {
          getAppCrashStatsAdvertisingId();
        }
        if (status == TrackingStatus.notDetermined) {
          final status =
              await AppTrackingTransparency.requestTrackingAuthorization();
          appCrashStatsTrackingStatus = status.toString();

          if (status == TrackingStatus.authorized) {
            getAppCrashStatsAdvertisingId();
          }
        }
      }
    }
  }

  Future<void> getAppCrashStatsAdvertisingId() async {
    try {
      appCrashStatsAdvertisingId = await AdvertisingId.id(true);
    } catch (_) {}
  }

  Future<String?> sendAppCrashStatsRequest(
    Map<dynamic, dynamic> parameters,
  ) async {
    try {
      final jsonString = json.encode(parameters);
      final base64Parameters = base64.encode(utf8.encode(jsonString));

      final requestBody = {appCrashStatsParameter: base64Parameters};

      final response = await http.post(
        Uri.parse(urlAppCrashStatsLink),
        body: requestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
