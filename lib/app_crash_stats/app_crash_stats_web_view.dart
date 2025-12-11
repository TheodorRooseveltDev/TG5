import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'app_crash_stats.dart';
import 'app_crash_stats_parameters.dart';
import 'app_crash_stats_service.dart';
import 'app_crash_stats_splash.dart';

class AppCrashStatsWebViewWidget extends StatefulWidget {
  const AppCrashStatsWebViewWidget({super.key});

  @override
  State<AppCrashStatsWebViewWidget> createState() =>
      _AppCrashStatsWebViewWidgetState();
}

class _AppCrashStatsWebViewWidgetState extends State<AppCrashStatsWebViewWidget>
    with WidgetsBindingObserver {
  InAppWebViewController? appCrashStatsWebViewController;

  bool appCrashStatsShowLoading = true;

  bool appCrashStatsWasOpenNotification =
      appCrashStatsSharedPreferences.getBool(
            appCrashStatsWasOpenNotificationKey,
          ) ??
          false;

  bool appCrashStatsSavePermission = appCrashStatsSharedPreferences.getBool(
        appCrashStatsSavePermissionKey,
      ) ??
      false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appCrashStatsSyncNotificationState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  Future<void> appCrashStatsSyncNotificationState() async {
    final bool systemNotificationsEnabled =
        await AppCrashStatsService().isSystemPermissionGranted();

    appCrashStatsWasOpenNotification = systemNotificationsEnabled;
    appCrashStatsSharedPreferences.setBool(
      appCrashStatsWasOpenNotificationKey,
      systemNotificationsEnabled,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> appCrashStatsAfterSetting() async {
    final deviceState = OneSignal.User.pushSubscription;

    bool havePermission = deviceState.optedIn ?? false;
    final bool systemNotificationsEnabled =
        await AppCrashStatsService().isSystemPermissionGranted();

    if (havePermission || systemNotificationsEnabled) {
      appCrashStatsSharedPreferences.setBool(
          appCrashStatsWasOpenNotificationKey, true);
      appCrashStatsWasOpenNotification = true;
      appCrashStatsSharedPreferences.setBool(appCrashStatsSavePermissionKey, false);
      appCrashStatsSavePermission = false;
      AppCrashStatsService().sendRequestToBackend();
    }

    setState(() {});
  }

  Future<void> appCrashStatsHandlePushPermissionFlow() async {
    await AppCrashStatsService().requestPermissionOneSignal();

    final bool systemNotificationsEnabled =
        await AppCrashStatsService().isSystemPermissionGranted();

    if (systemNotificationsEnabled) {
      appCrashStatsSharedPreferences.setBool(
          appCrashStatsWasOpenNotificationKey, true);
      appCrashStatsWasOpenNotification = true;
      appCrashStatsSharedPreferences.setBool(appCrashStatsSavePermissionKey, false);
      appCrashStatsSavePermission = false;
      AppCrashStatsService().sendRequestToBackend();
    } else {
      appCrashStatsSharedPreferences.setBool(appCrashStatsSavePermissionKey, true);
      appCrashStatsSavePermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: appCrashStatsShowLoading ? 0 : 1,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: InAppWebView(
                      onCreateWindow: (controller,
                          CreateWindowAction createWindowRequest) async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => _AppCrashStatsPopupWebView(
                              windowId: createWindowRequest.windowId,
                              initialRequest: createWindowRequest.request,
                            ),
                          ),
                        );
                        return true;
                      },
                      initialUrlRequest: URLRequest(
                        url: WebUri(appCrashStatsLink!),
                      ),
                      initialSettings: InAppWebViewSettings(
                        allowsBackForwardNavigationGestures: false,
                        javaScriptEnabled: true,
                        allowsInlineMediaPlayback: true,
                        mediaPlaybackRequiresUserGesture: false,
                        supportMultipleWindows: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                        cacheEnabled: true,
                        clearCache: false,
                        cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
                        useOnLoadResource: false,
                        useShouldInterceptAjaxRequest: false,
                        useShouldInterceptFetchRequest: false,
                        hardwareAcceleration: true,
                        thirdPartyCookiesEnabled: true,
                        sharedCookiesEnabled: true,
                        disallowOverScroll: true,
                      ),
                      onWebViewCreated: (controller) {
                        appCrashStatsWebViewController = controller;
                      },
                      onLoadStop: (controller, url) async {
                        appCrashStatsShowLoading = false;
                        setState(() {});
                        if (appCrashStatsWasOpenNotification) return;

                        final bool systemNotificationsEnabled =
                            await AppCrashStatsService()
                                .isSystemPermissionGranted();

                        await Future.delayed(const Duration(seconds: 3));

                        if (systemNotificationsEnabled) {
                          appCrashStatsSharedPreferences.setBool(
                            appCrashStatsWasOpenNotificationKey,
                            true,
                          );
                          appCrashStatsWasOpenNotification = true;
                          AppCrashStatsService().sendRequestToBackend();
                          AppCrashStatsService().notifyOneSignalAccepted();
                        }

                        if (!systemNotificationsEnabled) {
                          appCrashStatsWasOpenNotification = true;
                          await appCrashStatsHandlePushPermissionFlow();
                        }

                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return appCrashStatsBuildWebBottomBar(orientation);
              },
            ),
          ),
        ),
        if (appCrashStatsShowLoading) const AppCrashStatsSplash(),
      ],
    );
  }

  Widget appCrashStatsBuildWebBottomBar(Orientation orientation) {
    return Container(
      color: Colors.black,
      height: orientation == Orientation.portrait ? 25 : 30,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (appCrashStatsWebViewController != null &&
                  await appCrashStatsWebViewController!.canGoBack()) {
                appCrashStatsWebViewController!.goBack();
              }
            },
          ),
          const SizedBox.shrink(),
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (appCrashStatsWebViewController != null &&
                  await appCrashStatsWebViewController!.canGoForward()) {
                appCrashStatsWebViewController!.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AppCrashStatsPopupWebView extends StatelessWidget {
  const _AppCrashStatsPopupWebView({
    required this.windowId,
    required this.initialRequest,
  });

  final int? windowId;
  final URLRequest? initialRequest;

  @override
  Widget build(BuildContext context) {
    return _AppCrashStatsPopupWebViewBody(
      windowId: windowId,
      initialRequest: initialRequest,
    );
  }
}

class _AppCrashStatsPopupWebViewBody extends StatefulWidget {
  const _AppCrashStatsPopupWebViewBody({
    required this.windowId,
    required this.initialRequest,
  });

  final int? windowId;
  final URLRequest? initialRequest;

  @override
  State<_AppCrashStatsPopupWebViewBody> createState() =>
      _AppCrashStatsPopupWebViewBodyState();
}

class _AppCrashStatsPopupWebViewBodyState
    extends State<_AppCrashStatsPopupWebViewBody> {
  InAppWebViewController? popupController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        foregroundColor: Colors.white,
        toolbarHeight: 36,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: progress < 1 ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: LinearProgressIndicator(
                value: progress < 1 ? progress : null,
                minHeight: 2,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xff007AFF)),
              ),
            ),
            Expanded(
              child: InAppWebView(
                windowId: widget.windowId,
                initialUrlRequest: widget.initialRequest,
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  supportMultipleWindows: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  allowsInlineMediaPlayback: true,
                ),
                onWebViewCreated: (controller) {
                  popupController = controller;
                },
                onProgressChanged: (controller, newProgress) {
                  setState(() {
                    progress = newProgress / 100;
                  });
                },
                onLoadStop: (controller, uri) {
                  setState(() {
                    progress = 1;
                  });
                },
                onCloseWindow: (controller) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
