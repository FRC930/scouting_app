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

  @override
  Widget build(BuildContext context) {
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
                        } else {
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

class _MatchSettingsPageState extends State<MatchSettingsPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      widget._scrollController.jumpTo(widget.scrollToOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Settings'),
        actions: [
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
                          child: Padding(
                            child: CircularProgressIndicator(),
                            padding: EdgeInsets.only(top: 10),
                          ),
                        );
                      }
                    },
                    future: SharedPreferences.getInstance(),
                  ),
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          future: DBManager.instance.getMatchConfig(),
        ),
      ),
    );
  }
}

class PitSettingsPage extends StatefulWidget {
  final ScrollController _scrollController = ScrollController();
  final double scrollToOffset;

  PitSettingsPage({this.scrollToOffset = 0, Key? key}) : super(key: key);

  @override
  _PitSettingsPageState createState() => _PitSettingsPageState();
}

class _PitSettingsPageState extends State<PitSettingsPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      widget._scrollController.jumpTo(widget.scrollToOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                  builder: (context) => MatchSettingsPage(
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
                              child: CircularProgressIndicator(),
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
                child: CircularProgressIndicator(),
              );
            }
          },
          future: DBManager.instance.getPitConfig(),
        ),
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
      body: Container(
        decoration: backgroundDecoration,
        child: FutureBuilder(
          builder: (BuildContext context,
              AsyncSnapshot<SharedPreferences> snapshot) {
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          future: SharedPreferences.getInstance(),
        ),
      ),
    );
  }
}

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
  static SharedPreferences? prefs;
  static Map<String, List<Widget>> settingsInst = {};
  String _lastDataType = "";

  void setSpecial1(bool isValid, String value) {
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

  void setSpecial2(bool isValid, String value) {
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

  Future<List<Widget>> _getCommonSettings() async {
    prefs ??= await SharedPreferences.getInstance();
    String pages = prefs?.getString(
          widget.isMatch ? "matchPages" : "pitPages",
        ) ??
        "";

    return <Widget>[
      BearScoutsTextField(
        const ["Title", "", "", "text", "Enter a valid value"],
        (bool isValid, String value) {
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
        widget.pointValues["title"].toString(),
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
        (bool isValid, String value) async {
          if (widget.isMatch) {
            await DBManager.instance.updateMatchConfigDatapoint(
              widget.pointValues["export"] as int,
              "type",
              value,
            );

            Future.delayed(
              const Duration(milliseconds: 25),
              () {
                if (_lastDataType != value) {
                  _lastDataType = value;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchSettingsPage(
                          scrollToOffset: widget.controller?.offset ?? 0.0),
                    ),
                  );
                }
              },
            );
          } else {
            await DBManager.instance.updatePitConfigDatapoint(
              widget.pointValues["export"] as int,
              "type",
              value,
            );

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
        widget.pointValues["type"].toString(),
      ),
      BearScoutsMultipleChoice(
        [
          "Page",
          "",
          "",
          pages,
          pages,
        ],
        (bool isValid, String value) {
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

  Future<List<Widget>> _getFieldSettings() async {
    List<Widget> settings = await _getCommonSettings();
    settings.add(
      BearScoutsMultipleChoice(
        const <String>[
          "Validation",
          "",
          "",
          "integer,deciaml,text",
          "Integer,Decimal,Text",
        ],
        setSpecial1,
        widget.pointValues["special1"].toString(),
      ),
    );
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Validation Error Message",
          "",
          "",
          "text",
          "Enter the text to display when user input is incorrect",
        ],
        setSpecial2,
        widget.pointValues["special2"].toString(),
      ),
    );

    return settings;
  }

  Future<List<Widget>> _getMultipleChoiceSettings() async {
    List<Widget> settings = await _getCommonSettings();

    settings.add(
      BearScoutsTextField(
        const <String>[
          "Choices",
          "",
          "",
          "text",
          "Enter a valid list of choices, separated by commas"
        ],
        (bool isValid, String value) {
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
        },
        widget.pointValues["special1"].toString(),
      ),
    );
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Hints",
          "",
          "",
          "text",
          "Enter a valid list of hints, separated by commas"
        ],
        (bool isValid, String value) {
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
        },
        widget.pointValues["special2"].toString(),
      ),
    );

    return settings;
  }

  Future<List<Widget>> _getImageSettings() async {
    List<Widget> settings = await _getCommonSettings();

    settings.add(
      ElevatedButton(
        onPressed: () async {
          FilePickerResult? imageFile =
              await FilePicker.platform.pickFiles(type: FileType.image);

          if (imageFile != null && imageFile.isSinglePick) {
            File externalImageFile = File(imageFile.files.single.path!);

            String newFilePath = "";
            if (!Platform.isWindows) {
              newFilePath = (await getApplicationSupportDirectory()).path +
                  "/images/" +
                  externalImageFile.path.split("/").last;
            } else {
              newFilePath = (await getApplicationSupportDirectory()).path +
                  "\\images\\" +
                  externalImageFile.path.split("\\").last;
            }

            File newFileLocation = File(newFilePath);
            if (!await newFileLocation.exists()) {
              await newFileLocation.create(recursive: true);
            }

            await externalImageFile.copy(newFilePath);

            if (widget.isMatch) {
              DBManager.instance.updateMatchConfigDatapoint(
                widget.pointValues["export"] as int,
                "special1",
                newFilePath,
              );
            } else {
              DBManager.instance.updatePitConfigDatapoint(
                widget.pointValues["export"] as int,
                "special1",
                newFilePath,
              );
            }
          }
        },
        child: const Text("Select Image"),
      ),
    );

    return settings;
  }

  Future<List<Widget>> _getSliderSettings() async {
    List<Widget> settings = await _getCommonSettings();

    settings.add(
      BearScoutsTextField(
        const <String>[
          "Minimum",
          "",
          "",
          "integer",
          "Enter the lowest integer selectable using this field"
        ],
        (bool isValid, String value) {
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
        },
        widget.pointValues["special1"].toString(),
      ),
    );
    settings.add(
      BearScoutsTextField(
        const <String>[
          "Maximum",
          "",
          "",
          "integer",
          "Enter the highest integer selectable using this field"
        ],
        (bool isValid, String value) {
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
        },
        widget.pointValues["special2"].toString(),
      ),
    );

    return settings;
  }

  @override
  void initState() {
    super.initState();

    _lastDataType = widget.pointValues["type"].toString();
  }

  final Map<String, double> heights = {"field": 468.0};

  @override
  Widget build(BuildContext context) {
    if (settingsInst[widget.pointValues["export"]]?.isEmpty ?? true) {
      Future<List<Widget>> settings;

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
            child: FutureBuilder(
              future: settings,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  List<Widget> finalSettings = snapshot.data!;

                  finalSettings.add(
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
                  finalSettings.add(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (widget.isMatch) {
                              DBManager.instance.deleteData(
                                "delete from config_match where export = " +
                                    widget.pointValues["export"].toString() +
                                    " and title = \"" +
                                    widget.pointValues["title"].toString() +
                                    "\"",
                              );

                              DBManager.instance.updateData(
                                  "update config_match set export = export - 1 where export > " +
                                      widget.pointValues["export"].toString());

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
                                  builder: (context) => PitSettingsPage(
                                      scrollToOffset:
                                          widget.controller?.offset ?? 0.0),
                                ),
                              );
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
                                      widget.pointValues["export"].toString());

                              DBManager.instance.insertData(
                                "insert into config_match values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
                                    (int.tryParse(widget.pointValues["export"]
                                                .toString()) ??
                                            -2)
                                        .toString() +
                                    ")",
                              );

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
                        IconButton(
                          onPressed: () {
                            if (widget.isMatch) {
                              DBManager.instance.updateData(
                                  "update config_match set export = export + 1 where export > " +
                                      widget.pointValues["export"].toString());

                              DBManager.instance.insertData(
                                "insert into config_match values (\"New Datapoint\", \"Home\", \"field\", \"text\", \"Enter a valid value\", " +
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
                                  return MatchSettingsPage(
                                    scrollToOffset:
                                        widget.controller?.offset ?? 0.0,
                                  );
                                },
                              ));
                            } else {
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

                  settingsInst[widget.pointValues["export"].toString()] =
                      finalSettings;

                  return Column(
                    children: finalSettings,
                  );
                } else {
                  return const Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 400,
                      width: 400,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: settingsInst[widget.pointValues["export"].toString()] ?? [],
      );
    }
  }
}
