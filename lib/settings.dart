import 'dart:convert';

import 'package:bearscouts/custom_widgets.dart';
import 'package:bearscouts/database.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    if (!authenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Login'),
        ),
        drawer: const NavDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              children: <Widget>[
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                  controller: _passwordController,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      var bytes = utf8.encode(_passwordController.text);
                      var digest = sha256.convert(bytes);

                      if (_passwordHash.toLowerCase() ==
                          digest.toString().toLowerCase()) {
                        setState(() {
                          authenticated = true;
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
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
        ),
        drawer: const NavDrawer(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: ListView(
            children: [
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
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: ListTile(
                    title: Text(
                      "Manage App Data",
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
      );
    }
  }
}

class MatchSettingsPage extends StatefulWidget {
  final int widgetToScroll;

  const MatchSettingsPage({this.widgetToScroll = 0, Key? key})
      : super(key: key);

  @override
  _MatchSettingsPageState createState() => _MatchSettingsPageState();
}

class _MatchSettingsPageState extends State<MatchSettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        _scrollController.jumpTo(
          widget.widgetToScroll * 558.0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Settings'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/settings/match_data");
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                FutureBuilder(
                  builder: (BuildContext context,
                      AsyncSnapshot<SharedPreferences> snapshot) {
                    if (snapshot.hasData) {
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
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                  future: SharedPreferences.getInstance(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return DatapointSettingsWidget(
                        snapshot.data![index],
                        true,
                      );
                    },
                    itemCount: snapshot.data!.length,
                    controller: _scrollController,
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: DBManager.instance.getMatchConfig(),
      ),
    );
  }
}

class PitSettingsPage extends StatefulWidget {
  final int widgetToScroll;

  const PitSettingsPage({this.widgetToScroll = 0, Key? key}) : super(key: key);

  @override
  _PitSettingsPageState createState() => _PitSettingsPageState();
}

class _PitSettingsPageState extends State<PitSettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        _scrollController.jumpTo(
          widget.widgetToScroll * 558.0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pit Settings'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/settings/pit_data");
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                FutureBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<SharedPreferences> snapshot) {
                      if (snapshot.hasData) {
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
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                    future: SharedPreferences.getInstance()),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return DatapointSettingsWidget(
                        snapshot.data![index],
                        false,
                      );
                    },
                    itemCount: snapshot.data!.length,
                    controller: _scrollController,
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: DBManager.instance.getPitConfig(),
      ),
    );
  }
}

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
      body: FutureBuilder(
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
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
                BearScoutsTextField(
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
                ),
                BearScoutsTextField(
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
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: SharedPreferences.getInstance(),
      ),
    );
  }
}

class DatapointSettingsWidget extends StatefulWidget {
  final Map<String, Object?> pointName;
  final bool isMatch;

  const DatapointSettingsWidget(this.pointName, this.isMatch, {Key? key})
      : super(key: key);

  @override
  _DatapointSettingsWidgetState createState() =>
      _DatapointSettingsWidgetState();
}

class _DatapointSettingsWidgetState extends State<DatapointSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primaryContainer,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            children: [
              BearScoutsTextField(
                const ["Title", "", "", "text", "Enter a valid value"],
                (bool isValid, String value) {
                  if (widget.isMatch) {
                    DBManager.instance.updateMatchConfigDatapoint(
                      widget.pointName["export"] as int,
                      "title",
                      value,
                    );
                  } else {
                    DBManager.instance.updatePitConfigDatapoint(
                      widget.pointName["export"] as int,
                      "title",
                      value,
                    );
                  }
                },
                widget.pointName["title"].toString(),
              ),
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
                (bool isValid, String value) {
                  if (widget.isMatch) {
                    DBManager.instance.updateMatchConfigDatapoint(
                      widget.pointName["export"] as int,
                      "type",
                      value,
                    );
                  } else {
                    DBManager.instance.updatePitConfigDatapoint(
                      widget.pointName["export"] as int,
                      "type",
                      value,
                    );
                  }
                },
                widget.pointName["type"].toString(),
              ),
              FutureBuilder(
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<SharedPreferences> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      String pages = snapshot.data!.getString(
                            widget.isMatch ? "matchPages" : "pitPages",
                          ) ??
                          "";

                      return BearScoutsMultipleChoice(
                        [
                          "Page",
                          "",
                          "",
                          pages,
                          pages,
                        ],
                        (bool isValid, String value) {},
                        widget.pointName["page"].toString(),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                  future: SharedPreferences.getInstance()),
              BearScoutsTextField(
                const [
                  "Special Field 1",
                  "",
                  "",
                  "text",
                  "Enter a valid value"
                ],
                (bool isValid, String value) {
                  if (widget.isMatch) {
                    DBManager.instance.updateMatchConfigDatapoint(
                      widget.pointName["export"] as int,
                      "special1",
                      value,
                    );
                  } else {
                    DBManager.instance.updatePitConfigDatapoint(
                      widget.pointName["export"] as int,
                      "special1",
                      value,
                    );
                  }
                },
                widget.pointName["special1"].toString(),
              ),
              BearScoutsTextField(
                const [
                  "Special Field 2",
                  "",
                  "",
                  "text",
                  "Enter a valid value"
                ],
                (bool isValid, String value) {
                  if (widget.isMatch) {
                    DBManager.instance.updateMatchConfigDatapoint(
                      widget.pointName["export"] as int,
                      "special2",
                      value,
                    );
                  } else {
                    DBManager.instance.updatePitConfigDatapoint(
                      widget.pointName["export"] as int,
                      "special2",
                      value,
                    );
                  }
                },
                widget.pointName["special2"].toString(),
              ),
              BearScoutsCounter(
                const [
                  "Export order",
                  "",
                  "counter",
                  "",
                  "",
                ],
                (bool isValid, String value) {
                  if (widget.isMatch) {
                    DBManager.instance.updateMatchConfigExportAtTitle(
                      widget.pointName["title"].toString(),
                      int.tryParse(value) ?? -1,
                    );
                  } else {
                    DBManager.instance.updatePitConfigExportAtTitle(
                      widget.pointName["title"].toString(),
                      int.tryParse(value) ?? -1,
                    );
                  }
                },
                widget.pointName["export"].toString(),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.isMatch) {
                        DBManager.instance.deleteData(
                          "delete from config_match where export = " +
                              widget.pointName["export"].toString() +
                              " and title = \"" +
                              widget.pointName["title"].toString() +
                              "\"",
                        );

                        DBManager.instance.updateData(
                            "update config_match set export = export - 1 where export > " +
                                widget.pointName["export"].toString());

                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return MatchSettingsPage(
                              widgetToScroll: int.tryParse(
                                      widget.pointName["export"].toString()) ??
                                  0,
                            );
                          },
                        ));
                      } else {
                        DBManager.instance.deleteData(
                          "delete from config_pit where export = " +
                              widget.pointName["export"].toString() +
                              " and title = \"" +
                              widget.pointName["title"].toString() +
                              "\"",
                        );

                        DBManager.instance.updateData(
                            "update config_pit set export = export - 1 where export > " +
                                widget.pointName["export"].toString());

                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return PitSettingsPage(
                              widgetToScroll: int.tryParse(
                                      widget.pointName["export"].toString()) ??
                                  0,
                            );
                          },
                        ));
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (widget.isMatch) {
                        DBManager.instance.updateData(
                            "update config_match set export = export + 1 where export >= " +
                                widget.pointName["export"].toString());

                        DBManager.instance.insertData(
                          "insert into config_match values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                              (int.tryParse(widget.pointName["export"]
                                          .toString()) ??
                                      -2)
                                  .toString() +
                              ")",
                        );

                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return MatchSettingsPage(
                              widgetToScroll: int.tryParse(
                                      widget.pointName["export"].toString()) ??
                                  0,
                            );
                          },
                        ));
                      } else {
                        DBManager.instance.updateData(
                            "update config_pit set export = export + 1 where export >= " +
                                widget.pointName["export"].toString());

                        DBManager.instance.insertData(
                          "insert into config_pit values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                              (int.tryParse(widget.pointName["export"]
                                          .toString()) ??
                                      -2)
                                  .toString() +
                              ")",
                        );

                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return PitSettingsPage(
                              widgetToScroll: int.tryParse(
                                      widget.pointName["export"].toString()) ??
                                  0,
                            );
                          },
                        ));
                      }
                    },
                    icon: const Icon(
                      Icons.add_circle,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (widget.isMatch) {
                        DBManager.instance.updateData(
                            "update config_match set export = export + 1 where export > " +
                                widget.pointName["export"].toString());

                        DBManager.instance.insertData(
                          "insert into config_match values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                              ((int.tryParse(widget.pointName["export"]
                                              .toString()) ??
                                          -2) +
                                      1)
                                  .toString() +
                              ")",
                        );

                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return MatchSettingsPage(
                              widgetToScroll: int.tryParse(
                                      widget.pointName["export"].toString()) ??
                                  0,
                            );
                          },
                        ));
                      } else {
                        DBManager.instance.updateData(
                            "update config_pit set export = export + 1 where export > " +
                                widget.pointName["export"].toString());

                        DBManager.instance.insertData(
                          "insert into config_pit values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                              ((int.tryParse(widget.pointName["export"]
                                              .toString()) ??
                                          -2) +
                                      1)
                                  .toString() +
                              ")",
                        );

                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return PitSettingsPage(
                              widgetToScroll: int.tryParse(
                                      widget.pointName["export"].toString()) ??
                                  0,
                            );
                          },
                        ));
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
