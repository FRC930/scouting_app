import 'dart:convert';
import 'dart:io';

import 'package:bearscouts/custom_widgets.dart';
import 'package:bearscouts/database.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:bearscouts/themefile.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsAuthPage extends StatefulWidget {
  const SettingsAuthPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsAuthPageState();
}

class _SettingsAuthPageState extends State<SettingsAuthPage> {
  static const String _passwordHash =
      "a327bee904ca10725aed4ddb19b4e1161c6f97d281e36bb23439d837a3c7cd3e";
  final TextEditingController _passwordController = TextEditingController();
  bool authenticated = false;

  // This will tell the app to warn the user the next time they enter into the
  // settings editing area.
  @override
  void dispose() {
    super.dispose();

    _MatchSettingsPageState.isOkWithDelete = false;
    _PitSettingsPageState.isOkWithDelete = false;
  }

  // This build function has two basic functions. It handles authentication on
  // the first page, and then when it is authenticated, it reloads with the
  // admin portal unlocked
  @override
  Widget build(BuildContext context) {
    // Check to see if we are authenticated
    if (!authenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Login'),
        ),
        drawer: const NavDrawer(),
        body: Container(
          decoration: backgroundDecoration,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                children: <Widget>[
                  // The password entry field
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                    controller: _passwordController,
                  ),
                  // Password check button
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Hash the password entry
                        var bytes = utf8.encode(_passwordController.text);
                        var digest = sha256.convert(bytes);

                        // Check if the hashes match
                        if (_passwordHash.toLowerCase() ==
                            digest.toString().toLowerCase()) {
                          // Hashes match, congrats you're in
                          setState(() {
                            authenticated = true;
                          });
                        } else {
                          // Password is wrong, yell at them
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Password Incorrect"),
                                  content: const Text(
                                    "The password you entered is incorrect. "
                                    "Please try again.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("OK"),
                                    )
                                  ],
                                );
                              });
                        }

                        _passwordController.clear();
                      },
                      child: const Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // We're already authenticated, just display the admin panel
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
        ),
        drawer: const NavDrawer(),
        body: Container(
          decoration: backgroundDecoration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: ListView(
              children: [
                // Match data config button
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ListTile(
                      title: Text(
                        "Edit Match Data Configuration",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      iconColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      onTap: () =>
                          Navigator.pushNamed(context, "/settings/match_data"),
                      subtitle: const Text(
                        "Edit match data properties and configuration",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                // Pit data config button
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ListTile(
                      title: Text(
                        "Edit Pit Data Configuration",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      iconColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      onTap: () =>
                          Navigator.pushNamed(context, "/settings/pit_data"),
                      subtitle: const Text(
                        "Edit pit data properties and configuration",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                // App settings button
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ListTile(
                      title: Text(
                        "Edit App Settings",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      iconColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      onTap: () => Navigator.pushNamed(
                        context,
                        "/settings/app_config",
                      ),
                      subtitle: const Text(
                        "Edit app settings (tablet name)",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                // App templates button
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ListTile(
                      title: Text(
                        "Manage App Templates",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      iconColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      onTap: () => Navigator.pushNamed(
                          context, "/settings/data_management"),
                      subtitle: const Text(
                        "Export, import and restore data",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class MatchSettingsPage extends StatefulWidget {
  final ScrollController _scrollController = ScrollController();
  final double scrollToOffset;

  MatchSettingsPage({this.scrollToOffset = 0, Key? key}) : super(key: key);

  @override
  _MatchSettingsPageState createState() => _MatchSettingsPageState();
}

/// This is the page that acts as the google form editor for match pages
class _MatchSettingsPageState extends State<MatchSettingsPage> {
  static bool isOkWithDelete = false;

  // This will jump the scroll controller to the correct spot on the page
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      widget._scrollController.jumpTo(widget.scrollToOffset);
    });
  }

  // Once we dispose this view, create the data tables from the config tables
  @override
  void dispose() {
    super.dispose();

    if (isOkWithDelete) {
      DBManager.instance.createDataTables();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make sure that the user knows the consequences of continuing
    if (isOkWithDelete) {
      // The user supposably has read all the warnings and is fine with deleting
      // all their previous data
      return Scaffold(
        appBar: AppBar(
          title: const Text('Match Settings'),
          actions: [
            // Refresh button
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchSettingsPage(
                        scrollToOffset: widget._scrollController.offset),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Container(
          decoration: backgroundDecoration,
          child: FutureBuilder(
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    // Match page editor
                    FutureBuilder(
                      builder: (BuildContext context,
                          AsyncSnapshot<SharedPreferences> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.getString("matchPages") == null) {
                            DBManager.instance
                                .getMatchPages()
                                .then((List<String> pages) {
                              snapshot.data!
                                  .setString("matchPages", pages.join(","));

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MatchSettingsPage(
                                      scrollToOffset:
                                          widget._scrollController.offset),
                                ),
                              );
                            });
                          }
                          // This is the text field that will allow the user to
                          // edit what pages they want to appear.
                          return BearScoutsTextField(
                            const [
                              "Match Pages",
                              "",
                              "",
                              "text",
                              "Please enter a valid list of match pages separated by commas",
                            ],
                            (bool isValid, String value) {
                              snapshot.data!.setString("matchPages", value);
                            },
                            snapshot.data!.getString("matchPages") ?? "",
                          );
                        } else {
                          // Loading indicator
                          return const Center(
                            child: Padding(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                width: 30,
                                height: 30,
                              ),
                              padding: EdgeInsets.only(top: 10),
                            ),
                          );
                        }
                      },
                      future: SharedPreferences.getInstance(),
                    ),
                    // This is the list of editors. It is constructed from the
                    // data that we got from the config database.
                    Expanded(
                      child: ListView.builder(
                        controller: widget._scrollController,
                        itemBuilder: (context, index) {
                          return DatapointSettingsWidget(
                            snapshot.data![index],
                            true,
                            controller: widget._scrollController,
                          );
                        },
                        itemCount: snapshot.data!.length,
                      ),
                    ),
                  ],
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
            future: DBManager.instance.getMatchConfig(),
          ),
        ),
      );
    } else {
      // They haven't agreed to delete all their data yet
      return Scaffold(
        appBar: AppBar(
          title: const Text('Match Settings'),
        ),
        body: Container(
          decoration: backgroundDecoration,
          child: ListView(
            controller: widget._scrollController,
            children: <Widget>[
              // Warning text below here. Formatting is pretty simple
              const Center(
                child: Text(
                  "WARNING",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 40,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Potential data loss ahead",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 30,
                  ),
                ),
              ),
              const Center(
                child: Padding(
                    child: Text(
                      "Entering the editing page will erase any previously "
                      "saved match and pit data. Ensure that you either have a "
                      "backup or do not and will not need this data at any "
                      "point in the future. This decision is final and cannot "
                      "be reversed.",
                      textAlign: TextAlign.center,
                    ),
                    padding: EdgeInsets.all(5)),
              ),
              Padding(
                // The "I understand" button
                child: ElevatedButton(
                  onPressed: () {
                    // Once they say that they understand, make doubly sure
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("One more time"),
                        content: const Text(
                            "Are you ABSOLUTELY sure that you don't need this data?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                isOkWithDelete = true;
                              });
                            },
                            child: const Text("Yes, delete my data"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No, keep my data"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("I understand"),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 30,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// The pit settings page is literally functionally identical to the pit settings
// page. Look up there for documentation about the methods and stuff in the
// classes.
class PitSettingsPage extends StatefulWidget {
  final ScrollController _scrollController = ScrollController();
  final double scrollToOffset;

  PitSettingsPage({this.scrollToOffset = 0, Key? key}) : super(key: key);

  @override
  _PitSettingsPageState createState() => _PitSettingsPageState();
}

class _PitSettingsPageState extends State<PitSettingsPage> {
  static bool isOkWithDelete = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      widget._scrollController.jumpTo(widget.scrollToOffset);
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (isOkWithDelete) {
      DBManager.instance.createDataTables();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isOkWithDelete) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pit Settings'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PitSettingsPage(
                        scrollToOffset: widget._scrollController.offset),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Container(
          decoration: backgroundDecoration,
          child: FutureBuilder(
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    FutureBuilder(
                        builder: (BuildContext context,
                            AsyncSnapshot<SharedPreferences> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.getString("pitPages") == null) {
                              DBManager.instance
                                  .getPitPages()
                                  .then((List<String> pages) {
                                snapshot.data!
                                    .setString("pitPages", pages.join(","));

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PitSettingsPage(
                                        scrollToOffset:
                                            widget._scrollController.offset),
                                  ),
                                );
                              });
                            }
                            return BearScoutsTextField(
                              const [
                                "Pit Pages",
                                "",
                                "",
                                "text",
                                "Please enter a valid list of pit pages separated by commas",
                              ],
                              (bool isValid, String value) {
                                snapshot.data!.setString("pitPages", value);
                              },
                              snapshot.data!.getString("pitPages") ?? "",
                            );
                          } else {
                            return const Center(
                              child: Padding(
                                child: SizedBox(
                                  child: CircularProgressIndicator(),
                                  width: 30,
                                  height: 30,
                                ),
                                padding: EdgeInsets.only(top: 10),
                              ),
                            );
                          }
                        },
                        future: SharedPreferences.getInstance()),
                    Expanded(
                      child: ListView.builder(
                        controller: widget._scrollController,
                        itemBuilder: (context, index) {
                          return DatapointSettingsWidget(
                            snapshot.data![index],
                            false,
                            controller: widget._scrollController,
                          );
                        },
                        itemCount: snapshot.data!.length,
                      ),
                    ),
                  ],
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
            future: DBManager.instance.getPitConfig(),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pit Settings'),
        ),
        body: Container(
          decoration: backgroundDecoration,
          child: ListView(
            controller: widget._scrollController,
            children: <Widget>[
              const Center(
                child: Text(
                  "WARNING",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 40,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Potential data loss ahead",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 30,
                  ),
                ),
              ),
              const Center(
                child: Padding(
                    child: Text(
                      "Entering the editing page will erase any previously "
                      "saved match and pit data. Ensure that you either have a "
                      "backup or do not and will not need this data at any "
                      "point in the future. This decision is final and cannot "
                      "be reversed.",
                      textAlign: TextAlign.center,
                    ),
                    padding: EdgeInsets.all(5)),
              ),
              Padding(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("One more time"),
                        content: const Text(
                            "Are you ABSOLUTELY sure that you don't need this data?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  isOkWithDelete = true;
                                });
                              },
                              child: const Text("Yes, delete my data"))
                        ],
                      ),
                    );
                  },
                  child: const Text("I understand"),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 30,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// This allows the user to change some things about the app configuration
class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({Key? key}) : super(key: key);

  @override
  _AppSettingsPageState createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: Container(
        decoration: backgroundDecoration,
        child: FutureBuilder(
          builder: (BuildContext context,
              AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  // Tablet name editor. This shows up on the home page
                  BearScoutsTextField(
                    const [
                      "Tablet Name",
                      "",
                      "",
                      "text",
                      "Please enter a valid tablet name",
                    ],
                    (bool isValid, String value) {
                      snapshot.data!.setString("tabletName", value);
                    },
                    snapshot.data!.getString("tabletName") ?? "",
                  ),
                  // Tablet color editor. This changes the text on the home
                  // screen and also the color of the app bar.
                  BearScoutsMultipleChoice(
                    const [
                      "Tablet Color",
                      "",
                      "",
                      "blue,red",
                      "Blue,Red",
                    ],
                    (bool valid, String value) {
                      snapshot.data!.setString("tabletColor", value);
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        if (value.toLowerCase().contains("red")) {
                          DBManager.instance.colorNotifier.value =
                              ColorChangeNotifier(
                            darkAppBarTheme.copyWith(
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          DBManager.instance.colorNotifier.value =
                              ColorChangeNotifier(
                            darkAppBarTheme.copyWith(
                              backgroundColor: darkColorScheme.onSecondary,
                            ),
                          );
                        }
                      });
                    },
                    snapshot.data!.getString("tabletColor") ?? "blue",
                  ),
                ],
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
          future: SharedPreferences.getInstance(),
        ),
      ),
    );
  }
}

// These are the settings for each individual datapoint
class DatapointSettingsWidget extends StatefulWidget {
  final Map<String, Object?> pointValues;
  final bool isMatch;
  final ScrollController? controller;

  const DatapointSettingsWidget(this.pointValues, this.isMatch,
      {this.controller, Key? key})
      : super(key: key);

  @override
  _DatapointSettingsWidgetState createState() =>
      _DatapointSettingsWidgetState();
}

class _DatapointSettingsWidgetState extends State<DatapointSettingsWidget> {
  // Store the shared preferences so we don't have to get them repeatedly
  static SharedPreferences? prefs;
  // If the datapoint hasn't changed since last time, we can just render the
  // editor as it was last time
  String _lastDataType = "";

  // This will set the special value. This is reused from datapoint to datapoint
  void setSpecial1(bool isValid, String value) {
    // Update in the correct database
    if (widget.isMatch) {
      DBManager.instance.updateMatchConfigDatapoint(
        widget.pointValues["export"] as int,
        "special1",
        value,
      );
    } else {
      DBManager.instance.updatePitConfigDatapoint(
        widget.pointValues["export"] as int,
        "special1",
        value,
      );
    }
  }

  // Same story here. Update special 2 in all the different datapoints
  void setSpecial2(bool isValid, String value) {
    // Ensure that we are updating the correct point value
    if (widget.isMatch) {
      DBManager.instance.updateMatchConfigDatapoint(
        widget.pointValues["export"] as int,
        "special2",
        value,
      );
    } else {
      DBManager.instance.updatePitConfigDatapoint(
        widget.pointValues["export"] as int,
        "special2",
        value,
      );
    }
  }

  // This returns an editor for all of the settings common to all datapoints
  Future<List<Widget>> _getCommonSettings() async {
    // Get the preferences if we haven't already
    prefs ??= await SharedPreferences.getInstance();
    // Get the page order from shared preferences
    String pages = prefs?.getString(
          widget.isMatch ? "matchPages" : "pitPages",
        ) ??
        "";

    // Return the list of widgets for editing the common settings
    return <Widget>[
      // Title editing field
      // We just use a custom text field so we don't have to make any
      // formatting changes and it looks nice from the start.
      BearScoutsTextField(
        const ["Title", "", "", "text", "Enter a valid value"],
        // Called whenever the text changes in the field
        (bool isValid, String value) {
          // Make sure we are writing to the proper database
          if (widget.isMatch) {
            DBManager.instance.updateMatchConfigDatapoint(
              widget.pointValues["export"] as int,
              "title",
              value,
            );
          } else {
            DBManager.instance.updatePitConfigDatapoint(
              widget.pointValues["export"] as int,
              "title",
              value,
            );
          }
        },
        // This is the initial value of the text field
        widget.pointValues["title"].toString(),
        // Make sure that the user can't be stupid and remove match number
        // and team number from the list of widgets
        editable: widget.pointValues["title"] != "Team Number" &&
            widget.pointValues["title"] != "Match Number",
      ),
      // The data type editor. This is a multiple choice so that the user
      // can't enter a wrong data type
      BearScoutsMultipleChoice(
        const [
          "Data type",
          "",
          "",
          "choice,counter,field,stopwatch,"
              "image,heading,slider,toggle,heatmap",
          "Multiple choice,Counter,Field,Stopwatch,"
              "Image,Heading,Slider,Toggle,Heatmap"
        ],
        // This is called whenever the user changes the data type
        (bool isValid, String value) async {
          if (widget.isMatch) {
            // Update the database
            await DBManager.instance.updateMatchConfigDatapoint(
              widget.pointValues["export"] as int,
              "type",
              value,
            );

            // Reload the page to reflect the changes in data type
            Future.delayed(
              const Duration(milliseconds: 25),
              () {
                if (_lastDataType != value) {
                  _lastDataType = value;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      // Scroll the page to the offset that we're currently at
                      builder: (context) => MatchSettingsPage(
                          scrollToOffset: widget.controller?.offset ?? 0.0),
                    ),
                  );
                }
              },
            );
          } else {
            // Write to the database
            await DBManager.instance.updatePitConfigDatapoint(
              widget.pointValues["export"] as int,
              "type",
              value,
            );

            // Same thing as before, reload the page
            Future.delayed(
              const Duration(milliseconds: 25),
              () {
                if (_lastDataType != value) {
                  _lastDataType = value;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PitSettingsPage(
                          scrollToOffset: widget.controller?.offset ?? 0.0),
                    ),
                  );
                }
              },
            );
          }
        },
        // Initial value for the multiple choice box
        widget.pointValues["type"].toString(),
      ),
      // This is the page selector. There is a limited number of pages that we
      // can have so we use a multiple choice
      BearScoutsMultipleChoice(
        [
          "Page",
          "",
          "",
          pages,
          pages,
        ],
        (bool isValid, String value) {
          // Ensure we're using the correct database
          // There is no need to reload the page here
          if (widget.isMatch) {
            DBManager.instance.updateMatchConfigDatapoint(
              widget.pointValues["export"] as int,
              "page",
              value,
            );
          } else {
            DBManager.instance.updatePitConfigDatapoint(
              widget.pointValues["export"] as int,
              "page",
              value,
            );
          }
        },
        widget.pointValues["page"].toString(),
      ),
    ];
  }

  // These are the settings that are specific to a field
  Future<List<Widget>> _getFieldSettings() async {
    // Start off with the common settings
    List<Widget> settings = await _getCommonSettings();
    // Add a validation multiple choice box
    settings.add(
      BearScoutsMultipleChoice(
        const <String>[
          "Validation",
          "",
          "",
          "integer,deciaml,text",
          "Integer,Decimal,Text",
        ],
        // Use our helper function here
        setSpecial1,
        widget.pointValues["special1"].toString(),
      ),
    );
    // Add the error message to the editor
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Validation Error Message",
          "",
          "",
          "text",
          "Enter the text to display when user input is incorrect",
        ],
        // Again use our helper function
        setSpecial2,
        widget.pointValues["special2"].toString(),
      ),
    );

    // Return the list of all the different widgets
    return settings;
  }

  // The list of widgets to edit a multiple choice field
  Future<List<Widget>> _getMultipleChoiceSettings() async {
    // Get the common settings
    List<Widget> settings = await _getCommonSettings();
    // Add the outputs field. These are the values that are actually written
    // to the database
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Outputs",
          "",
          "",
          "text",
          "Enter a valid list of choice outputs, separated by commas"
        ],
        setSpecial1,
        widget.pointValues["special1"].toString(),
      ),
    );
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Scouter Choices",
          "",
          "",
          "text",
          "Enter a valid list of displayable items, separated by commas"
        ],
        setSpecial2,
        widget.pointValues["special2"].toString(),
      ),
    );

    return settings;
  }

  // This returns the settings for an image widget
  Future<List<Widget>> _getImageSettings() async {
    // Get the common settings
    List<Widget> settings = await _getCommonSettings();

    // Add the image picker
    settings.add(
      ElevatedButton(
        onPressed: () async {
          // Get a file from the user
          FilePickerResult? imageFile =
              await FilePicker.platform.pickFiles(type: FileType.image);

          // Make sure that the user has only picked one file and that they
          // haven't cancelled the picking process
          if (imageFile != null && imageFile.isSinglePick) {
            // Get a file pointer to the image path
            File externalImageFile = File(imageFile.files.single.path!);

            // We're going to copy the image into a program-referenceable
            // directory, so we need to get that new path
            String newFilePath = "";
            if (!Platform.isWindows) {
              // The platform isn't windows so we can use forward slashes
              newFilePath = (await getApplicationSupportDirectory()).path +
                  "/images/" +
                  externalImageFile.path.split("/").last;
            } else {
              // We're on windows so we need to use back slashes
              newFilePath = (await getApplicationSupportDirectory()).path +
                  "\\images\\" +
                  externalImageFile.path.split("\\").last;
            }

            // Create a file pointer to the new file path
            File newFileLocation = File(newFilePath);
            // Make sure that the file exists, if not, create it and any
            // directories along the way
            if (!await newFileLocation.exists()) {
              await newFileLocation.create(recursive: true);
            }

            // Copy the file from the external path to the internal path
            await externalImageFile.copy(newFilePath);

            setSpecial1(true, newFilePath);
          }
        },
        child: const Text("Select Image"),
      ),
    );

    // Get all of the widgets to edit an image
    return settings;
  }

  // This will get the settings used for a slider
  Future<List<Widget>> _getSliderSettings() async {
    // Get the settings common to all widgets
    List<Widget> settings = await _getCommonSettings();

    // Minimum value for the slider
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Minimum",
          "",
          "",
          "integer",
          "Enter the lowest integer selectable using this field"
        ],
        setSpecial1,
        widget.pointValues["special1"].toString(),
      ),
    );
    // Maximum value for the slider
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Maximum",
          "",
          "",
          "integer",
          "Enter the highest integer selectable using this field"
        ],
        setSpecial2,
        widget.pointValues["special2"].toString(),
      ),
    );

    return settings;
  }

  @override
  void initState() {
    super.initState();

    // Set the last data type so we can make sure to re-render if the data type
    // changes by the multiple choice box
    _lastDataType = widget.pointValues["type"].toString();
  }

  // The build method for the widget editor
  @override
  Widget build(BuildContext context) {
    // Build the list of widgets into this list
    Future<List<Widget>> settings;

    // Start with the defaults for the field type
    switch (widget.pointValues["type"]) {
      case "field":
        settings = _getFieldSettings();
        break;
      case "choice":
        settings = _getMultipleChoiceSettings();
        break;
      case "image":
      case "heatmap":
        settings = _getImageSettings();
        break;
      case "slider":
        settings = _getSliderSettings();
        break;
      case "counter":
      case "stopwatch":
      case "heading":
      case "toggle":
      default:
        settings = _getCommonSettings();
        break;
    }

    // This padding gives the widget editor a more roomy feel
    return Padding(
      padding: const EdgeInsets.all(10),
      // Add a three pixel wide border around the widget editor
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primaryContainer,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: FutureBuilder(
            // Get the actual list of elements using a future
            future: settings,
            builder:
                (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) {
                // We have our data, time to get to work
                List<Widget> finalSettings = snapshot.data!;

                // Add a few things to the widget list
                finalSettings.add(
                  BearScoutsCounter(
                    const [
                      "Export order",
                      "",
                      "counter",
                      "",
                      "",
                    ],
                    // This function is a bit different as we are changing the
                    // export value. Usually the export is what we use to figure
                    // out where to change data. Instead, here we use the title
                    // to figure out which export to change.
                    (bool isValid, String value) {
                      if (widget.isMatch) {
                        DBManager.instance.updateMatchConfigExportAtTitle(
                          widget.pointValues["title"].toString(),
                          int.tryParse(value) ?? -1,
                        );
                      } else {
                        DBManager.instance.updatePitConfigExportAtTitle(
                          widget.pointValues["title"].toString(),
                          int.tryParse(value) ?? -1,
                        );
                      }
                    },
                    widget.pointValues["export"].toString(),
                  ),
                );
                // Add delete, plus, and minus buttons
                finalSettings.add(
                  Row(
                    children: [
                      // Delete button
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            // Make sure that the user is absolutely sure that
                            // they want to delete this
                            builder: (context) => AlertDialog(
                              content: const Text(
                                "Are you sure you want to delete this datapoint?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);

                                    // If the user is trying to delete the team number or match number fields, we
                                    // need to make sure that they know the consequences of their actions.
                                    if (widget.pointValues["title"] ==
                                            "Team Number" ||
                                        widget.pointValues["title"] ==
                                            "Match Number") {
                                      // Show the dialog that will tell them that their app will stop working if
                                      // they choose to delete this field
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Deletion Danger"),
                                          content: const Text(
                                            "Deleting this field may cause the app to stop working. Are you sure?",
                                          ),
                                          actions: [
                                            TextButton(
                                              // They've made a mistake, but they have every right to do that
                                              onPressed: () {
                                                Navigator.pop(context);

                                                _deletePoint();
                                              },
                                              child: const Text(
                                                "Yes",
                                              ),
                                            ),
                                            TextButton(
                                              // They realized that they wanted a functional app so we won't delete
                                              // that datapoint
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "No",
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // This datapoint is not a team number or
                                      // match number, so we can delete after
                                      // one confirmation dialog
                                      _deletePoint();
                                    }
                                  },
                                  child: const Text(
                                    "Yes, delete this datapoint",
                                  ),
                                ),
                                // They actually changed their mind and don't
                                // want to delete that datapoint
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Take me back!"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                        ),
                      ),
                      // This is the button to add a widget before the current one
                      IconButton(
                        onPressed: () {
                          if (widget.isMatch) {
                            // We use raw queries since we don't need a helper
                            // method. We only ever do this once so there's no
                            // point to make this a helper method
                            DBManager.instance.updateData(
                                "update config_match set export = export + 1 where export >= " +
                                    widget.pointValues["export"].toString());

                            DBManager.instance.insertData(
                              "insert into config_match values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                                  (int.tryParse(widget.pointValues["export"]
                                              .toString()) ??
                                          -2)
                                      .toString() +
                                  ")",
                            );

                            // Reload the page so that we get the new widget
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return MatchSettingsPage(
                                  scrollToOffset:
                                      widget.controller?.offset ?? 0.0,
                                );
                              },
                            ));
                          } else {
                            // Same story here just for pit data
                            DBManager.instance.updateData(
                                "update config_pit set export = export + 1 where export >= " +
                                    widget.pointValues["export"].toString());

                            DBManager.instance.insertData(
                              "insert into config_pit values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                                  (int.tryParse(widget.pointValues["export"]
                                              .toString()) ??
                                          -2)
                                      .toString() +
                                  ")",
                            );

                            // Reload the page
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return PitSettingsPage(
                                  scrollToOffset:
                                      widget.controller?.offset ?? 0.0,
                                );
                              },
                            ));
                          }
                        },
                        icon: const Icon(
                          Icons.add_circle,
                        ),
                      ),
                      // Add after the current widget
                      IconButton(
                        onPressed: () {
                          if (widget.isMatch) {
                            // Move all the widgets up one
                            DBManager.instance.updateData(
                                "update config_match set export = export + 1 where export > " +
                                    widget.pointValues["export"].toString());

                            // Insert a new widget after the current one
                            DBManager.instance.insertData(
                              "insert into config_match values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                                  ((int.tryParse(widget.pointValues["export"]
                                                  .toString()) ??
                                              -2) +
                                          1)
                                      .toString() +
                                  ")",
                            );

                            // Reload the page
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return MatchSettingsPage(
                                  scrollToOffset:
                                      widget.controller?.offset ?? 0.0,
                                );
                              },
                            ));
                          } else {
                            // Same story here but for pit config
                            DBManager.instance.updateData(
                                "update config_pit set export = export + 1 where export > " +
                                    widget.pointValues["export"].toString());

                            DBManager.instance.insertData(
                              "insert into config_pit values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                                  ((int.tryParse(widget.pointValues["export"]
                                                  .toString()) ??
                                              -2) +
                                          1)
                                      .toString() +
                                  ")",
                            );

                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return PitSettingsPage(
                                  scrollToOffset:
                                      widget.controller?.offset ?? 0.0,
                                );
                              },
                            ));
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                );

                return Column(
                  children: finalSettings,
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
          ),
        ),
      ),
    );
  }

  // Delete the current datapoint
  // This is a helper method because we use it twice
  void _deletePoint() {
    if (widget.isMatch) {
      // Get rid of the row that this datapoint is in
      DBManager.instance.deleteData(
        "delete from config_match where export = " +
            widget.pointValues["export"].toString() +
            " and title = \"" +
            widget.pointValues["title"].toString() +
            "\"",
      );

      // Move all the export values down one
      DBManager.instance.updateData(
          "update config_match set export = export - 1 where export > " +
              widget.pointValues["export"].toString());

      // Reload the page
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return MatchSettingsPage(
            scrollToOffset: widget.controller?.offset ?? 0.0,
          );
        },
      ));
    } else {
      // Same story but for pit data
      DBManager.instance.deleteData(
        "delete from config_pit where export = " +
            widget.pointValues["export"].toString() +
            " and title = \"" +
            widget.pointValues["title"].toString() +
            "\"",
      );

      DBManager.instance.updateData(
          "update config_pit set export = export - 1 where export > " +
              widget.pointValues["export"].toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PitSettingsPage(scrollToOffset: widget.controller?.offset ?? 0.0),
        ),
      );
    }
  }
}
