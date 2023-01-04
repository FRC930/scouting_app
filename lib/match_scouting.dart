import 'package:bearscouts/custom_widgets.dart';
import 'package:bearscouts/database.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:bearscouts/themefile.dart';
import 'package:flutter/material.dart';

class MatchScouter extends StatefulWidget {
  const MatchScouter({Key? key}) : super(key: key);

  @override
  _MatchScouterState createState() => _MatchScouterState();
}

// This is the class that manages showing the user the different pages and
// datapoints in the match scouting section.
class _MatchScouterState extends State<MatchScouter> {
  // This is the index of the page we are showing
  int _currentIndex = 0;
  List<String> pageNames = [];

  @override
  Widget build(BuildContext context) {
    // Future builder to get the match pages from database
    return FutureBuilder(
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          // Check to see if we are ready
          if (snapshot.hasData) {
            // Get the data from the snapshot
            pageNames = snapshot.data ?? [];
            return Scaffold(
              drawer: const NavDrawer(),
              appBar: AppBar(
                title: const Text('Match Scouting'),
                actions: [
                  // Clear fields button
                  IconButton(
                    onPressed: () {
                      // Make sure that the user knows exactly what they are 
                      // doing by pressing this button
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text(
                            "This will FOREVER lose all data entered during "
                            "this match. Only do this if you are CERTAIN that "
                            "you do not need this data.",
                          ),
                          actions: [
                            TextButton(
                              // They've clicked yes. Erase the data.
                              onPressed: () {
                                DBManager.instance.clearMatchData();

                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/match_scouting");
                              },
                              child: const Text("Yes"),
                            ),
                            TextButton(
                              // They realize that they made a mistake, abort
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
                  // Save icon
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      // Make sure that all the fields are filled out
                      if (!validFields.containsValue(false)) {
                        // Write in-memory data to database
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
                                  // Clear the match data and reload the page
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
                        // They've not filled out all the required fields, yell at them
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
              // The main body. Everything here is pretty simple. We just return
              // a page using the name we got before.
              body: Container(
                decoration: backgroundDecoration,
                child: IndexedStack(
                  index: _currentIndex,
                  children: pageNames.map((e) {
                    return MatchScoutWidget(e);
                  }).toList(),
                ),
              ),
              // Bottom navigation bar. This allows the user to switch freely
              // between pages.
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
            // Loading indicator
            return const Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 30,
                height: 30,
              ),
            );
          }
        },
        // The future to get the match pages.
        future: DBManager.instance.getMatchPages());
  }
}

class MatchScoutWidget extends StatefulWidget {
  final String pageName;

  const MatchScoutWidget(this.pageName, {Key? key}) : super(key: key);

  @override
  _MatchScoutWidgetState createState() => _MatchScoutWidgetState();
}

/// This is the class that tells the data widget what to render
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
                    // Get a new data widget with match set to true
                    return BearScoutsDataWidget(
                      widgetSnapshot.data!,
                      true,
                    );
                  } else {
                    // Loading indicator
                    return const Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        width: 30,
                        height: 30,
                      ),
                    );
                  }
                },
                // The future to get the datapoint config from the database
                future: DBManager.instance.getMatchDatapointConfig(
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
      // Get the widgets on the current page
      future: DBManager.instance.getMatchPageWidgets(widget.pageName),
    );
  }
}
