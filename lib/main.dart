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

// This is the main method of the application.
// Also known as the entry point of the application, this serves to perform a
// few functions prior to loading the visual interface of the app
Future<void> main() async {
  // We need to use sqflite_ffi for Windows/Linux, as plain sqlite isn't supported
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // This ensures that we don't do anything with widgets before the Flutter
  // framework is done initializing
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the databases we will use for storing match and pit data, as
  // well as the databses that hold the match/pit configuration data
  await DBManager.instance.initDatabases();

  // Set a microtask (something that will run "asyncronously" to the main thread.)
  // This prevents us from stopping the user interface from showing up while we
  // load all of the neccessary themes
  Future.microtask(
    () async {
      // All of the preferences for tablet color and theme are stored in
      // SharedPreferences. We use this to ensure that these values stay the
      // same between app instances/runs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // We check to see what color the appbar should be. If it's red,
      // we copy the dark app bar theme into the change notifier. Because the
      // Flutter framework is already initialized (line 30), we don't have to
      // worry about the object not being loaded yet
      if (prefs.getString("tabletColor")?.toLowerCase().contains("red") ??
          false) {
        // This color change notifier is a custom notifier that will tell the
        // app that it needs to change the color of the appbar whenever we
        // reassign the value contained in DBManager
        DBManager.instance.colorNotifier.value = ColorChangeNotifier(
          darkAppBarTheme.copyWith(
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Default to blue if the value doesn't match red
        // Same idea as before, just with blue as the color instead of red
        DBManager.instance.colorNotifier.value = ColorChangeNotifier(
          darkAppBarTheme.copyWith(
            backgroundColor: darkColorScheme.onSecondary,
          ),
        );
      }

      // We don't rely on the system for dark/light mode. The user is free to
      // set it to dark/light mode, and the app will remember that through the
      // use of SharedPreferences.
      DBManager.instance.modeNotifier.value = ThemeModel(
          prefs.getBool("darkMode") ?? true ? ThemeMode.dark : ThemeMode.light);
      // Setting this allows us to not have to re-get the value again when we
      // initialize the home page
      _HomePageState._color = prefs.getBool("darkMode") ?? true;

      // This is a flag that is set whenever the app runs. If the tables don't
      // exist, we need to create them, but if we recreate the tables after the
      // first run of the app, we lose all of the data that was stored in the
      // tables during previous runs
      if (prefs.getBool("firstRun") ?? true) {
        await DBManager.instance.checkIfTablesExist();
        prefs.setBool("firstRun", false);
      }
    },
  );

  // After setting that microtask to run at some point in the near future, we
  // can run the main class to create the view that the user will see
  runApp(const MainApp());
}

/// MainApp is the StatelessWidget that handles everything about the app's
/// navigation and theme changes
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  // The build method is essential to every widget. It will be called whenever a
  // repaint is needed
  @override
  Widget build(BuildContext context) {
    // A ValueListenableBuilder2 is a union of two ChangeNotifiers. These will
    // monitor the values that they are assigned and tell the app to repaint if
    // one of them changes
    return ValueListenableBuilder2<ThemeModel, ColorChangeNotifier>(
      first: DBManager.instance.modeNotifier,
      second: DBManager.instance.colorNotifier,
      builder: (_, modeModel, colorModel, __) {
        final mode = modeModel.mode;
        final lightTheme = lightColorTheme.copyWith(
            appBarTheme: DBManager.instance.colorNotifier.value.theme);
        final darkTheme = darkColorTheme.copyWith(
            appBarTheme: DBManager.instance.colorNotifier.value.theme);
        // The MaterialApp is the main part of the application. This handles
        // routing, the theme of the app, and what screen the app should
        // initially show
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

/// HomePage
/// This is the main page of the app
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

/// This is the state class for the home page
/// This will keep track of the app theme and allow the user to change from
/// dark mode to light mode
class _HomePageState extends State<HomePage> {
  // The theme of the app. True is dark mode and false is light mode
  static bool _color = true;

  // This method adds a post frame callback to ensure that we render the widget
  // before trying to set the color
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
    // This Scaffold is pretty standard. It will be used all througout the app
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
