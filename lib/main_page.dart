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
    MatchViewer(),
  ];
  static const List<String> _pageNames = <String>[
    '930 Scouting App',
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
