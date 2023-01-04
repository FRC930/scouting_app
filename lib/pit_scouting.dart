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

/// This is the class that manages showing the user the different pages
/// and datapoints in the pit scouting section
class _PitScouterState extends State<PitScouter> {
  // This is the index of the page we are showing
  int _currentIndex = 0;
  List<String> pageNames = [];
  // We store the team so that we can easily reference it later
  int team = -1;

  @override
  Widget build(BuildContext context) {
    // Future builder to get the pit pages from the database
    return FutureBuilder(
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          // Check to see if the database has give us the info yet
          if (snapshot.hasData) {
            // Get the important data from the snapshot
            pageNames = snapshot.data ?? [];
            return Scaffold(
              drawer: const NavDrawer(),
              appBar: AppBar(
                title: const Text('Pit Scouting'),
                actions: [
                  // Clear fields button
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
                              // They've clicked yes. Erase the data.
                              onPressed: () {
                                DBManager.instance.clearPitData();

                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/pit_scouting");
                              },
                              child: const Text("Yes"),
                            ),
                            TextButton(
                              // Mistakes have been made, abort.
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
                      // Make sure that all the fields are filled out properly
                      if (!validFields.containsValue(false)) {
                        // Write the data to the database
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
                                  // Clear match data and reload the page
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
                        // They've not filled out all the fields, give them a
                        // talking to and prevent saving
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
              // a page using the name we got before
              body: Container(
                decoration: backgroundDecoration,
                child: IndexedStack(
                  index: _currentIndex,
                  children: pageNames.map((e) {
                    return PitScoutWidget(e);
                  }).toList(),
                ),
              ),
              // Bottom navigation bar. This allows the user to switch between
              // pages
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
        // The future to get the list of pit pages.
        future: DBManager.instance.getPitPages());
  }
}

class PitScoutWidget extends StatefulWidget {
  final String pageName;

  const PitScoutWidget(this.pageName, {Key? key}) : super(key: key);

  @override
  _PitScoutWidgetState createState() => _PitScoutWidgetState();
}

/// This is the class that tells the data widget what to render
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
                    // Get a new data widget that will write to the pit database
                    return BearScoutsDataWidget(
                      widgetSnapshot.data!,
                      false,
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
      // Get the widgets on the current page
      future: DBManager.instance.getPitPageWidgets(widget.pageName),
    );
  }
}
