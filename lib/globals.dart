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

Future<void> readConfigJson() async {
  // rootBundle.load("assets/config.json").then(
  //   (value) {
  //     matchData = json.decode(value.toString());
  //   },
  // );
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
    String filename = "match-";
    matchData["Pre-Match Data"]?.forEach((element) {
      filename += element["data"];
      filename += "_";
    });
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
