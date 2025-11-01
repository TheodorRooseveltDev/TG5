import 'package:flutter/material.dart';
import 'package:rabit_run/shared/widgets/splash_loading_screen.dart';

class AppCrashStatsSplash extends StatefulWidget {
  const AppCrashStatsSplash({super.key});

  @override
  State<AppCrashStatsSplash> createState() => _AppCrashStatsSplashState();
}

class _AppCrashStatsSplashState extends State<AppCrashStatsSplash> {
  @override
  Widget build(BuildContext context) {
    return SplashLoadingScreen();
  }
}
