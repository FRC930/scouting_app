import 'dart:collection';
import 'dart:convert';

import 'package:bearscouts/themefile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  Database? _dataDB;
  final LinkedHashMap<String, String> _matchData = LinkedHashMap();
  final LinkedHashMap<String, String> _pitData = LinkedHashMap();

  static final DBManager _instance = DBManager._();
  static DBManager get instance => _instance;
  DBManager._();

  final Mutex _dbMutex = Mutex();

  Future<void> initDatabases() async {
    await _dbMutex.protect(() async {
      _dataDB = await openDatabase("data.db");
    });
  }

  Future<void> checkIfTablesExist() async {
    if (_dataDB == null) {
      await initDatabases();
    }

    await _dbMutex.protect(() async {
      final List<Map<String, Object?>> tables = await _dataDB!
          .query("sqlite_master", columns: ["name"], where: "type = 'table'");
      if (tables.length != 4) {
        readConfigFromAssetBundle();
      }
    });
  }

  Future<void> createConfigTables() async {
    await _dbMutex.protect(() async {
      await _dataDB!.execute("drop table if exists config_match");
      await _dataDB!.execute("create table if not exists config_match "
          "(title varchar(50), page varchar(50), type varchar(10), "
          "special1 varchar(200), special2 varchar(200), export integer)");

      await _dataDB!.execute("drop table if exists config_pit");
      await _dataDB!.execute("create table if not exists config_pit "
          "(title varchar(50), page varchar(50), type varchar(10), "
          "special1 varchar(200), special2 varchar(200), export integer)");
    });
  }

  Future<void> createDataTables() async {
    List<Map<String, dynamic>> datapoints = [];
    await _dbMutex.protect(() async {
      datapoints = await _dataDB!.rawQuery(
          "select distinct title from config_match order by export asc");
    });
    List<String> dataNames = [];
    for (Map<String, dynamic> datapoint in datapoints) {
      dataNames.add("\"" + datapoint["title"].toString() + "\"");
      _matchData[datapoint["title"].toString()] = "";
    }
    dataNames.add("timestamp");
    String tableColumns = dataNames.join(" varchar(500), ");
    tableColumns += " datetime";
    await _dbMutex.protect(() async {
      await _dataDB!.execute("drop table if exists data_match");
      await _dataDB!
          .execute("create table if not exists data_match ($tableColumns)");
    });

    await _dbMutex.protect(() async {
      datapoints = await _dataDB!.rawQuery(
          "select distinct title from config_pit order by export asc");
    });
    dataNames = ["Team Number"];
    for (Map<String, dynamic> datapoint in datapoints) {
      dataNames.add("\"" + datapoint["title"].toString() + "\"");
      _pitData[datapoint["title"].toString()] = "";
    }
    dataNames.add("timestamp");
    tableColumns = dataNames.join(" varchar(500), ");
    tableColumns += " datetime";
    await _dbMutex.protect(() async {
      await _dataDB!.execute("drop table if exists data_pit");
      await _dataDB!
          .execute("create table if not exists data_pit ($tableColumns)");
    });
  }

  Future<void> readConfigFromAssetBundle() async {
    debugPrint("Reading config from asset bundle");

    if (_dataDB == null) {
      await initDatabases();
    }

    await readConfigFromString(
      await rootBundle.loadString("assets/config.json"),
    );
  }

  Future<void> readConfigFromString(String data) async {
    if (_dataDB == null) {
      await initDatabases();
    }

    await createConfigTables();

    Map<String, dynamic> jsonMap = json.decode(data);
    List matchConfig = jsonMap["match"];
    for (Map<String, dynamic> datapoint in matchConfig) {
      await _dbMutex.protect(() async {
        await _dataDB!.insert("config_match", datapoint);
      });
    }

    List pitConfig = jsonMap["pit"];
    for (Map<String, dynamic> datapoint in pitConfig) {
      await _dbMutex.protect(() async {
        await _dataDB!.insert("config_pit", datapoint);
      });
    }

    await createDataTables();
  }

  Future<void> updateMatchConfigDatapoint(
    int export,
    String columnName,
    String newValue,
  ) async {
    await _dbMutex.protect(() async {
      await _dataDB!.rawUpdate(
        "update config_match set '$columnName' = '$newValue' where export = $export",
      );
    });
  }

  Future<void> updatePitConfigDatapoint(
    int export,
    String columnName,
    String newValue,
  ) async {
    await _dbMutex.protect(() async {
      await _dataDB!.rawUpdate(
        "update config_pit set '$columnName' = '$newValue' where export = $export",
      );
    });
  }

  Future<void> updateMatchConfigExportAtTitle(String title, int export) async {
    await _dbMutex.protect(() async {
      await _dataDB!.rawUpdate(
        "update config_match set export = $export where title = '$title'",
      );
    });
  }

  Future<void> updatePitConfigExportAtTitle(String title, int export) async {
    await _dbMutex.protect(() async {
      await _dataDB!.rawUpdate(
        "update config_pit set export = $export where title = '$title'",
      );
    });
  }

  Future<List<Map<String, Object?>>> getMatchConfig() async {
    return _dbMutex.protect(() async {
      return await _dataDB!
          .rawQuery("select * from config_match order by export asc");
    });
  }

  Future<List<Map<String, Object?>>> getPitConfig() async {
    return _dbMutex.protect(() async {
      return await _dataDB!
          .rawQuery("select * from config_pit order by export asc");
    });
  }

  Future<List<String>> getMatchDatapointConfig(String key) async {
    if (_dataDB == null) {
      debugPrint("Unable to get config. Database not initialized.");
      await initDatabases();
    }
    List<Map<String, Object?>> queryResult = [];
    await _dbMutex.protect(() async {
      queryResult = await _dataDB!.rawQuery(
        "select * from config_match where title = ?",
        [key],
      );
    });
    if (queryResult.isEmpty) {
      debugPrint("Unable to get config. Key not found.");
      return [];
    }
    List<String> result = [];
    queryResult.first.forEach((key, value) {
      result.add(value.toString());
    });

    return result;
  }

  void setMatchDatapoint(String name, String value) {
    _matchData[name] = value;
  }

  String getMatchDatapoint(String name) {
    return _matchData[name] ?? "";
  }

  Future<void> writeMatchData() async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    Map<String, String> matchDataToWrite = {};

    _matchData.forEach((key, value) {
      matchDataToWrite["\"" + key + "\""] = value;
    });

    matchDataToWrite["timestamp"] = DateTime.now().toString();

    await _dbMutex.protect(() async {
      await _dataDB!.insert("data_match", matchDataToWrite);
    });
  }

  Future<List<String>> getMatchPages() async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    List<Map<String, Object?>> queryResult = [];
    await _dbMutex.protect(() async {
      queryResult = await _dataDB!.rawQuery(
        "select distinct page from config_match",
      );
    });
    List<String> result = [];
    for (Map<String, Object?> datapoint in queryResult) {
      result.add(datapoint["page"].toString());
    }

    return result;
  }

  Future<List<String>> getMatchPageWidgets(String pagename) async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    List<Map<String, Object?>> queryResult = [];
    await _dbMutex.protect(() async {
      queryResult = await _dataDB!.rawQuery(
        "select title from config_match where page = ?",
        [pagename],
      );
    });
    List<String> result = [];
    for (Map<String, Object?> datapoint in queryResult) {
      result.add(datapoint["title"].toString());
    }

    return result;
  }

  void clearMatchData() {
    _matchData.clear();
  }

  Future<List<String>> getPitDatapointConfig(String key) async {
    if (_dataDB == null) {
      debugPrint("Unable to get config. Database not initialized.");
      await initDatabases();
    }
    List<Map<String, Object?>> queryResult = [];
    await _dbMutex.protect(() async {
      queryResult = await _dataDB!.rawQuery(
        "select * from config_pit where title = ?",
        [key],
      );
    });
    if (queryResult.isEmpty || queryResult.length > 1) {
      debugPrint("Unable to get config. Either zero or one or more "
          "entries were found with the same title.");
      return [];
    }
    List<String> result = [];
    queryResult.first.forEach((key, value) {
      result.add(value.toString());
    });

    return result;
  }

  void setPitDatapoint(String name, String value) {
    _pitData[name] = value;
  }

  String getPitDatapoint(String name) {
    return _pitData[name] ?? "";
  }

  Future<void> writePitData() async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    Map<String, String> pitDataToWrite = {};

    _pitData.forEach((key, value) {
      pitDataToWrite["\"" + key + "\""] = value;
    });

    pitDataToWrite["timestamp"] = DateTime.now().toString();

    await _dbMutex.protect(() async {
      await _dataDB!.insert("data_pit", pitDataToWrite);
    });
  }

  Future<List<String>> getPitPages() async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    List<Map<String, Object?>> queryResult = [];
    await _dbMutex.protect(() async {
      queryResult = await _dataDB!.rawQuery(
        "select distinct page from config_pit",
      );
    });
    List<String> result = [];
    for (Map<String, Object?> datapoint in queryResult) {
      result.add(datapoint["page"].toString());
    }

    return result;
  }

  Future<List<String>> getPitPageWidgets(String pagename) async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    List<Map<String, Object?>> queryResult = [];
    await _dbMutex.protect(() async {
      queryResult = await _dataDB!.rawQuery(
        "select title from config_pit where page = ?",
        [pagename],
      );
    });
    List<String> result = [];
    for (Map<String, Object?> datapoint in queryResult) {
      result.add(datapoint["title"].toString());
    }

    return result;
  }

  void clearPitData() {
    _pitData.clear();
  }

  Future<List<Map<String, Object?>>> getData(String query) async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    return await _dbMutex.protect<List<Map<String, Object?>>>(() async {
      return await _dataDB!.rawQuery(query);
    });
  }

  Future<void> deleteData(String query) async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    await _dbMutex.protect(() async {
      await _dataDB!.rawDelete(query);
    });
  }

  Future<void> insertData(String query) async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    await _dbMutex.protect(() async {
      await _dataDB!.rawInsert(query);
    });
  }

  Future<void> updateData(String query) async {
    if (_dataDB == null) {
      debugPrint("Database not initialized. Attempting to initialize.");
      await initDatabases();
    }

    await _dbMutex.protect(() async {
      await _dataDB!.rawUpdate(query);
    });
  }

  void setTabletColor() async {
    final prefs = await SharedPreferences.getInstance();
    String tabletName = prefs.getString("tabletColor") ?? "blue";
    if (tabletName.toLowerCase().contains("red")) {
      lightAppBarTheme = lightAppBarTheme.copyWith(color: Colors.red);
      darkAppBarTheme = darkAppBarTheme.copyWith(color: Colors.red);
    } else {
      lightAppBarTheme = lightAppBarTheme.copyWith(color: Colors.blue);
      darkAppBarTheme = darkAppBarTheme.copyWith(color: Colors.blue);
    }
  }
}
