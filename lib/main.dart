import 'dart:io';

import 'package:bearscouts/data_management.dart';
import 'package:bearscouts/database.dart';
import 'package:bearscouts/settings.dart';
import 'package:flutter/material.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:bearscouts/pit_scouting.dart';
import 'package:bearscouts/themefile.dart';
import 'package:bearscouts/view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'match_scouting.dart';

Future<void> main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();
  // await DBManager.instance.readConfigFromAssetBundle();
  await DBManager.instance.checkIfTablesExist();

  DBManager.instance.setTabletColor();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final notifier =
      ValueNotifier<ThemeModel>(ThemeModel(ThemeMode.system));

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeModel>(
      valueListenable: notifier,
      builder: (_, model, __) {
        final mode = model.mode;
        return MaterialApp(
          title: 'BEARscouts',
          theme: lightColorTheme,
          darkTheme: darkColorTheme,
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
                  builder: (context) => const MatchSettingsPage(),
                );
              case '/settings/pit_data':
                return MaterialPageRoute(
                  builder: (context) => const PitSettingsPage(),
                );
              case '/settings/app_config':
                return MaterialPageRoute(
                  builder: (context) => const AppSettingsPage(),
                );
              case '/settings/data_management':
                return MaterialPageRoute(
                  builder: (context) => const DataManagementPage(),
                );
              case '/':
              default:
                return MaterialPageRoute(
                  builder: (context) => const HomePage(),
                );
            }
          },
          home: const HomePage(),
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
  bool _color = true;

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

                setState(() {
                  MyApp.notifier.value = ThemeModel(
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
      body: FutureBuilder(
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
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
              child: CircularProgressIndicator(),
            );
          }
        },
        future: SharedPreferences.getInstance(),
      ),
    );
  }
}

class ThemeModel with ChangeNotifier {
  final ThemeMode _themeMode;
  ThemeMode get mode => _themeMode;

  ThemeModel(this._themeMode);
}
