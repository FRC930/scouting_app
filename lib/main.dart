import 'package:flutter/material.dart';
import 'package:bearscouts/color_schemes.dart';
import 'package:bearscouts/data_manager.dart';
import 'package:bearscouts/loading_screen.dart';
import 'package:bearscouts/main_page.dart';
import 'package:bearscouts/settings.dart';

void main() {
  runApp(const MainApp());

  MatchDataManager.readData();
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
      routes: {
        '/': (context) => const MainPage(),
        '/loading': (context) => const LoadingScreen(),
        '/match_scouter': (context) => const MainPage(initialIndex: 1),
        '/match_viewer': (context) => const MainPage(initialIndex: 2),
        '/settings': (context) => const ConfigSettingsPage(),
        '/settings/app': (context) => const AppSettingsPage(),
        '/settings/auth': (context) => const SettingsAuthPage(),
        '/settings/import_export': (context) => const ImportExportPage(),
      },
      initialRoute: "/loading",
      debugShowCheckedModeBanner: false,
    );
  }
}
