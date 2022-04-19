import 'package:bearscouts/pit_scouter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bearscouts/home_page.dart';
import 'package:bearscouts/match_scouter.dart';
import 'package:bearscouts/match_viewer.dart';
import 'package:bearscouts/nav_drawer.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const List<Widget> _pages = <Widget>[
    HomePageWidget(),
    MatchScouter(),
    FileViewer(),
  ];
  static const List<String> _pageNames = <String>[
    '930 Match Scouting App',
    'Match Scouter',
    'Match Viewer',
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(_pageNames.elementAt(_selectedIndex))),
      ),
      drawer: const NavDrawer(),
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
        child: IndexedStack(children: _pages, index: _selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 36),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 36),
            label: "Match Scout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review, size: 36),
            label: "Match View",
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class PitScoutingMainPage extends StatefulWidget {
  final int initialIndex;

  const PitScoutingMainPage({Key? key, this.initialIndex = 0})
      : super(key: key);

  @override
  _PitScoutingMainPageState createState() => _PitScoutingMainPageState();
}

class _PitScoutingMainPageState extends State<PitScoutingMainPage> {
  static const List<Widget> _pages = <Widget>[
    HomePageWidget(),
    PitScouter(),
    FileViewer(viewerType: "pit"),
  ];
  static const List<String> _pageNames = <String>[
    '930 Pit Scouting App',
    'Pit Scouter',
    'Pit Data Viewer',
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(_pageNames.elementAt(_selectedIndex))),
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
        child: IndexedStack(children: _pages, index: _selectedIndex),
      ),
      drawer: const NavDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 36),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 36),
            label: "Pit Scout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review, size: 36),
            label: "Pit Data View",
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
