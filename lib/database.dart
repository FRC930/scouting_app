import 'dart:collection';
import 'dart:convert';

import 'package:bearscouts/themefile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mutex/mutex.dart';
import 'package:sqflite/sqflite.dart';

/// DBManager
/// This takes care of everything to do with the SQL database. We have a bunch
/// of helper functions that make it very easy to access the data
class DBManager {
  Database? _dataDB;
  // Linked hash maps keep what order they were assigned. Normal maps do not
  // neccesarily behave in the same way.
  final LinkedHashMap<String, String> _matchData = LinkedHashMap();
  final LinkedHashMap<String, String> _pitData = LinkedHashMap();

  // This is the object that will tell the app to rerender whenever the user
  // changes from dark to light mode and vice versa.
  final modeNotifier = ValueNotifier<ThemeModel>(ThemeModel(ThemeMode.system));
  // This notifies the app to redraw itself when the user changes the color
  // of the app bar. This is done in settings
  final colorNotifier =
      ValueNotifier<ColorChangeNotifier>(ColorChangeNotifier(darkAppBarTheme));

  // This class is used as a singleton to ensure we don't try to access the
  // database with a couple of different instances.
  static final DBManager _instance = DBManager._();
  static DBManager get instance => _instance;
  DBManager._();

  // Though dart is not an asynchronous language, it does have some form of
  // parallel execution. This mutex just ensures that two functions aren't
  // modifying the same data at the same time.
  final Mutex _dbMutex = Mutex();

  // This function is called at the beginning of execution. All it does is open
  // the database that we have stored in our app files.
  Future<void> initDatabases() async {
    await _dbMutex.protect(() async {
      _dataDB = await openDatabase("data.db");
    });
  }

  // This function checks to see if the database has the tables configured
  Future<void> checkIfTablesExist() async {
    // Init database if it isn't already
    if (_dataDB == null) {
      await initDatabases();
    }

    // Use the mutex to make sure that only we can access it.
    await _dbMutex.protect(() async {
      // Get the number of table. There should be four: match config, pit
      // config, match data, and pit data. If there aren't those four tables,
      // the database needs to be reconfigured so we read config from the
      // asset bundle. This gets us to a reasonable default.
      final List<Map<String, Object?>> tables = await _dataDB!
          .query("sqlite_master", columns: ["name"], where: "type = 'table'");
      if (tables.length != 4) {
        readConfigFromAssetBundle();
      }
    });
  }

  // The create config tables function erases everything that is currently
  // in the config tables. It then creates empty tables that have the correct
  // dimensions and column names.
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

  // Create data tables takes the information found in the config tables and
  // creates data tables that are able to receive data in the format specified.
  Future<void> createDataTables() async {
    // Get the titles of the widgets from the config tables
    List<Map<String, dynamic>> datapoints = [];
    await _dbMutex.protect(() async {
      datapoints = await _dataDB!.rawQuery(
          "select distinct title from config_match order by export asc");
    });
    // Extract the titles of the widgets from the datapoints
    List<String> dataNames = [];
    for (Map<String, dynamic> datapoint in datapoints) {
      dataNames.add("\"" + datapoint["title"].toString() + "\"");
      _matchData[datapoint["title"].toString()] = "";
    }
    // Add a timestamp so that we know when the match happened
    dataNames.add("timestamp");
    // Join the columns together into a proper sql statement.
    String tableColumns = dataNames.join(" varchar(500), ");
    // Add datetime to the end so that timestamp is stored in that format
    tableColumns += " datetime";
    // Drop and create the table to ensure that we have no leftover data
    await _dbMutex.protect(() async {
      await _dataDB!.execute("drop table if exists data_match");
      await _dataDB!
          .execute("create table if not exists data_match ($tableColumns)");
    });

    // Repeat the same process for the pit configuration
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

  // This will reset the configuration to a reasonable default
  Future<void> readConfigFromAssetBundle() async {
    debugPrint("Reading config from asset bundle");

    // Check to see that we actually have a database
    if (_dataDB == null) {
      await initDatabases();
    }

    // Use the helper function to read from a string
    await readConfigFromString(
      await rootBundle.loadString("assets/config.json"),
    );
  }

  // This is a function to read configuration data from string encoded in json
  // format. See the config.json file for the stucture required for that file.
  Future<void> readConfigFromString(String data) async {
    // Make sure databases are good to go
    if (_dataDB == null) {
      await initDatabases();
    }

    // Clear the config tables
    await createConfigTables();

    // Parse the json string
    Map<String, dynamic> jsonMap = json.decode(data);
    // Get the match config from the json
    List matchConfig = jsonMap["match"];
    // Loop through the datapoints
    for (Map<String, dynamic> datapoint in matchConfig) {
      await _dbMutex.protect(() async {
        // Add the datapoint to the config database
        await _dataDB!.insert("config_match", datapoint);
      });
    }

    // Same story here, just for pit
    List pitConfig = jsonMap["pit"];
    for (Map<String, dynamic> datapoint in pitConfig) {
      await _dbMutex.protect(() async {
        await _dataDB!.insert("config_pit", datapoint);
      });
    }

    // Create the data tables based on the config tables
    await createDataTables();
  }

  // ------ MODIFICATION FUNCTIONS ------ \\
  // These functions will not make any sense if you do not know SQL. Learn that
  // first or ask somebody who knows what SQL is and does.

  // A description of the different columns in the config database
  // Title: The title of the data widget. This is what will appear next to the 
  //    widget when it is loaded on screen
  // Page: The page on which the widget will appear. This is useful for making
  //    widgets appear on one page but export in a different order. 
  // Type: This tells the app which kind of widget you are trying to render. The
  //    configuration and display of each widget is different.
  // Special1: This column can serve a few different purposes. It is used to
  //    store any of the following things: the type of information to collect 
  //    in the case of a field, the path to an file in the case of an image or
  //    a heatmap, or the internal results of a multiple choice field.
  // Special2: This column serves two different purposes. In the case of a
  //    field, it stores the validation error message. For multiple choice, it
  //    stores the text that should display in a multiple choice box.

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

  // This function takes the data stored in the transient memory and stores it
  // to the more stable database.
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

  // This is used to make raw queries to the database. Only use this if you know
  // what you are doing. It is used for specialized queries that are only made
  // once over the lifetime of the app.
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
}


// These two classes are used to make the app change colors when the different
// themes are selected or the color of the app bar should change
class ThemeModel with ChangeNotifier {
  final ThemeMode _themeMode;
  ThemeMode get mode => _themeMode;

  ThemeModel(this._themeMode);
}

class ColorChangeNotifier with ChangeNotifier {
  final AppBarTheme _appBarTheme;
  AppBarTheme get theme => _appBarTheme;

  ColorChangeNotifier(this._appBarTheme);
}
