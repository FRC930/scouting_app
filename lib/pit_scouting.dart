import 'package:bearscouts/custom_widgets.dart';
import 'package:bearscouts/database.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:bearscouts/themefile.dart';
import 'package:flutter/material.dart';

class PitScouter extends StatefulWidget {
  const PitScouter({Key? key}) : super(key: key);

  @override
  _PitScouterState createState() => _PitScouterState();
}

class _PitScouterState extends State<PitScouter> {
  int _currentIndex = 0;
  List<String> pageNames = [];
  int team = -1;

  @override
  void initState() {
    super.initState();

    DBManager.instance.getPitPages().then((pages) {
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
                title: const Text('Pit Scouting'),
                actions: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text(
                            "This will FOREVER lose all data entered during "
                            "this session. Only do this if you are CERTAIN that "
                            "you do not need this data.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                DBManager.instance.clearPitData();

                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/pit_scouting");
                              },
                              child: const Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No"),
                            )
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      if (!validFields.containsValue(false)) {
                        DBManager.instance.writePitData();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Fields Written'),
                            content: const Text(
                                'All fields have been written. Clearing current pit data.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  DBManager.instance.clearPitData();
                                  Navigator.of(context).popUntil(
                                    (route) => route.isFirst,
                                  );
                                  Navigator.of(context).pushNamed(
                                    "/pit_scouting",
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
              body: Container(
                decoration: backgroundDecoration,
                child: IndexedStack(
                  index: _currentIndex,
                  children: pageNames.map((e) {
                    return PitScoutWidget(e);
                  }).toList(),
                ),
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
            return const Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 30,
                height: 30,
              ),
            );
          }
        },
        future: DBManager.instance.getPitPages());
  }
}

class PitScoutWidget extends StatefulWidget {
  final String pageName;

  const PitScoutWidget(this.pageName, {Key? key}) : super(key: key);

  @override
  _PitScoutWidgetState createState() => _PitScoutWidgetState();
}

class _PitScoutWidgetState extends State<PitScoutWidget> {
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
                      false,
                    );
                  } else {
                    return const Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        width: 30,
                        height: 30,
                      ),
                    );
                  }
                },
                future: DBManager.instance.getPitDatapointConfig(
                  pageSnapshot.data![index],
                ),
              );
            },
          );
        } else {
          return const Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              width: 30,
              height: 30,
            ),
          );
        }
      },
      future: DBManager.instance.getPitPageWidgets(widget.pageName),
    );
  }
}
