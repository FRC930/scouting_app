import 'dart:io';

import 'package:bearscouts/counterfield.dart';
import 'package:bearscouts/heatmap.dart';
import 'package:bearscouts/stopwatch.dart';
import 'package:flutter/material.dart';

class DataCollectorWidget extends StatefulWidget {
  final Map datapointValues;
  final int index;
  final Function(bool, String) validateAndWrite;
  final Function() getData;

  const DataCollectorWidget({
    Key? key,
    required this.index,
    required this.validateAndWrite,
    required this.getData,
    required this.datapointValues,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataCollectorWidgetState();
}

class _DataCollectorWidgetState extends State<DataCollectorWidget> {
  dynamic _widgetValue;

  @override
  void initState() {
    super.initState();

    if (widget.datapointValues["data-type"] == "field") {
      _widgetValue = GlobalKey<FormState>();
    } else if (widget.datapointValues["data-type"] == "heading" ||
        widget.datapointValues["data-type"] == "displayImage") {
      widget.validateAndWrite(true, "");
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialValueString = widget.getData();

    if (widget.datapointValues["data-type"] == "field") {
      TextInputType textType = TextInputType.text;
      if (widget.datapointValues["keyboard-type"] != null) {
        switch (widget.datapointValues["keyboard-type"]) {
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
                widget.datapointValues["title"] ?? "",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            TextFormField(
              key: _widgetValue,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: widget.datapointValues["title"],
              ),
              keyboardType: textType,
              initialValue: initialValueString,
              validator: (value) {
                RegExp validationExpression =
                    RegExp(widget.datapointValues["validation"] ?? "");
                if (value == null || value.isEmpty) {
                  return "Please enter a value";
                } else if ((validationExpression.stringMatch(value) ?? "")
                    .isEmpty) {
                  return widget.datapointValues["validate-help"];
                }
                widget.validateAndWrite(true, value);
                return null;
              },
            )
          ],
        ),
      );
    } else if (widget.datapointValues["data-type"] == "counter") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                widget.datapointValues["title"] ?? "",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            CounterField(
              (int num) {
                widget.validateAndWrite(true, num.toString());
              },
              // Get integer from the data string if it exists
              int.tryParse(widget.getData.toString()) ?? 0,
            ),
          ],
        ),
      );
    } else if (widget.datapointValues["data-type"] == "choice") {
      List<String> itemsList =
          widget.datapointValues["choices"]?.cast<String>();
      List<String> hintList = [];
      if (widget.datapointValues.containsKey("hints")) {
        hintList = widget.datapointValues["hints"]?.cast<String>();
      } else {
        for (int i = 0; i < itemsList.length; i++) {
          hintList.add("");
        }
      }

      if (widget.getData().isEmpty) {
        widget.validateAndWrite(true, widget.datapointValues["choices"][0]);
      }

      return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                child: Text(
                  widget.datapointValues["title"],
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
                  widget.validateAndWrite(true, value.toString());
                },
                value: initialValueString.isEmpty
                    ? widget.datapointValues["choices"][0]
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
    } else if (widget.datapointValues["data-type"] == "stopwatch") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: StopwatchWidget(
          (String output) {
            widget.validateAndWrite(true, output);
          },
          ((double.tryParse(initialValueString) ?? 0.0) * 1000).floor(),
          widget.datapointValues["title"],
        ),
      );
    } else if (widget.datapointValues["data-type"] == "displayImage") {
      if (widget.datapointValues["location"].toString().contains("assets/")) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            widget.datapointValues["location"],
            fit: BoxFit.contain,
            height: 200,
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Image.file(
            File(widget.datapointValues["location"]),
            fit: BoxFit.contain,
            height: 200,
          ),
        );
      }
    } else if (widget.datapointValues["data-type"] == "heading") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            widget.datapointValues["title"],
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
      );
    } else if (widget.datapointValues["data-type"] == "slider") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                child: Text(
                  widget.datapointValues["title"],
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.left,
                ),
                padding: const EdgeInsets.all(5),
              ),
            ),
            Slider(
              onChanged: (value) {
                widget.validateAndWrite(true, value.toString());

                setState(() {
                  _widgetValue = value;
                });
              },
              value: _widgetValue ?? double.tryParse(initialValueString) ?? 0.0,
            ),
          ],
        ),
      );
    } else if (widget.datapointValues["data-type"] == "toggle") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                child: Text(
                  widget.datapointValues["title"],
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
                  widget.validateAndWrite(true, value.toString());

                  setState(() {
                    _widgetValue = value;
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else if (widget.datapointValues["data-type"] == "heatmap") {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: HeatMap(
          widget.datapointValues,
          widget.getData(),
          (String value) => widget.validateAndWrite(true, value),
        ),
      );
    } else {
      return const Text("Widget not found");
    }
  }
}
