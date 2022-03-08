import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scouting_app3/counterfield.dart';
import 'package:scouting_app3/globals.dart';
import 'package:scouting_app3/matchviewer.dart';
import 'package:scouting_app3/stopwatch.dart';
import 'package:scouting_app3/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      getApplicationSupportDirectory().then(
        (value) {
          appFilesDir = value;
          appFilesDirString = value.path;
        },
      );
    }

    readConfigJson();

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
                                  pageName: "Pre-Match Data",
                                  nextWidget: DataPage(
                                    pageName: "Match Data",
                                    nextWidget: DataPage(
                                      pageName: "Post-Match Data",
                                      nextWidget: SaveDataPage(),
                                    ),
                                  ),
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
  final String pageName;

  const DataPage({Key? key, this.nextWidget, this.pageName = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appBarTitle = pageName;
    if (matchData["Pre-Match Data"]?[0]["data"].toString().isNotEmpty ??
        false) {
      appBarTitle = "Team " +
          matchData["Pre-Match Data"]?[0]["data"] +
          "'s " +
          appBarTitle;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: appThemeData.textTheme.headlineMedium,
        ),
      ),
      body: DataCollectorWidget(pageName: pageName),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          child: (nextWidget == null)
              ? const Icon(Icons.keyboard_arrow_left)
              : const Icon(Icons.keyboard_arrow_right),
          onPressed: () {
            if (nextWidget != null) {
              if (formKeys[pageName]?.currentState?.validate() ?? false) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => nextWidget!));
              }
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
  final String pageName;

  const DataCollectorWidget({Key? key, this.pageName = ""}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataCollectorWidgetState();
}

class _DataCollectorWidgetState extends State<DataCollectorWidget> {
  @override
  Widget build(BuildContext context) {
    String sectionTitle = widget.pageName;
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
            formKeys[widget.pageName]?.currentState?.validate();
            return true;
          },
          key: (formKeys[widget.pageName] = GlobalKey<FormState>()),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: matchData[widget.pageName]!.length,
                  itemBuilder: (content, index) {
                    final List dataRequired = matchData[widget.pageName] ?? [];

                    String initialValueString = "";
                    if ((matchData[sectionTitle]?.length ?? 0) >= index) {
                      initialValueString =
                          matchData[sectionTitle]?[index]["data"] ?? "";
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
                                dataRequired[index]["title"] ?? "",
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
                                RegExp validationExpression = RegExp(
                                    dataRequired[index]["validation"] ?? "");
                                if (value == null || value.isEmpty) {
                                  return "Please enter a value";
                                } else if ((validationExpression
                                            .stringMatch(value) ??
                                        "")
                                    .isEmpty) {
                                  return dataRequired[index]["validate-help"];
                                }
                                matchData[sectionTitle]?[index]["data"] = value;
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
                                dataRequired[index]["title"] ?? "",
                                textAlign: TextAlign.left,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                            CounterField(
                              (int num) {
                                matchData[sectionTitle]?[index]["data"] =
                                    num.toString();
                              },
                              // Get integer from the data string if it exists
                              int.tryParse(matchData[sectionTitle]?[index]
                                          ["data"] ??
                                      "0") ??
                                  0,
                            ),
                          ],
                        ),
                      );
                    } else if (dataRequired[index]["data-type"] == "choice") {
                      List<String> itemsList =
                          dataRequired[index]["choices"]?.cast<String>();

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
                                  matchData[sectionTitle]?[index]["data"] =
                                      value;
                                },
                                value: initialValueString.isEmpty
                                    ? (matchData[sectionTitle]?[index]
                                        ["choices"][0])
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
                            (double.tryParse(matchData[sectionTitle]![index]
                                        ["data"]) ??
                                    0.0 * 1000)
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
                    } 
                    // else if (dataRequired[index]["data-type"] ==
                    //     "sectionTitle") {
                    // }
                     else {
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
