import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scouting_app3/configurator.dart';
import 'package:scouting_app3/counterfield.dart';
import 'package:scouting_app3/globals.dart';
import 'package:scouting_app3/matchviewer.dart';
import 'package:scouting_app3/stopwatch.dart';
import 'package:scouting_app3/theme.dart';
import 'package:tuple/tuple.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pre-fetch the configuration data
    Configurator.getInstance().readConfigJson();

    if (!kIsWeb) {
      getApplicationSupportDirectory().then(
        (value) {
          appFilesDir = value;
          appFilesDirString = value.path;
        },
      );
    }

    return MaterialApp(
      title: "930 Scouting App",
      // Only affects debug mode
      debugShowCheckedModeBanner: false,
      theme: appThemeData,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (kIsWeb) {
        AlertDialog alert = AlertDialog(
          title: Text(
            "Device error",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          content: Text(
            "This application is unable to run in the web browser, "
            "as there is currently no way to store files for later use.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              child: Text(
                "Ok",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
        showDialog(context: context, builder: (context) => alert);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "930 Scouting App",
          style: appThemeData.textTheme.headlineMedium,
        ),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: kIsWeb
                  ? []
                  : [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DataPage(
                                  nextWidget: DataPage(
                                    nextWidget: DataPage(
                                      nextWidget: DataPage(
                                        nextWidget: DataPage(
                                          nextWidget: SaveDataPage(),
                                          pageIndex: 4,
                                        ),
                                        pageIndex: 3,
                                      ),
                                      pageIndex: 2,
                                    ),
                                    pageIndex: 1,
                                  ),
                                  pageIndex: 0,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "New Match",
                            style: appThemeData.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MatchDataViewer(),
                              ),
                            );
                          },
                          child: Text(
                            " View Data ",
                            style: appThemeData.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class DataPage extends StatelessWidget {
  final Widget? nextWidget;
  final int pageIndex;

  const DataPage({Key? key, this.nextWidget, this.pageIndex = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map pageData = Configurator.getInstance().getSection(pageIndex);
    String appBarTitle = pageData["title"];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: appThemeData.textTheme.headlineMedium,
        ),
      ),
      body: DataCollectorWidget(pageIndex: pageIndex),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          child: (nextWidget == null)
              ? const Icon(Icons.keyboard_arrow_left)
              : const Icon(Icons.keyboard_arrow_right),
          onPressed: () {
            if (nextWidget != null) {
              try {
                if (formKeys[pageIndex]?.currentState?.validate() ?? false) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => nextWidget!));
                }
              } catch (e) {}
            } else {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
        ),
      ),
    );
  }
}

class DataCollectorWidget extends StatefulWidget {
  final int pageIndex;

  const DataCollectorWidget({Key? key, this.pageIndex = 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataCollectorWidgetState();
}

class _DataCollectorWidgetState extends State<DataCollectorWidget> {
  @override
  Widget build(BuildContext context) {
    String sectionTitle =
        Configurator.getInstance().getSection(widget.pageIndex)["title"];
    return Container(
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
        child: Form(
          onWillPop: () async {
            formKeys[widget.pageIndex]?.currentState?.validate();
            return true;
          },
          key: (formKeys[widget.pageIndex] = GlobalKey<FormState>()),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: Configurator.getInstance()
                      .getSection(widget.pageIndex)["data"]
                      .length,
                  itemBuilder: (content, index) {
                    final dataRequired = Configurator.getInstance()
                        .getSection(widget.pageIndex)["data"];
                    String initialValueString = "";
                    if (matchData[sectionTitle] != null) {
                      for (Tuple2 item in matchData[sectionTitle]!.values) {
                        if (item.item1 == index) {
                          initialValueString = matchData[sectionTitle]![
                                      dataRequired[index]["title"]]
                                  ?.item2 ??
                              "";
                          break;
                        }
                      }
                    }
                    if (dataRequired[index]["data-type"] == "field") {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                dataRequired[index]["title"],
                                textAlign: TextAlign.left,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: dataRequired[index]["title"],
                              ),
                              initialValue: initialValueString,
                              validator: (value) {
                                RegExp validationExpression =
                                    RegExp(dataRequired[index]["validation"]);
                                if (value == null || value.isEmpty) {
                                  return "Please enter a value";
                                } else if ((validationExpression
                                            .stringMatch(value) ??
                                        "")
                                    .isEmpty) {
                                  return dataRequired[index]["validate-help"];
                                }
                                matchData[sectionTitle] ??= {};
                                matchData[sectionTitle]![dataRequired[index]
                                    ["title"]] = matchData[sectionTitle]![
                                            dataRequired[index]["title"]]
                                        ?.withItem2(value) ??
                                    Tuple2<int, String>(
                                        index, value.toString());
                                return null;
                              },
                            )
                          ],
                        ),
                      );
                    } else if (dataRequired[index]["data-type"] == "counter") {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                dataRequired[index]["title"],
                                textAlign: TextAlign.left,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                            CounterField(
                              (int num) {
                                matchData[sectionTitle] ??= {};
                                matchData[sectionTitle] ??= {};
                                matchData[sectionTitle]![dataRequired[index]
                                    ["title"]] = matchData[sectionTitle]![
                                            dataRequired[index]["title"]]
                                        ?.withItem2(num.toString()) ??
                                    Tuple2<int, String>(index, num.toString());
                              },
                              int.tryParse(matchData[sectionTitle]
                                              ?[dataRequired[index]["title"]]
                                          ?.item2 ??
                                      "0") ??
                                  0,
                            ),
                          ],
                        ),
                      );
                    } else if (dataRequired[index]["data-type"] == "choice") {
                      List<String> itemsList =
                          dataRequired[index]["choices"].cast<String>();

                      return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Padding(
                                child: Text(
                                  dataRequired[index]["title"],
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                                padding: const EdgeInsets.all(5),
                              ),
                              DropdownButtonFormField(
                                items: itemsList.map((menuItemName) {
                                  return DropdownMenuItem(
                                    child: Text(
                                      menuItemName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    value: menuItemName,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  matchData[sectionTitle] ??= {};
                                  matchData[sectionTitle]![dataRequired[index]
                                      ["title"]] = matchData[sectionTitle]![
                                              dataRequired[index]["title"]]
                                          ?.withItem2(value.toString()) ??
                                      Tuple2<int, String>(
                                          index, value.toString());
                                },
                                value: initialValueString.isEmpty
                                    ? null
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
                    } else if (dataRequired[index]["data-type"] ==
                        "stopwatch") {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: StopwatchTimerWidget(
                            sectionTitle,
                            dataRequired[index]["title"],
                            (double.tryParse(matchData[sectionTitle]
                                                ?[dataRequired[index]["title"]]
                                            ?.item2 ??
                                        "0.0")! *
                                    1000)
                                .floor(),
                            index),
                      );
                    } else if (dataRequired[index]["data-type"] ==
                        "displayImage") {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image(
                          image: AssetImage("assets/Tarmac.png",
                              bundle: rootBundle),
                          height: 200,
                        ),
                      );
                    } else {
                      return const Text("Widget not found");
                    }
                  },
                ),
              )
            ],
          ),
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
        title: Text(
          "930 Scouting App",
          style: appThemeData.textTheme.headlineMedium,
        ),
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
                child: Text(
                  "Write Match Data",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontSize: 22),
                ),
              ),
              onPressed: () {
                writeMatchData();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MatchDataViewer extends StatelessWidget {
  const MatchDataViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Data Viewer",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: const MatchViewElement(),
    );
  }
}
