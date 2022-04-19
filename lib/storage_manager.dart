import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// This class manages access to the configuration data for the app.
///
/// The data is stored in a JSON file in the application support directory.
class Storage {
  static Storage? instance;

  final String _assetsPath = "assets/";
  final String _matchConfigName = "match_config.json";
  final String _appConfigName = "app_config.json";
  final String _pitConfigName = "pit_config.json";

  final Logger _logger = Logger('Storage');

  List matchConfigData = [];
  List<String> matchData = [];

  List pitConfigData = [];
  List<String> pitData = [];

  Map appConfig = {};

  LinkedHashMap<String, List<int>> matchPageConfigs = LinkedHashMap();
  LinkedHashMap<String, List<int>> pitPageConfigs = LinkedHashMap();

  List<String> matchPageNames = [];
  List<String> pitPageNames = [];

  Storage._();

  factory Storage() {
    instance ??= Storage._();
    return instance!;
  }

  Future<String> get localStorageDataPath async {
    return (await getApplicationSupportDirectory()).path;
  }

  /// Reads config files that came with the app and sets the all of the
  /// confiuration data.
  ///
  /// This method or [readConfigFromLocalStorage] should be called before any
  /// operations are attempted on the data.
  Future<void> readConfigFromAssetBundle() async {
    _logger.fine("Reading config from asset bundle");

    String matchDataString =
        await rootBundle.loadString(_assetsPath + _matchConfigName);
    String appDataString =
        await rootBundle.loadString(_assetsPath + _appConfigName);
    String pitDataString =
        await rootBundle.loadString(_assetsPath + _pitConfigName);

    _logger.finest("Read string data from config files successfully.");

    matchConfigData = json.decode(matchDataString) as List;
    matchData = List.filled(matchConfigData.length, "", growable: true);

    pitConfigData = json.decode(pitDataString) as List;
    pitData = List.filled(pitConfigData.length, "", growable: true);

    appConfig = json.decode(appDataString) as Map;

    _logger.fine("Config read from asset bundle");

    generatePageConfigs();
  }

  /// Reads config files stored locally on the tablet and sets the all of the
  /// confiuration data.
  ///
  /// This method or [readConfigFromAssetBundle] should be called before any
  /// operations are attempted on the data.
  Future<void> readConfigFromLocalStorage() async {
    _logger.fine("Reading config from local storage.");
    try {
      String storagePath = await localStorageDataPath;

      final File matchDataFile = File("$storagePath/$_matchConfigName");
      final File pitDataFile = File("$storagePath/$_pitConfigName");
      final File appConfigFile = File("$storagePath/$_appConfigName");
      _logger.finest("Files instantiated successfully.");
      if (!(await matchDataFile.exists()) ||
          !(await pitDataFile.exists()) ||
          !(await appConfigFile.exists())) {
        _logger.warning("Some/all of the config files are missing. ");
        readConfigFromAssetBundle();
        writeConfigToLocalStorage();
      } else {
        final matchDataString = await matchDataFile.readAsString();
        final pitDataString = await pitDataFile.readAsString();
        final appConfigString = await appConfigFile.readAsString();

        _logger.finest("Read config from files successfully.");

        matchConfigData = json.decode(matchDataString) as List;
        matchData = List.filled(matchConfigData.length, "", growable: true);

        pitConfigData = json.decode(pitDataString) as List;
        pitData = List.filled(pitConfigData.length, "", growable: true);

        appConfig = json.decode(appConfigString) as Map;

        _logger.fine("Config files read from local storage.");

        generatePageConfigs();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _logger.fine("Config read from local storage.");
  }

  Future<void> writeConfigToLocalStorage() async {
    _logger.fine("Writing config to local storage.");
    try {
      String storagePath = await localStorageDataPath;

      final File matchDataFile = File("$storagePath/$_matchConfigName");
      final File pitDataFile = File("$storagePath/$_pitConfigName");
      final File appConfigFile = File("$storagePath/$_appConfigName");
      _logger.finest("Files instantiated successfully.");

      if (!(await matchDataFile.exists())) {
        await matchDataFile.create();
      }
      if (!(await pitDataFile.exists())) {
        await pitDataFile.create();
      }
      if (!(await appConfigFile.exists())) {
        await appConfigFile.create();
      }

      final matchDataString = json.encode(matchConfigData);
      final pitDataString = json.encode(pitConfigData);
      final appConfigString = json.encode(appConfig);

      _logger.finest("Read config from files successfully.");

      await matchDataFile.writeAsString(matchDataString);
      await pitDataFile.writeAsString(pitDataString);
      await appConfigFile.writeAsString(appConfigString);

      _logger.fine("Config files written to local storage.");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _logger.fine("Config written to local storage.");
  }

  Future<void> writeMatchData() async {
    _logger.fine("Writing match data to local storage.");
    try {
      if (matchData.length != matchConfigData.length) {
        _logger.warning("Match data length does not match config data length.");
        return;
      }
      final String matchDataFileName = "$localStorageDataPath/matches/"
          "t${matchData[0]}-"
          "m${matchData[1]}-${matchData[2]}.json";

      final File matchDataFile = File(matchDataFileName);
      _logger.finest("Files instantiated successfully.");

      if (!(await matchDataFile.exists())) {
        await matchDataFile.create();
      }

      List<String> fileOutput = [];

      for (int i = 0; i < matchData.length; i++) {
        if (matchConfigData[i]["data-type"] != "heading" &&
            matchConfigData[i]["data-type"] != "displayImage") {
          fileOutput.add(matchData[i]);
        }
      }

      await matchDataFile.writeAsString(json.encode(fileOutput));

      _logger.fine("Match data written to local storage.");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _logger.fine("Match data written to local storage.");
  }

  Future<void> writePitData(String teamName, String teamNumber) async {
    _logger.fine("Writing pit data to local storage.");
    try {
      if (pitData.length != pitConfigData.length) {
        _logger.warning("Pit data length does not match config data length.");
        return;
      }

      String storagePath = await localStorageDataPath;

      await Directory("$storagePath/pits").create(recursive: true);

      final String pitDataFileName =
          "$storagePath/pit/" + teamName + "-" + teamNumber + ".json";

      final File pitDataFile = File(pitDataFileName);
      _logger.finest("Files instantiated successfully.");

      if (!(await pitDataFile.exists())) {
        await pitDataFile.create();
      }

      List<String> fileOutput = [];

      for (int i = 0; i < pitData.length; i++) {
        if (pitConfigData[i]["data-type"] != "heading" &&
            pitConfigData[i]["data-type"] != "displayImage") {
          fileOutput.add(pitData[i]);
        }
      }

      await pitDataFile.writeAsString(json.encode(fileOutput));

      _logger.fine("Pit data written to local storage.");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _logger.fine("Pit data written to local storage.");
  }

  void generatePageConfigs() {
    _logger.fine("Generating page configs.");
    matchPageConfigs.clear();
    matchPageNames.clear();

    matchPageNames = appConfig["Match Page Order"].toString().split(",");
    for (String pageName in matchPageNames) {
      matchPageConfigs[pageName] = [];
    }

    for (int i = 0; i < matchConfigData.length; i++) {
      matchPageConfigs[matchConfigData[i]["page-name"]] ??= [];
      matchPageConfigs[matchConfigData[i]["page-name"]]?.add(i);
    }
    _logger.fine("Match page configs generated.");

    pitPageConfigs.clear();
    pitPageNames.clear();

    pitPageNames = appConfig["Pit Page Order"].toString().split(",");
    for (String pageName in pitPageNames) {
      pitPageConfigs[pageName] = [];
    }

    for (int i = 0; i < pitConfigData.length; i++) {
      pitPageConfigs[pitConfigData[i]["page-name"]] ??= [];
      pitPageConfigs[pitConfigData[i]["page-name"]]?.add(i);
    }
    _logger.fine("Pit page configs generated.");
  }
}
