import 'package:bearscouts/data_collector.dart';
import 'package:bearscouts/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitScouter extends StatefulWidget {
  const PitScouter({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PitScouterState();
}

class _PitScouterState extends State<PitScouter> {
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
                  Storage().pitData =
                      List.filled(Storage().pitConfigData.length, "");
                  return const TeamChoosePage();
                }));
              },
              child: const Text("New Form Entry"),
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (PitSaveDataPage.teamNumber == "0") {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const TeamChoosePage();
                }));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const Datapage(0);
                }));
              }
            },
            child: const Text("Continue Current Form Entry"),
          ),
        ),
      ],
    );
  }
}

class TeamChoosePage extends StatefulWidget {
  const TeamChoosePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TeamChoosePageState();
}

class _TeamChoosePageState extends State<TeamChoosePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Selector"),
      ),
      body: ListView.builder(
        itemCount: Storage().appConfig["Team Numbers"].length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: ListTile(
                title: Text(
                  Storage().appConfig["Team Numbers"][index].toString() +
                      " - " +
                      Storage().appConfig["Team Names"][index].toString(),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer),
                ),
                trailing: const Icon(Icons.chevron_right),
                iconColor: Theme.of(context).colorScheme.onTertiaryContainer,
                onTap: () {
                  PitSaveDataPage.teamName =
                      Storage().appConfig["Team Names"][index];
                  PitSaveDataPage.teamNumber =
                      Storage().appConfig["Team Numbers"][index];
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const Datapage(0);
                  }));
                },
              ),
            ),
          );
        },
      ),
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

    widgets = Storage()
        .pitPageConfigs[Storage().pitPageNames[widget.pageIndex]] ??= [];

    widgetStates = List.generate(widgets.length, (_) => false, growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(PitSaveDataPage.teamName),
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
                      validateAndWrite: (bool state, String value) {
                        widgetStates[index] = state;
                        Storage().pitData[widgets[index]] = value;
                      },
                      getData: () => Storage().pitData[widgets[index]],
                      datapointValues: Storage().pitConfigData[widgets[index]],
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              !widgetStates.contains(false)) {
                            if (widget.pageIndex <
                                Storage().pitPageNames.length - 1) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Datapage(widget.pageIndex + 1);
                              }));
                            } else {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const PitSaveDataPage();
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

class PitSaveDataPage extends StatelessWidget {
  static String teamNumber = "0";
  static String teamName = "";

  const PitSaveDataPage({Key? key}) : super(key: key);

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
                child: Text("Write Pit Data",
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontSize: 22)),
              ),
              onPressed: () {
                Storage().writePitData(teamName, teamNumber);
                Navigator.pushNamedAndRemoveUntil(
                    context, "/pit_scout/data_view", (route) => false);
              },
            ),
          ),
        ),
      ),
    );
  }
}
