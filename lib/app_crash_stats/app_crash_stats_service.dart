import 'dart:convert';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';
import 'app_crash_stats.dart';
import 'app_crash_stats_parameters.dart';
import 'app_crash_stats_web_view.dart';
import 'app_crash_stats_web_view_two.dart';

class AppCrashStatsService {
  void navigateToWebView(BuildContext context) {
    final bool useCustomTab =
        appCrashStatsWebViewType == 2 && appCrashStatsLink != null;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            useCustomTab
                ? AppCrashStatsWebViewTwo(link: appCrashStatsLink!)
                : const AppCrashStatsWebViewWidget(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> initializeOneSignal() async {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    await OneSignal.Location.setShared(false);
    OneSignal.initialize(appCrashStatsOneSignalAppId);
    appCrashStatsExternalId = const Uuid().v1();
  }

  Future<void> requestPermissionOneSignal() async {
    await OneSignal.Notifications.requestPermission(true);
    appCrashStatsExternalId = const Uuid().v1();
    try {
      OneSignal.login(appCrashStatsExternalId!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  void notifyOneSignalAccepted() {
    try {
      OneSignal.login(appCrashStatsExternalId ?? const Uuid().v1());
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  void sendRequestToBackend() {
    try {
      OneSignal.login(appCrashStatsExternalId!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  Future<void> navigateToStandardApp(BuildContext context) async {
    appCrashStatsSharedPreferences.setBool(appCrashStatsSentFlagKey, true);
    appCrashStatsOpenStandardAppLogic(context);
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

  AppsFlyerOptions createAppsFlyerOptions() {
    return AppsFlyerOptions(
      afDevKey: (appCrashStatsAfDevKeyPart1 + appCrashStatsAfDevKeyPart2),
      appId: appCrashStatsAppsFlyerAppId,
      timeToWaitForATTUserAuthorization: 5,
      showDebug: true,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
      manualStart: true,
    );
  }

  Future<void> requestTrackingPermission() async {
    if (Platform.isIOS) {
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      appCrashStatsTrackingPermissionStatus = status.toString();

      if (status == TrackingStatus.authorized) {
        await _getAdvertisingId();
      }
    }
  }

  Future<void> _getAdvertisingId() async {
    try {
      appCrashStatsAdvertisingId = await AdvertisingId.id(true);
    } catch (_) {}
  }

  Future<String?> sendAppCrashStatsRequest(
      Map<dynamic, dynamic> parameters) async {
    try {
      final jsonString = json.encode(parameters);
      final base64Parameters = base64.encode(utf8.encode(jsonString));

      final requestBody = {appCrashStatsKeyword: base64Parameters};

      final response = await http.post(
        Uri.parse(appCrashStatsBackendUrl),
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
