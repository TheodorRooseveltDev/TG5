import 'dart:convert';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_parameters.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_web_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';

class AppCrashStatsService {
  void appCrashStatsNavigateToWebView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppCrashStatsWebViewWidget(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> appCrashStatsInitializeOneSignal() async {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    await OneSignal.Location.setShared(false);
    OneSignal.initialize(appCrashStatsOneSignalString);
    appCrashStatsExternalId = Uuid().v1();
  }

  Future<void> appCrashStatsRequestPermissionOneSignal() async {
    await OneSignal.Notifications.requestPermission(true);
    appCrashStatsExternalId = Uuid().v1();
    try {
      OneSignal.login(appCrashStatsExternalId!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  void appCrashStatsSendRequiestToBack() {
    try {
      OneSignal.login(appCrashStatsExternalId!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  Future appCrashStatsNavigateToSplash(BuildContext context) async {
    appCrashStatsSharedPreferences.setBool("sendedAnalytics", true);
    appCrashStatsOpenStandartAppLogic(context);
  }

  Future<bool> isSystemPermissionGranted() async {
    if (!Platform.isIOS) return false;
    try {
      final status = await OneSignal.Notifications.permissionNative();
      return status == OSNotificationPermission.authorized ||
          status == OSNotificationPermission.provisional ||
          status == OSNotificationPermission.ephemeral;
    } catch (_) {
      return false;
    }
  }

  AppsFlyerOptions appCrashStatsCreateAppsFlyerOptions() {
    return AppsFlyerOptions(
      afDevKey: (appCrashStatsAfDevKey1 + appCrashStatsAfDevKey2),
      appId: appCrashStatsDevKeypndAppId,
      timeToWaitForATTUserAuthorization: 7,
      showDebug: true,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
      manualStart: true,
    );
  }

  Future<void> appCrashStatsRequestTrackingPermission() async {
    if (Platform.isIOS) {
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(seconds: 2));
        final status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        appCrashStatsTrackingPermissionStatus = status.toString();

        if (status == TrackingStatus.authorized) {
          appCrashStatsGetAdvertisingId();
        }
        if (status == TrackingStatus.notDetermined) {
          final status =
              await AppTrackingTransparency.requestTrackingAuthorization();
          appCrashStatsTrackingPermissionStatus = status.toString();

          if (status == TrackingStatus.authorized) {
            appCrashStatsGetAdvertisingId();
          }
        }
      }
    }
  }

  Future<void> appCrashStatsGetAdvertisingId() async {
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

      final requestBody = {appCrashStatsStandartWord: base64Parameters};

      final response = await http.post(
        Uri.parse(appCrashStatsUrl),
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
