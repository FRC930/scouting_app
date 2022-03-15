import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Directory? appFilesDir;
String? appFilesDirString;
LinkedHashMap<String, List> matchData = LinkedHashMap();
Map<String, GlobalKey<FormState>> formKeys = {};
String currentPage = "";

Future<void> readConfigJson() async {
  rootBundle.loadString("assets/config.json").then((response) {
    matchData = LinkedHashMap.from(json.decode(response));
    matchData.forEach((key, value) {
      for (var element in value) {
        element["data"] = "";
      }
    });
  });
}

void writeMatchData() {
  if (!kIsWeb) {
    String filename = "match";
    for (int i = 0; i <= 2; i++) {
      String? currentData = matchData["Pre-Match Data"]?[i]["data"];
      if (currentData != null) {
        filename += currentData;
        filename += "_";
      }
    }
    filename += ".json";

    readConfigJson();

    final jsonFile = File(appFilesDirString! + "/" + filename);
    if (jsonFile.existsSync()) {
      jsonFile.deleteSync();
    }
    jsonFile.createSync();
    jsonFile.writeAsStringSync(json.encode(matchData));
  }
}
