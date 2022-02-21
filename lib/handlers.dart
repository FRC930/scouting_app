import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MatchHandler {
  static final Map<String, Map> matchData = {};

  static Map<String, Map> getMatchData() => matchData;

  static void writeMatchData() {
    getApplicationDocumentsDirectory().then((directory) {
      final String filename = "match-" +
          matchData["pre-match"]!["Match Number"] +
          "_" +
          matchData["pre-match"]!["Scouter Name"] +
          ".csv";
      String matchDataString = "";

      ConfigHandler.getData().forEach((key, value) {
        value.forEach((value) {
          matchDataString +=
              (MatchHandler.matchData[key]![value["title"]] ?? "0") + ";";
        });
      });
      final csvFile = File(directory.path + "/" + filename);
      csvFile.createSync();
      csvFile.writeAsStringSync(matchDataString);
    });
  }

  static Future<void> clearData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    matchData.clear();
  }
}

class MatchViewHandler {
  static Future<List<String>> readMatchFiles() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    List<String> files = [];
    appDocDir.list().forEach((element) {
      if (element.path.endsWith("csv")) {
        files.add(element.path);
      }
    });

    return files;
  }
}

class ConfigHandler {
  static Map _data = {};
  static final List<String> preMatchData = [];
  static final List<String> autonData = [];
  static final List<String> teleopData = [];
  static final List<String> endgameData = [];
  static final List<String> postMatchData = [];

  static Future<void> readConfigJson() async {
    final String response = await rootBundle.loadString("assets/config.json");
    final data = await json.decode(response);
    _data = data;
    data["pre-match"].forEach((value) {
      preMatchData.add(value["title"]);
    });
    data["auton"].forEach((value) {
      autonData.add(value["title"]);
    });
    data["teleop"].forEach((value) {
      teleopData.add(value["title"]);
    });
    data["endgame"].forEach((value) {
      endgameData.add(value["title"]);
    });
    data["post-match"].forEach((value) {
      postMatchData.add(value["title"]);
    });
  }

  static Map getData() {
    if (_data.isEmpty) {
      readConfigJson();
    }
    return _data;
  }
}
