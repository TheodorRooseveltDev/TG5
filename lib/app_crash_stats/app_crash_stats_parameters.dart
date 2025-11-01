import 'package:flutter/material.dart';
import 'package:rabit_run/main.dart';

String appCrashStatsOneSignalString = "20455ca1-25c3-4d17-9b98-6febc9d52fa6";
String afDevKey1 = "hNYE575rnPs";
String afDevKey2 = "XhWgTXMRzpB";

String urlAppCrashStatsLink = "https://rabitruntrack.com/app-crash-stats/";

String appCrashStatsParameter = "app-crash-stats";

String devKeypndAppId = "6754575407";

void openStandartAppLogic(BuildContext context) async {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const AppInitializer()),
  );
}
