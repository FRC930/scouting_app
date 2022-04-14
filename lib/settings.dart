import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bearscouts/data_manager.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsAuthPage extends StatefulWidget {
  const SettingsAuthPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsAuthPageState();
}

class _SettingsAuthPageState extends State<SettingsAuthPage> {
  static const String _passwordHash =
      "404b131bbcc856693d8d494a7e02af41f8f6ea98a002e58b890fb43c1e18d1e0";
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

                      if (_passwordHash == digest.toString()) {
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
                      "Edit Data Configuration",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    iconColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                    onTap: () => Navigator.pushNamed(context, "/settings"),
                    subtitle: const Text(
                      "Edit data properties and configuration",
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
                      "/settings/app",
                    ),
                    subtitle: const Text(
                      "Edit app settings (tablet name, page order, etc.)",
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
                    onTap: () =>
                        Navigator.pushNamed(context, "/settings/import_export"),
                    subtitle: const Text(
                      "Export, import and restore data",
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
                      "Restart App",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    iconColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/loading", (route) => false);

                      DataManager.writeCurrentData();
                      DataManager.readData();
                    },
                    subtitle: const Text(
                      "Apply changes and lock the admin screen.",
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

class ConfigSettingsPage extends StatefulWidget {
  final int scrollTo;

  const ConfigSettingsPage({Key? key, this.scrollTo = 0}) : super(key: key);

  @override
  _ConfigSettingsPageState createState() => _ConfigSettingsPageState();
}

class _ConfigSettingsPageState extends State<ConfigSettingsPage> {
  final ScrollController _scrollController = ScrollController();
  static final Map<int, double> _scrollOffsets = {0: 0.0};
  static final Map<String, double> _widgetOffsets = {
    "choice": 410.0,
    "counter": 286.0,
    "field": 472.0,
    "stopwatch": 286.0,
    "displayImage": 334.0,
    "heading": 286.0,
    "slider": 472.0,
    "toggle": 286.0,
    "heatmap": 334.0,
  };

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(milliseconds: 33),
      () => _scrollController.jumpTo(
        _scrollOffsets[widget.scrollTo] ?? 0.0,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    DataManager.writeCurrentData();
  }

  @override
  Widget build(BuildContext context) {
    List currentDatapoints = DataManager.getDatapoints();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              size: 24,
            ),
            onPressed: () {
              DataManager.writeCurrentData();
              DataManager.readData();

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/loading",
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (index == currentDatapoints.length) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        DataManager.addDatapoint({
                          "title": "New Datapoint",
                          "data-type": "field",
                          "page-name": "Home Page",
                          "validation": "^[^;]*\$",
                          "validate-help": "How did you get here?",
                          "keyboard-type": "text",
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfigSettingsPage(
                              scrollTo: currentDatapoints.length - 2,
                            ),
                          ),
                        );
                      },
                      child: const Text("Add new datapoint"),
                    ),
                  );
                }

                var datapoint = currentDatapoints[index];
                var type = datapoint["data-type"];
                if (index > 0) {
                  _scrollOffsets[index] = (_scrollOffsets[index - 1] ?? 0.0) +
                      _widgetOffsets[type]!;
                }

                return _DatapointSettingsWidget(index: index);
              },
              itemCount: currentDatapoints.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatapointSettingsWidget extends StatefulWidget {
  final int index;

  const _DatapointSettingsWidget({Key? key, required this.index})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DatapointSettingsWidgetState();
}

class _DatapointSettingsWidgetState extends State<_DatapointSettingsWidget> {
  Map currentSettings = {};

  @override
  void initState() {
    super.initState();

    currentSettings = DataManager.getDatapoint(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: 3,
        )),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: buildSettingsChangeWidget(),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      AlertDialog deletionAlert = AlertDialog(
                        title: const Text("Delete Datapoint?"),
                        actions: [
                          TextButton(
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white54),
                            ),
                            onPressed: () {
                              Navigator.pop(context);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfigSettingsPage(
                                    scrollTo: widget.index,
                                  ),
                                ),
                              );

                              DataManager.removeDatapointAt(widget.index);
                            },
                          ),
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                      showDialog(
                        context: context,
                        builder: (context) => deletionAlert,
                      );
                    },
                    icon: const Icon(Icons.delete, size: 36),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      DataManager.swapDatapointsAtIndexes(
                          widget.index, widget.index - 1);

                      SchedulerBinding.instance
                          ?.addPostFrameCallback((timeStamp) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfigSettingsPage(
                              scrollTo: widget.index,
                            ),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.arrow_circle_up, size: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      DataManager.swapDatapointsAtIndexes(
                          widget.index, widget.index + 1);

                      SchedulerBinding.instance
                          ?.addPostFrameCallback((timeStamp) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfigSettingsPage(
                              scrollTo: widget.index,
                            ),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.arrow_circle_down, size: 40),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsChangeWidget() {
    if (currentSettings.isEmpty) {
      return getTypeSelector(null);
    }

    switch (currentSettings["data-type"]) {
      case "field":
        return getFieldSettings();
      case "counter":
        return getCounterSettings();
      case "choice":
        return getMultipleChoiceSettings();
      case "stopwatch":
        return getStopwatchSettings();
      case "displayImage":
        return getImageSettings();
      case "heading":
        return getHeadingSettings();
      case "slider":
        return getSliderSettings();
      case "toggle":
        return getToggleSettings();
      case "heatmap":
        return getHeatmapSettings();
      default:
        return getTypeSelector(null);
    }
  }

  DropdownButtonFormField<String> getMultipleChoiceSelector(
      List<String> values,
      List<String> labels,
      String? currentValue,
      Function(String?) onSelectionChanged,
      String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: currentValue,
      items: List<DropdownMenuItem<String>>.generate(
        values.length,
        (index) => DropdownMenuItem<String>(
          value: values[index],
          child: Text(labels[index]),
        ),
      ),
      onChanged: onSelectionChanged,
    );
  }

  DropdownButtonFormField<String> getTypeSelector(String? currentSelection) {
    return getMultipleChoiceSelector(
        [
          "choice",
          "counter",
          "field",
          "stopwatch",
          "displayImage",
          "heading",
          "slider",
          "toggle",
          "heatmap",
        ],
        [
          "Multiple Choice",
          "Counter",
          "Field",
          "Stopwatch",
          "Display Image",
          "Heading",
          "Slider",
          "Toggle",
          "Heatmap",
        ],
        currentSelection,
        (value) => setState(() {
              currentSettings["data-type"] = value;
            }),
        "Widget Type");
  }

  List<Widget> getCommonSettings() {
    return <Widget>[
      TextFormField(
        decoration: const InputDecoration(
          labelText: "Title",
        ),
        initialValue: currentSettings["title"] ?? "",
        onChanged: (value) {
          currentSettings["title"] = value;
        },
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: "Page Name",
        ),
        initialValue: currentSettings["page-name"] ?? "",
        onChanged: (value) {
          currentSettings["page-name"] = value;
        },
      ),
      getTypeSelector(currentSettings["data-type"]),
    ];
  }

  Widget getFieldSettings() {
    List<Widget> settings = getCommonSettings();
    settings.add(
      getMultipleChoiceSelector(
        ["^[^;]*\$", "^[0-9]*\$"],
        ["Text", "Number"],
        currentSettings["validation"],
        (value) {
          currentSettings["validation"] = value;
        },
        "Validation",
      ),
    );
    settings.add(TextFormField(
      decoration: const InputDecoration(
        labelText: "Validation Error Message",
      ),
      initialValue: currentSettings["validate-help"] ?? "",
      onChanged: (value) {
        currentSettings["validate-help"] = value;
      },
    ));
    settings.add(
      getMultipleChoiceSelector(
        ["number", "text"],
        ["Number", "Text"],
        currentSettings["keyboard-type"],
        (value) => {currentSettings["keyboard-type"] = value},
        "Keyboard Type",
      ),
    );

    return Column(
      children: settings,
    );
  }

  Widget getCounterSettings() {
    return Column(
      children: getCommonSettings(),
    );
  }

  Widget getMultipleChoiceSettings() {
    List<Widget> settings = getCommonSettings();
    settings.add(TextFormField(
      decoration: const InputDecoration(
        labelText: "Choices",
      ),
      initialValue: currentSettings["choices"]?.join(","),
      onChanged: (value) {
        currentSettings["choices"] = value.split(",");
      },
    ));
    settings.add(TextFormField(
      decoration: const InputDecoration(
        labelText: "Hints",
      ),
      initialValue: currentSettings["hints"]?.join(","),
      onChanged: (value) {
        currentSettings["hints"] = value.split(",");
      },
    ));

    return Column(
      children: settings,
    );
  }

  Widget getStopwatchSettings() {
    return Column(
      children: getCommonSettings(),
    );
  }

  Widget getImageSettings() {
    List<Widget> settings = getCommonSettings();
    settings.add(
      ElevatedButton(
        onPressed: () async {
          FilePickerResult? imageFile = await FilePicker.platform.pickFiles(
            type: FileType.any,
          );
          if (imageFile != null) {
            File externalImageFile = File(imageFile.files.single.path!);

            String newFilePath =
                (await getApplicationSupportDirectory()).path + "/images";

            await externalImageFile.copy(newFilePath);

            currentSettings["location"] = newFilePath;
          }
        },
        child: const Text("Select Image"),
      ),
    );

    return Column(
      children: settings,
    );
  }

  Widget getHeadingSettings() {
    return Column(
      children: getCommonSettings(),
    );
  }

  Widget getSliderSettings() {
    List<Widget> settings = getCommonSettings();
    settings.add(TextFormField(
      decoration: const InputDecoration(
        labelText: "Min",
      ),
      initialValue: currentSettings["min"] ?? "0.0",
      onChanged: (value) {
        currentSettings["min"] = double.tryParse(value) ?? 0.0;
      },
    ));
    settings.add(TextFormField(
      decoration: const InputDecoration(
        labelText: "Max",
      ),
      initialValue: currentSettings["max"] ?? "100.0",
      onChanged: (value) {
        currentSettings["max"] = double.tryParse(value) ?? 100.0;
      },
    ));
    settings.add(TextFormField(
      decoration: const InputDecoration(
        labelText: "Increment",
      ),
      initialValue: currentSettings["increment"] ?? "1.0",
      onChanged: (value) {
        currentSettings["increment"] = double.tryParse(value) ?? 1.0;
      },
    ));

    return Column(
      children: settings,
    );
  }

  Widget getToggleSettings() {
    return Column(
      children: getCommonSettings(),
    );
  }

  Widget getHeatmapSettings() {
    List<Widget> settings = getCommonSettings();
    settings.add(
      ElevatedButton(
        onPressed: () async {
          FilePickerResult? imageFile = await FilePicker.platform.pickFiles(
            type: FileType.any,
          );
          if (imageFile != null) {
            File externalImageFile = File(imageFile.files.single.path!);

            String newFilePath =
                (await getApplicationSupportDirectory()).path + "/images";

            await externalImageFile.copy(newFilePath);

            currentSettings["location"] = newFilePath;
          }
        },
        child: const Text("Select Image"),
      ),
    );

    return Column(
      children: settings,
    );
  }
}

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({Key? key}) : super(key: key);

  @override
  _ImportExportPageState createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Import/Export"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/loading",
                (route) => false,
              );

              DataManager.readData();
            },
          ),
        ],
      ),
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
                    "Import File from Device",
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  iconColor: Theme.of(context).colorScheme.onTertiaryContainer,
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ["json"],
                    );

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      var data = await file.readAsString();
                      DataManager.setDatapoints(jsonDecode(data));
                    }

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Import Complete"),
                          content: const Text("The data has been imported."),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  subtitle: const Text(
                    "Restore a backup match data configuration file",
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
                    "Export File to Device",
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  iconColor: Theme.of(context).colorScheme.onTertiaryContainer,
                  onTap: () async {
                    if (Platform.isAndroid) {
                      String? saveLocation =
                          await FilePicker.platform.getDirectoryPath();

                      if (await Permission.storage.request().isGranted &&
                          saveLocation != null) {
                        final file = File("$saveLocation/settings_export.json");
                        if (await file.exists()) {
                          await file.delete();
                        }

                        await file.create();
                        await file.writeAsString(jsonEncode(
                          DataManager.getDatapoints(),
                        ));

                        var okAlert = AlertDialog(
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"))
                          ],
                          title: const Text("File Saved"),
                          content: const Text(
                              "The file has been saved to the selected folder."),
                        );

                        showDialog(
                            context: context, builder: (context) => okAlert);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"))
                              ],
                              title: const Text("Permission Denied"),
                              content: const Text(
                                "You must grant storage permission to export your settings.",
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                  subtitle: const Text(
                    "Export a backup match data configuration file",
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
                    "Reset Match Data to Default",
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  iconColor: Theme.of(context).colorScheme.onTertiaryContainer,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          TextButton(
                            onPressed: () {
                              DataManager.readConfigFromAssetBundle();

                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Reset",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                        title: const Text("Reset Configuration"),
                        content: const Text(
                            "Are you sure you want to reset the configuration to the default?"),
                      );
                    },
                  ),
                  subtitle: const Text(
                    "Restore the default match data configuration file (Rapid React)",
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

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({Key? key}) : super(key: key);

  @override
  _AppSettingsPageState createState() => _AppSettingsPageState();
}

class _SettingsWidget extends StatefulWidget {
  final String settingName;

  const _SettingsWidget({
    Key? key,
    required this.settingName,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<_SettingsWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.text = DataManager.getAppConfig(widget.settingName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: 3,
        )),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: widget.settingName,
            ),
            onChanged: (value) {
              DataManager.setAppConfigAt(widget.settingName, value);
            },
          ),
        ),
      ),
    );
  }
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  @override
  void dispose() {
    super.dispose();

    DataManager.writeCurrentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/loading",
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(children: const <Widget>[
        _SettingsWidget(settingName: "Tablet Name"),
        _SettingsWidget(settingName: "Page Order"),
      ]),
    );
  }
}
