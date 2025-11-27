import 'package:flutter/material.dart';
import 'package:rabit_run/main.dart';

String appCrashStatsOneSignalString = "20455ca1-25c3-4d17-9b98-6febc9d52fa6";
String appCrashStatsDevKeypndAppId = "6754575407";

String appCrashStatsAfDevKey1 = "hNYE575rnPs";
String appCrashStatsAfDevKey2 = "XhWgTXMRzpB";

String appCrashStatsUrl = 'https://rabitruntrack.com/app-crash-stats/';
String appCrashStatsStandartWord = "app-crash-stats";

void appCrashStatsOpenStandartAppLogic(BuildContext context) async {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const AppInitializer()),
  );
}
