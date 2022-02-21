import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scouting_app3/datafarmer.dart';
import 'package:scouting_app3/themefile.dart';

import 'handlers.dart';
import 'matchviewer.dart';

void main() {
  runApp(const MainApp());
}

/// Main app class
///
/// This is the class that will start the app and set the theme
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pre-fetch the configuration data
    ConfigHandler.getData();
    return MaterialApp(
      title: "930 Scouting App",
      // Only affects debug mode
      debugShowCheckedModeBanner: false,
      // Set the home page for the app
      home: const HomePage(),
      // Set up the theme found in the themefile
      theme: mainThemeData,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar to display page title and the back button
      appBar: AppBar(
        title: Text(
          "930 Scouting App",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      // Use container to add the logo to the background
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.bottomCenter,
            image: AssetImage(
              "assets/logo.png",
              bundle: rootBundle,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ElevatedButton(
                  child: Text(
                    "New Match",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreMatchData(),
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: Text(
                    "View Data",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MatchDataViewer(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchDataViewer extends StatelessWidget {
  const MatchDataViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MatchViewHandler.readMatchFiles();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Data Viewer",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: const MatchViewElement(),
    );
  }
}

class PreMatchData extends StatelessWidget {
  final MatchPageData preMatchData =
      const MatchPageData("pre-match", AutonData());

  const PreMatchData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pre-Match Data",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: preMatchData,
    );
  }
}

class AutonData extends StatelessWidget {
  final MatchPageData autonData = const MatchPageData("auton", TeleopData());

  const AutonData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Auton Data",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image(
              image: AssetImage("assets/Tarmac.png", bundle: rootBundle),
              height: 200,
            ),
          ),
          Expanded(
            child: autonData,
          ),
        ],
      ),
    );
  }
}

class TeleopData extends StatelessWidget {
  final MatchPageData autonData = const MatchPageData("teleop", EndgameData());

  const TeleopData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Teleop Data",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: autonData,
    );
  }
}

class EndgameData extends StatelessWidget {
  final MatchPageData autonData =
      const MatchPageData("endgame", PostMatchData());

  const EndgameData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Endgame Data",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: autonData,
    );
  }
}

class PostMatchData extends StatelessWidget {
  final MatchPageData autonData =
      const MatchPageData("post-match", SaveDataPage());

  const PostMatchData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post-Match Data",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: autonData,
    );
  }
}

class SaveDataPage extends StatelessWidget {
  const SaveDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Save Data",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              child: Text(
                "Save data",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                MatchHandler.writeMatchData();
                MatchHandler.clearData();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
