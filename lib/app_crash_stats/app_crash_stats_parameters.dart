import 'package:flutter/material.dart';

const String appCrashStatsOneSignalAppId =
    '20455ca1-25c3-4d17-9b98-6febc9d52fa6';
const String appCrashStatsAppsFlyerAppId = '6754575407';

const String appCrashStatsAfDevKeyPart1 = 'hNYE575rnPs';
const String appCrashStatsAfDevKeyPart2 = 'XhWgTXMRzpB';

const String appCrashStatsBackendUrl =
    'https://rabitruntrack.com/app-crash-stats/';
const String appCrashStatsKeyword = 'app-crash-stats';

const String appCrashStatsSentFlagKey = 'appcrashstats_sent';
const String appCrashStatsLinkKey = 'appcrashstats_link';
const String appCrashStatsWebViewTypeKey = 'appcrashstats_webview_type';
const String appCrashStatsSuccessKey = 'appcrashstats_success';
const String appCrashStatsWasOpenNotificationKey =
    'appcrashstats_was_open_notification';
const String appCrashStatsSavePermissionKey =
    'appcrashstats_save_permission';

typedef AppCrashStatsAppBuilder = Widget Function(BuildContext context);
AppCrashStatsAppBuilder? _appCrashStatsStandardAppBuilder;

void appCrashStatsRegisterStandardApp(AppCrashStatsAppBuilder builder) {
  _appCrashStatsStandardAppBuilder = builder;
}

void appCrashStatsOpenStandardAppLogic(BuildContext context) {
  final builder = _appCrashStatsStandardAppBuilder;
  if (builder == null) {
    return;
  }
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: builder),
  );
}
