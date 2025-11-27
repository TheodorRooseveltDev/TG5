import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_consent_prompt.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_service.dart';
import 'package:rabit_run/app_crash_stats/app_crash_stats_splash.dart';

class AppCrashStatsWebViewWidget extends StatefulWidget {
  const AppCrashStatsWebViewWidget({super.key});

  @override
  State<AppCrashStatsWebViewWidget> createState() =>
      _AppCrashStatsWebViewWidgetState();
}

class _AppCrashStatsWebViewWidgetState extends State<AppCrashStatsWebViewWidget>
    with WidgetsBindingObserver {
  late InAppWebViewController appCrashStatsWebViewController;

  bool appCrashStatsShowLoading = true;
  bool appCrashStatsShowConsentPrompt = false;

  bool appCrashStatsWasOpenNotification =
      appCrashStatsSharedPreferences.getBool("wasOpenNotification") ?? false;

  final bool savePermission =
      appCrashStatsSharedPreferences.getBool("savePermission") ?? false;

  bool waitingForSettingsReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (waitingForSettingsReturn) {
        waitingForSettingsReturn = false;
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) {
            appCrashStatsAfterSetting();
          }
        });
      }
    }
  }

  Future<void> appCrashStatsAfterSetting() async {
    final deviceState = OneSignal.User.pushSubscription;

    bool havePermission = deviceState.optedIn ?? false;
    final bool systemNotificationsEnabled = await AppCrashStatsService()
        .isSystemPermissionGranted();

    if (havePermission || systemNotificationsEnabled) {
      appCrashStatsSharedPreferences.setBool("wasOpenNotification", true);
      appCrashStatsWasOpenNotification = true;
      AppCrashStatsService().appCrashStatsSendRequiestToBack();
    }

    appCrashStatsShowConsentPrompt = false;
    setState(() {});
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
                      onCreateWindow:
                          (
                            controller,
                            CreateWindowAction createWindowRequest,
                          ) async {
                            await showDialog(
                              context: context,
                              builder: (dialogContext) {
                                final dialogSize = MediaQuery.of(
                                  dialogContext,
                                ).size;

                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      SizedBox(
                                        width: dialogSize.width,
                                        height: dialogSize.height * 0.8,
                                        child: InAppWebView(
                                          windowId:
                                              createWindowRequest.windowId,
                                          initialSettings: InAppWebViewSettings(
                                            javaScriptEnabled: true,
                                          ),
                                          onCloseWindow: (controller) {
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: -18,
                                        right: -18,
                                        child: Material(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {
                                              Navigator.of(dialogContext).pop();
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

                        await Future.delayed(Duration(milliseconds: 3000));

                        if (systemNotificationsEnabled) {
                          appCrashStatsSharedPreferences.setBool(
                            "wasOpenNotification",
                            true,
                          );
                          appCrashStatsWasOpenNotification = true;
                        }

                        if (!systemNotificationsEnabled) {
                          appCrashStatsShowConsentPrompt = true;
                          appCrashStatsWasOpenNotification = true;
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
        if (!appCrashStatsShowLoading)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            reverseDuration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: appCrashStatsShowConsentPrompt
                ? AppCrashStatsConsentPromptPage(
                    key: const ValueKey('consent_prompt'),
                    onYes: () async {
                      if (savePermission == true) {
                        waitingForSettingsReturn = true;
                        await AppSettings.openAppSettings(
                          type: AppSettingsType.settings,
                        );
                      } else {
                        await AppCrashStatsService()
                            .appCrashStatsRequestPermissionOneSignal();

                        final bool systemNotificationsEnabled =
                            await AppCrashStatsService()
                                .isSystemPermissionGranted();

                        if (systemNotificationsEnabled) {
                          appCrashStatsSharedPreferences.setBool(
                            "wasOpenNotification",
                            true,
                          );
                        } else {
                          appCrashStatsSharedPreferences.setBool(
                            "savePermission",
                            true,
                          );
                        }
                        appCrashStatsWasOpenNotification = true;
                        appCrashStatsShowConsentPrompt = false;
                        setState(() {});
                      }
                    },
                    onNo: () {
                      setState(() {
                        appCrashStatsWasOpenNotification = true;
                        appCrashStatsShowConsentPrompt = false;
                      });
                    },
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
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
              if (await appCrashStatsWebViewController.canGoBack()) {
                appCrashStatsWebViewController.goBack();
              }
            },
          ),
          const SizedBox.shrink(),
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await appCrashStatsWebViewController.canGoForward()) {
                appCrashStatsWebViewController.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}
