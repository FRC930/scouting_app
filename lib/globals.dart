import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Directory? appFilesDir;
String? appFilesDirString;
Map<String, Map> matchData = {};
Map<int, GlobalKey<FormState>> formKeys = {};

void writeMatchData() {
  if (!kIsWeb) {
    final String filename = "match-" +
        matchData["Pre-Match Data"]!["Match Number"]!.item2 +
        "_" +
        matchData["Pre-Match Data"]!["Scouter Name"]!.item2 +
        ".csv";

    Map<String, List<String>> matchDataItems = {};

    matchData.forEach((key1, value1) {
      matchDataItems[key1] ??= [];
      value1.forEach((key2, value2) {
        matchDataItems[key1]!.insert(
            value2.item1 < matchDataItems[key1]!.length
                ? value2.item1
                : matchDataItems[key1]!.length,
            value2.item2);
      });
    });

    String matchDataString = "";
    matchDataItems.forEach((key, value) {
      for (var element in value) {
        matchDataString += element;
        matchDataString += ";";
      }
    });

    final csvFile = File(appFilesDirString! + "/" + filename);
    if (csvFile.existsSync()) {
      csvFile.deleteSync();
    }
    csvFile.createSync();
    csvFile.writeAsStringSync(matchDataString);

    matchData.clear();
  }
}
