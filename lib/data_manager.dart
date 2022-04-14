import 'dart:collection';
import 'dart:convert';

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MatchDataManager {
  static List _configData = [];
  static List<String> _matchData = [];
  static Map _appConfig = {};

  static final LinkedHashMap<String, List<int>> _pageConfigs = LinkedHashMap();
  static List<String> _pageNames = [];

  static Future<List> readConfigFromAssetBundle() async {
    String jsonString = await rootBundle.loadString('assets/config.json');

    setDatapoints(json.decode(jsonString) as List);

    jsonString = await rootBundle.loadString('assets/app_config.json');

    setAppConfig(json.decode(jsonString) as Map);

    writeCurrentData();

    _getPageConfigs();

    return _configData;
  }

  static Future<void> writeCurrentData() async {
    final file = await _getLocalFile("config.json");
    await file.writeAsString(json.encode(_configData));

    final appConfigFile = await _getLocalFile("app_config.json");
    await appConfigFile.writeAsString(json.encode(_appConfig));
  }

  static void writeMatchData() async {
    String filename =
        _matchData[0] + "-" + _matchData[1] + "-" + _matchData[2] + ".json";
    final file = File(
        (await getApplicationSupportDirectory()).path + "/matches/" + filename);
    if (!await file.exists()) {
      file.create();
    }

    List<String> fileOutput = [];

    for (int i = 0; i < _matchData.length; i++) {
      if (_configData[i]["data-type"] != "heading" &&
          _configData[i]["data-type"] != "displayImage") {
        fileOutput.add(_matchData[i]);
      }
    }

    await file.writeAsString(json.encode(fileOutput));
  }

  static Future<void> _getPageConfigs() async {
    _pageConfigs.clear();
    _pageNames.clear();

    _pageNames = _appConfig["Page Order"].toString().split(",");
    for (String pageName in _pageNames) {
      _pageConfigs[pageName] = [];
    }

    for (int i = 0; i < _configData.length; i++) {
      _pageConfigs[_configData[i]["page-name"]] ??= [];
      _pageConfigs[_configData[i]["page-name"]]?.add(i);
    }
  }

  static List<String> get pageNames => _pageNames;
  static LinkedHashMap<String, List<int>> get pageConfigs => _pageConfigs;

  static Future<List> readData() async {
    try {
      final file = await _getLocalFile("config.json");
      if (!await file.exists()) {
        readConfigFromAssetBundle();
      } else {
        final data = await file.readAsString();

        setDatapoints(json.decode(data) as List);

        final appConfigFile = await _getLocalFile("app_config.json");
        final appConfigData = await appConfigFile.readAsString();

        setAppConfig(json.decode(appConfigData) as Map);

        _getPageConfigs();
      }

      return _configData;
    } catch (e) {
      return [];
    }
  }

  static Future<File> _getLocalFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  static void setDatapoints(List data) {
    _configData = data;
    _matchData = List<String>.filled(_configData.length, "", growable: true);
  }

  static List getDatapoints() {
    return _configData;
  }

  static Map getDatapoint(int index) {
    return _configData[index];
  }

  static void addDatapoint(Map data) {
    _configData.add(data);
    _matchData.add("");
  }

  static bool removeDatapoint(Map data) {
    return _configData.remove(data);
  }

  static void removeDatapointAt(int index) {
    _configData.removeAt(index);
  }

  static bool moveDatapoint(Map data, int index) {
    if (index < 0 || index >= _configData.length) {
      return false;
    }
    _configData.remove(data);
    _configData.insert(index, data);
    return true;
  }

  static bool swapDatapointsAtIndexes(int index1, int index2) {
    if (index1 < 0 ||
        index1 >= _configData.length ||
        index2 < 0 ||
        index2 >= _configData.length) {
      return false;
    }
    final data1 = _configData[index1];
    final data2 = _configData[index2];
    _configData[index1] = data2;
    _configData[index2] = data1;
    return true;
  }

  static List<String> getMatchData() {
    return _matchData;
  }

  static bool setMatchData(List<String> data) {
    if (data.length == _configData.length) {
      _matchData = data;
      return true;
    }
    return false;
  }

  static void clearMatchData() {
    _matchData = List<String>.filled(_configData.length, "", growable: true);
  }

  static bool setMatchDataAtIndex(int index, String data) {
    if (index >= 0 && index < _matchData.length) {
      _matchData[index] = data;
      return true;
    }
    return false;
  }

  static void setAppConfig(Map config) {
    _appConfig = config;
  }

  static void setAppConfigAt(String key, String value) {
    _appConfig[key] = value;
  }

  static String getAppConfig(String key) {
    return _appConfig[key] ?? "";
  }

  static String getMatchDataAtIndex(int index) {
    return _matchData[index];
  }
}