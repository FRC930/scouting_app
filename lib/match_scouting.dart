import 'package:bearscouts/nav_drawer.dart';
import 'package:flutter/material.dart';
import 'package:bearscouts/custom_widgets.dart';
import 'package:bearscouts/database.dart';

class MatchScouter extends StatefulWidget {
  const MatchScouter({Key? key}) : super(key: key);

  @override
  _MatchScouterState createState() => _MatchScouterState();
}

class _MatchScouterState extends State<MatchScouter> {
  int _currentIndex = 0;
  List<String> pageNames = [];

  @override
  void initState() {
    super.initState();

    DBManager.instance.getMatchPages().then((pages) {
      setState(() {
        pageNames = pages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            pageNames = snapshot.data ?? [];
            return Scaffold(
              drawer: const NavDrawer(),
              appBar: AppBar(
                title: const Text('Match Scouting'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      if (!validFields.containsValue(false)) {
                        DBManager.instance.writeMatchData();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Fields Written'),
                            content: const Text(
                                'All fields have been written. Clearing current match data.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  DBManager.instance.clearMatchData();
                                  Navigator.of(context).popUntil(
                                    (route) => route.isFirst,
                                  );
                                  Navigator.of(context).pushNamed(
                                    "/match_scouting",
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Invalid Fields'),
                            content: Text(
                              'Please fill out all fields.\n\n'
                                      'The fields that are missing are: \n' +
                                  validFields.entries
                                      .where(
                                        (entry) => entry.value == false,
                                      )
                                      .map<String>((e) => e.key)
                                      .join('\n'),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              body: IndexedStack(
                index: _currentIndex,
                children: pageNames.map((e) {
                  return MatchScoutWidget(e);
                }).toList(),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: pageNames.map((e) {
                  return BottomNavigationBarItem(
                    label: e,
                    icon: const Icon(Icons.category),
                  );
                }).toList(),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
        future: DBManager.instance.getMatchPages());
  }
}

class MatchScoutWidget extends StatefulWidget {
  final String pageName;

  const MatchScoutWidget(this.pageName, {Key? key}) : super(key: key);

  @override
  _MatchScoutWidgetState createState() => _MatchScoutWidgetState();
}

class _MatchScoutWidgetState extends State<MatchScoutWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> pageSnapshot) {
        if (pageSnapshot.hasData) {
          return ListView.builder(
            controller: ScrollController(),
            itemCount: pageSnapshot.data!.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> widgetSnapshot) {
                  if (widgetSnapshot.hasData) {
                    return BearScoutsDataWidget(
                      widgetSnapshot.data!,
                      true,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
                future: DBManager.instance.getMatchDatapointConfig(
                  pageSnapshot.data![index],
                ),
              );
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
      future: DBManager.instance.getMatchPageWidgets(widget.pageName),
    );
  }
}