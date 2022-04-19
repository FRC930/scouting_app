import 'package:bearscouts/storage_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bearscouts/color_schemes.dart';
import 'package:bearscouts/loading_screen.dart';
import 'package:bearscouts/main_page.dart';
import 'package:bearscouts/settings.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MainApp());

  Storage().readConfigFromLocalStorage();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '930 Scouting App',
      theme: ThemeData(
        colorScheme: darkColorScheme,
        textTheme: appTextTheme,
        appBarTheme: darkAppBarTheme,
        bottomNavigationBarTheme: darkNavigationBarTheme,
      ),
      onGenerateRoute: (settings) {
        Widget Function(BuildContext) builder;

        switch (settings.name) {
          case '/':
            builder = (context) => const MainPage();
            break;
          case '/loading':
            builder = (context) => const LoadingScreen();
            break;
          case '/match_scouter':
            builder = (context) => const MainPage(initialIndex: 1);
            break;
          case '/match_viewer':
            builder = (context) => const MainPage(initialIndex: 2);
            break;
          case '/settings':
            builder = (context) => const ConfigSettingsPage();
            break;
          case '/settings/app':
            builder = (context) => const AppSettingsPage();
            break;
          case '/settings/pit':
            builder = (context) => const ConfigSettingsPage(type: "pit");
            break;
          case '/settings/auth':
            builder = (context) => const SettingsAuthPage();
            break;
          case '/settings/import_export':
            builder = (context) => const ImportExportPage();
            break;
          case '/pit_scout':
            builder = (context) => const PitScoutingMainPage();
            break;
          case '/pit_scout/data_record':
            builder = (context) => const PitScoutingMainPage(initialIndex: 1);
            break;
          case '/pit_scout/data_view':
            builder = (context) => const PitScoutingMainPage(initialIndex: 2);
            break;
          default:
            builder = (context) => const MainPage();
        }
        return MaterialPageRoute(builder: builder);
      },
      initialRoute: "/loading",
      debugShowCheckedModeBanner: false,
    );
  }
}
