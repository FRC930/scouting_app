import 'dart:io';

import 'package:bearscouts/heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bearscouts/counterfield.dart';
import 'package:bearscouts/data_manager.dart';
import 'package:bearscouts/stopwatch.dart';

class MatchScouter extends StatefulWidget {
  const MatchScouter({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MatchScouterState();
}

class _MatchScouterState extends State<MatchScouter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  DataManager.clearMatchData();
                  return const Datapage(0);
                }));
              },
              child: const Text("New Match"),
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Datapage(0);
              }));
            },
            child: const Text("Continue Current Match"),
          ),
        ),
      ],
    );
  }
}

class Datapage extends StatefulWidget {
  final int pageIndex;

  const Datapage(this.pageIndex, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DatapageState();
}

class _DatapageState extends State<Datapage> {
  List<int> widgets = [];
  List<bool> widgetStates = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    widgets =
        DataManager.pageConfigs[DataManager.pageNames[widget.pageIndex]] ??= [];

    widgetStates = List.generate(widgets.length, (_) => false, growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DataManager.pageNames[widget.pageIndex]),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widgets.length + 1,
                itemBuilder: (context, index) {
                  if (index < widgets.length) {
                    return DataCollectorWidget(
                      index: widgets[index],
                      onValidation: (bool state) => widgetStates[index] = state,
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              !widgetStates.contains(false)) {
                            if (widget.pageIndex <
                                DataManager.pageNames.length - 1) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Datapage(widget.pageIndex + 1);
                              }));
                            } else {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const SaveDataPage();
                              }));
                            }
                          }
                        },
                        child: const Text("Next Page"),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SaveDataPage extends StatelessWidget {
  const SaveDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("930 Scouting App"),
        centerTitle: true,
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
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text("Write Match Data",
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontSize: 22)),
              ),
              onPressed: () {
                DataManager.writeMatchData();
                Navigator.pushNamedAndRemoveUntil(
                    context, "/loading", (route) => false);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DataCollectorWidget extends StatefulWidget {
  final int index;
  final Function(bool) onValidation;

  const DataCollectorWidget(
      {Key? key, required this.index, required this.onValidation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataCollectorWidgetState();
}

class _DataCollectorWidgetState extends State<DataCollectorWidget> {
  Map data = {};
  dynamic _widgetValue;

  @override
  void initState() {
    super.initState();

    data = DataManager.getDatapoint(widget.index);

    if (data["data-type"] != "field") {
      widget.onValidation(true);
    } else {
      _widgetValue = GlobalKey<FormState>();
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialValueString = DataManager.getMatchDataAtIndex(widget.index);

    if (data["data-type"] == "field") {
      TextInputType textType = TextInputType.text;
      if (data["keyboard-type"] != null) {
        switch (data["keyboard-type"]) {
          case "number":
            textType = TextInputType.number;
            break;
          default:
            break;
        }
      }

      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                data["title"] ?? "",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            TextFormField(
              key: _widgetValue,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: data["title"],
              ),
              keyboardType: textType,
              initialValue: initialValueString,
              validator: (value) {
                RegExp validationExpression = RegExp(data["validation"] ?? "");
                if (value == null || value.isEmpty) {
                  return "Please enter a value";
                } else if ((validationExpression.stringMatch(value) ?? "")
                    .isEmpty) {
                  return data["validate-help"];
                }
                widget.onValidation(true);
                DataManager.setMatchDataAtIndex(widget.index, value);
                return null;
              },
            )
          ],
        ),
      );
    } else if (data["data-type"] == "counter") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                data["title"] ?? "",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            CounterField(
              (int num) {
                DataManager.setMatchDataAtIndex(widget.index, num.toString());
              },
              // Get integer from the data string if it exists
              int.tryParse(DataManager.getMatchDataAtIndex(widget.index)) ?? 0,
            ),
          ],
        ),
      );
    } else if (data["data-type"] == "choice") {
      List<String> itemsList = data["choices"]?.cast<String>();
      List<String> hintList = [];
      if (data.containsKey("hints")) {
        hintList = data["hints"]?.cast<String>();
      } else {
        for (int i = 0; i < itemsList.length; i++) {
          hintList.add("");
        }
      }

      if (DataManager.getMatchDataAtIndex(widget.index).isEmpty) {
        DataManager.setMatchDataAtIndex(
            widget.index, DataManager.getDatapoint(widget.index)["choices"][0]);
      }

      return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                child: Text(
                  data["title"],
                  style: Theme.of(context).textTheme.headline5,
                ),
                padding: const EdgeInsets.all(5),
              ),
              DropdownButtonFormField(
                items: itemsList.map((menuItemName) {
                  return DropdownMenuItem(
                    child: Text(
                      hintList[itemsList.indexOf(menuItemName)],
                    ),
                    value: menuItemName,
                  );
                }).toList(),
                onChanged: (value) {
                  DataManager.setMatchDataAtIndex(
                      widget.index, value.toString());
                },
                value: initialValueString.isEmpty
                    ? DataManager.getDatapoint(widget.index)["choices"][0]
                    : initialValueString,
                validator: (value) {
                  if (value == null) {
                    return "No choice selected";
                  }
                  return null;
                },
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ));
    } else if (data["data-type"] == "stopwatch") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: StopwatchWidget(
          widget.index,
          ((double.tryParse(initialValueString) ?? 0.0) * 1000).floor(),
        ),
      );
    } else if (data["data-type"] == "displayImage") {
      if (data["location"].toString().contains("assets/")) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            data["location"],
            fit: BoxFit.contain,
            height: 200,
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Image.file(
            File(data["location"]),
            fit: BoxFit.contain,
            height: 200,
          ),
        );
      }
    } else if (data["data-type"] == "heading") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            data["title"],
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
      );
    } else if (data["data-type"] == "slider") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                child: Text(
                  data["title"],
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.left,
                ),
                padding: const EdgeInsets.all(5),
              ),
            ),
            Slider(
              onChanged: (value) {
                DataManager.setMatchDataAtIndex(widget.index, value.toString());

                setState(() {
                  _widgetValue = value;
                });
              },
              value: _widgetValue ?? double.tryParse(initialValueString) ?? 0.0,
            ),
          ],
        ),
      );
    } else if (data["data-type"] == "toggle") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                child: Text(
                  data["title"],
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.left,
                ),
                padding: const EdgeInsets.all(5),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Switch(
                value: _widgetValue ?? false,
                onChanged: (bool value) {
                  DataManager.setMatchDataAtIndex(
                      widget.index, value.toString());
                  setState(() {
                    _widgetValue = value;
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else if (data["data-type"] == "heatmap") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: HeatMap(widget.index),
      );
    } else {
      return const Text("Widget not found");
    }
  }
}
