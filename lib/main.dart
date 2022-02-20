import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scouting_app3/datafarmer.dart';
import 'package:scouting_app3/themefile.dart';

import 'handlers.dart';
import 'matchviewer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigHandler.getData();
    return const MaterialApp(
      title: "930 Scouting App",
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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
      appBar: AppBar(
        title: Text(
          "930 Scouting App",
          style: TextHandler.headerText,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: mainThemeData.backgroundColor,
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
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFF1D57A5),
                  ),
                  child: Text(
                    "New Match",
                    style: TextHandler.buttonText,
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
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFF1D57A5),
                  ),
                  child: Text("View Data", style: TextHandler.buttonText),
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
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        title: Text(
          "Data Viewer",
          style: TextHandler.headerText,
        ),
      ),
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
        child: const MatchViewElement(),
      ),
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
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        title: Text(
          "Pre-Match Data",
          style: TextHandler.headerText,
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
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        title: Text(
          "Auton Data",
          style: TextHandler.headerText,
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
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        title: Text(
          "Teleop Data",
          style: TextHandler.headerText,
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
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        title: Text(
          "Endgame Data",
          style: TextHandler.headerText,
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
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        title: Text(
          "Post-Match Data",
          style: TextHandler.headerText,
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
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        title: Text(
          "Save Data",
          style: TextHandler.headerText,
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
                style: TextHandler.buttonText,
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
