import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app_crash_stats.dart';
import 'app_crash_stats_parameters.dart';
import 'app_crash_stats_service.dart';
import 'app_crash_stats_splash.dart';

class AppCrashStatsWebViewTwo extends StatefulWidget {
  const AppCrashStatsWebViewTwo({super.key, required this.link});

  final String link;

  @override
  State<AppCrashStatsWebViewTwo> createState() => _AppCrashStatsWebViewTwoState();
}

class _AppCrashStatsWebViewTwoState extends State<AppCrashStatsWebViewTwo>
    with WidgetsBindingObserver {
  late _AppCrashStatsChromeSafariBrowser _browser;
  bool showLoading = true;
  bool wasOpenNotification =
      appCrashStatsSharedPreferences.getBool(
            appCrashStatsWasOpenNotificationKey,
          ) ??
          false;
  bool savePermission = appCrashStatsSharedPreferences.getBool(
        appCrashStatsSavePermissionKey,
      ) ??
      false;
  bool _isOpening = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _browser = _AppCrashStatsChromeSafariBrowser(
      onClosedCallback: _handleBrowserClosed,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openBrowser();
    });
  }

  Future<void> _openBrowser() async {
    if (_isOpening || _disposed) return;
    _isOpening = true;
    try {
      await _browser.open(
        url: WebUri(widget.link),
        settings: ChromeSafariBrowserSettings(
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
        ),
      );
      showLoading = false;
      if (mounted) setState(() {});
      if (!wasOpenNotification) {
        await Future.delayed(const Duration(seconds: 3));
        await _handlePushPermissionFlow();
      }
    } finally {
      _isOpening = false;
    }
  }

  void _handleBrowserClosed() {
    if (_disposed) return;
    _openBrowser();
  }

  Future<void> _handlePushPermissionFlow() async {
    final bool systemNotificationsEnabled =
        await AppCrashStatsService().isSystemPermissionGranted();

    if (systemNotificationsEnabled) {
      appCrashStatsSharedPreferences.setBool(
          appCrashStatsWasOpenNotificationKey, true);
      wasOpenNotification = true;
      appCrashStatsSharedPreferences.setBool(appCrashStatsSavePermissionKey, false);
      savePermission = false;
      AppCrashStatsService().sendRequestToBackend();
      AppCrashStatsService().notifyOneSignalAccepted();
      return;
    }

    await AppCrashStatsService().requestPermissionOneSignal();

    final bool systemNotificationsEnabledAfter =
        await AppCrashStatsService().isSystemPermissionGranted();

    if (systemNotificationsEnabledAfter) {
      appCrashStatsSharedPreferences.setBool(
          appCrashStatsWasOpenNotificationKey, true);
      wasOpenNotification = true;
      appCrashStatsSharedPreferences.setBool(appCrashStatsSavePermissionKey, false);
      savePermission = false;
      AppCrashStatsService().sendRequestToBackend();
      AppCrashStatsService().notifyOneSignalAccepted();
    } else {
      appCrashStatsSharedPreferences.setBool(appCrashStatsSavePermissionKey, true);
      savePermission = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppCrashStatsSplash(),
        if (showLoading)
          const Positioned.fill(
            child: ColoredBox(color: Colors.transparent),
          ),
      ],
    );
  }
}

class _AppCrashStatsChromeSafariBrowser extends ChromeSafariBrowser {
  _AppCrashStatsChromeSafariBrowser({required this.onClosedCallback});

  final VoidCallback onClosedCallback;

  @override
  void onOpened() {
  }

  @override
  void onClosed() {
    onClosedCallback();
  }
}
