import 'dart:io';

import 'package:bearscouts/data_management.dart';
import 'package:bearscouts/database.dart';
import 'package:bearscouts/match_scouting.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:bearscouts/pit_scouting.dart';
import 'package:bearscouts/settings.dart';
import 'package:bearscouts/static_pages.dart';
import 'package:bearscouts/themefile.dart';
import 'package:bearscouts/view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await DBManager.instance.initDatabases();
  // await DBManager.instance.readConfigFromAssetBundle();

  Future.microtask(
    () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("tabletColor")?.toLowerCase().contains("red") ??
          false) {
        DBManager.instance.colorNotifier.value = ColorChangeNotifier(
          darkAppBarTheme.copyWith(
            backgroundColor: Colors.red,
          ),
        );
      } else {
        DBManager.instance.colorNotifier.value = ColorChangeNotifier(
          darkAppBarTheme.copyWith(
            backgroundColor: darkColorScheme.onSecondary,
          ),
        );
      }

      DBManager.instance.modeNotifier.value = ThemeModel(
          prefs.getBool("darkMode") ?? true ? ThemeMode.dark : ThemeMode.light);
      _HomePageState._color = prefs.getBool("darkMode") ?? true;

      if (prefs.getBool("firstRun") ?? true) {
        await DBManager.instance.checkIfTablesExist();
        prefs.setBool("firstRun", false);
      }
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<ThemeModel, ColorChangeNotifier>(
      first: DBManager.instance.modeNotifier,
      second: DBManager.instance.colorNotifier,
      builder: (_, modeModel, colorModel, __) {
        final mode = modeModel.mode;
        final lightTheme = lightColorTheme.copyWith(
            appBarTheme: DBManager.instance.colorNotifier.value.theme);
        final darkTheme = darkColorTheme.copyWith(
            appBarTheme: DBManager.instance.colorNotifier.value.theme);
        return MaterialApp(
          title: 'BEARscouts',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/match_scouting':
                return MaterialPageRoute(
                  builder: (context) => const MatchScouter(),
                );
              case '/pit_scouting':
                return MaterialPageRoute(
                  builder: (context) => const PitScouter(),
                );
              case '/viewer':
                return MaterialPageRoute(
                  builder: (context) => const ViewPage(),
                );
              case '/settings':
                return MaterialPageRoute(
                  builder: (context) => const SettingsAuthPage(),
                );
              case '/settings/match_data':
                return MaterialPageRoute(
                  builder: (context) => MatchSettingsPage(),
                );
              case '/settings/pit_data':
                return MaterialPageRoute(
                  builder: (context) => PitSettingsPage(),
                );
              case '/settings/app_config':
                return MaterialPageRoute(
                  builder: (context) => const AppSettingsPage(),
                );
              case '/settings/data_management':
                return MaterialPageRoute(
                  builder: (context) => const DataManagementPage(),
                );
              case '/about':
                return MaterialPageRoute(
                  builder: (context) => const BEARScoutsAboutUs(),
                );
              case '/':
              default:
                return MaterialPageRoute(
                  builder: (context) => const HomePage(),
                );
            }
          },
          initialRoute: '/',
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static bool _color = true;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        DBManager.instance.modeNotifier.value = ThemeModel(
          _color ? ThemeMode.dark : ThemeMode.light,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BEARscouts'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                _color = !_color;

                SharedPreferences.getInstance().then((value) {
                  value.setBool("darkMode", _color);
                });

                setState(() {
                  DBManager.instance.modeNotifier.value = ThemeModel(
                    _color ? ThemeMode.dark : ThemeMode.light,
                  );
                });
              },
              icon: Icon(_color ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
        ],
      ),
      drawer: const NavDrawer(),
      body: Container(
        decoration: backgroundDecoration,
        child: FutureBuilder(
          builder: (BuildContext context,
              AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.hasData) {
              String tabletName = snapshot.data!.getString("tabletName") ?? "";

              Color textColor =
                  Theme.of(context).textTheme.bodyText1?.color ?? Colors.white;

              if (tabletName.toLowerCase().contains("red")) {
                textColor = Colors.red;
              } else if (tabletName.toLowerCase().contains("blue")) {
                textColor = Colors.blue;
              }

              tabletName += "\nScouting Tablet";

              return Center(
                child: Text(
                  tabletName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 64,
                  ),
                ),
              );
            } else {
              return const Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  width: 100,
                  height: 100,
                ),
              );
            }
          },
          future: SharedPreferences.getInstance(),
        ),
      ),
    );
  }
}
