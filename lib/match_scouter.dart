import 'package:bearscouts/data_collector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bearscouts/data_manager.dart';

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
                  MatchDataManager.clearMatchData();
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

    widgets = MatchDataManager
        .pageConfigs[MatchDataManager.pageNames[widget.pageIndex]] ??= [];

    widgetStates = List.generate(widgets.length, (_) => false, growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MatchDataManager.pageNames[widget.pageIndex]),
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
                      validateAndWrite: (bool state, String value) {
                        widgetStates[index] = state;
                        MatchDataManager.setMatchDataAtIndex(
                          widgets[index],
                          value,
                        );
                      },
                      getData: () => MatchDataManager.getMatchDataAtIndex(
                        widgets[index],
                      ),
                      datapointValues:
                          MatchDataManager.getDatapoint(widgets[index]),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              !widgetStates.contains(false)) {
                            if (widget.pageIndex <
                                MatchDataManager.pageNames.length - 1) {
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
                MatchDataManager.writeMatchData();
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
