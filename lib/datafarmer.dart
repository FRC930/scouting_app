import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:scouting_app3/counterfield.dart';
import 'package:scouting_app3/stopwatch.dart';
import 'package:tuple/tuple.dart';

import 'handlers.dart';

class MatchPageData extends StatefulWidget {
  final String stageName;
  final StatelessWidget nextPage;

  const MatchPageData(this.stageName, this.nextPage, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MatchPageDataState();
}

class _MatchPageDataState extends State<MatchPageData> {
  final _formKey = GlobalKey<FormState>();

  final List<Tuple2<String, TextEditingController>> _textData = [];

  void _initControllers() {
    final dataRequired = ConfigHandler.getData()[widget.stageName];
    for (int i = 0; i < dataRequired.length; i++) {
      if (_textData.length <= i) {
        var editControl = TextEditingController();
        String contentType = dataRequired[i]["data-type"];
        if (MatchHandler.matchData[widget.stageName] != null &&
            contentType != "choice" &&
            contentType != "stopwatch") {
          editControl.text = MatchHandler
                  .matchData[widget.stageName]![dataRequired[i]["title"]] ??
              "";
        }
        _textData.add(Tuple2(dataRequired[i]["title"], editControl));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MatchHandler.matchData[widget.stageName] == null) {
      MatchHandler.matchData.addAll({widget.stageName: {}});
    }

    if (_textData.isEmpty) {
      _initControllers();
    }

    return Scaffold(
      backgroundColor: const Color(0xff222222),
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
          child: Form(
            onWillPop: () async {
              saveData();
              return true;
            },
            key: _formKey,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: ConfigHandler.getData()[widget.stageName].length,
                    itemBuilder: (content, index) {
                      final dataRequired =
                          ConfigHandler.getData()[widget.stageName];
                      if (dataRequired[index]["data-type"] == "int") {
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
                                  style: TextHandler.boldBodyText,
                                ),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: dataRequired[index]["title"],
                                  fillColor: const Color(0xFFDDDDDD),
                                  filled: true,
                                ),
                                validator: (value) {
                                  if (int.tryParse(value!) == null) {
                                    return "Please enter an integer";
                                  }
                                  return null;
                                },
                                controller: _textData[index].item2,
                                keyboardType: TextInputType.number,
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
                                    style: TextHandler.boldBodyText,
                                  ),
                                  padding: const EdgeInsets.all(5),
                                ),
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    errorStyle: TextStyle(color: Colors.black),
                                    fillColor: Color(0xFFDDDDDD),
                                    filled: true,
                                  ),
                                  items: itemsList.map((String s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s,
                                        style: TextHandler.blackBodyText,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    MatchHandler.matchData[widget.stageName]!
                                        .addAll({
                                      dataRequired[index]["title"]: value
                                    });
                                  },
                                  value:
                                      MatchHandler.matchData[widget.stageName]![
                                          dataRequired[index]["title"]],
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
                          "counter") {
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
                                  style: TextHandler.boldBodyText,
                                ),
                              ),
                              CounterField(
                                (int num) {
                                  MatchHandler.matchData[widget.stageName]![
                                          dataRequired[index]["title"]] =
                                      num.toString();
                                },
                                int.tryParse(MatchHandler
                                                .matchData[widget.stageName]
                                            ?[dataRequired[index]["title"]] ??
                                        "0") ??
                                    0,
                              ),
                            ],
                          ),
                        );
                      } else if (dataRequired[index]["data-type"] ==
                          "stopwatch") {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: StopwatchTimerWidget(
                              widget.stageName,
                              dataRequired[index]["title"],
                              (double.tryParse(MatchHandler
                                                  .matchData[widget.stageName]
                                              ?[dataRequired[index]["title"]] ??
                                          "0.0")! *
                                      1000)
                                  .floor()),
                        );
                      } else if (dataRequired[index]["data-type"] ==
                          "matchnum") {
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
                                    style: TextHandler.boldBodyText,
                                  ),
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Match number and alliance color",
                                    fillColor: Color(0xFFDDDDDD),
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if ((value ?? "").isEmpty) {
                                      return "Please enter a match number and alliance color";
                                    }
                                    String allianceColor =
                                        value!.substring(value.length - 1);
                                    if (value.contains(";")) {
                                      return "Input cannot contain semicolons";
                                    }
                                    if (allianceColor != "R" &&
                                        allianceColor != "r" &&
                                        allianceColor != "B" &&
                                        allianceColor != "b") {
                                      return "Could not get alliance color";
                                    }
                                    if (int.tryParse(
                                          value.substring(0, value.length - 1),
                                        ) ==
                                        null) {
                                      return "Could not get match number";
                                    }
                                    return null;
                                  },
                                  controller: _textData[index].item2,
                                ),
                              ],
                            ));
                      } else {
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
                                    style: TextHandler.boldBodyText,
                                  ),
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: dataRequired[index]["title"],
                                    fillColor: const Color(0xFFDDDDDD),
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if ((value ?? "").isEmpty) {
                                      return "Please enter a string";
                                    } else if (value!.contains(";")) {
                                      return "Input cannot contain semicolons";
                                    }
                                    return null;
                                  },
                                  controller: _textData[index].item2,
                                ),
                              ],
                            ));
                      }
                    },
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    primaryColor: const Color(0xFF1D57A5),
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      if (saveData()) {
                        WidgetsBinding.instance?.addPostFrameCallback(
                          (_) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widget.nextPage,
                            ),
                          ),
                        );
                      }
                    },
                    backgroundColor: const Color(0xFF1D57A5),
                    child: const Icon(Icons.keyboard_arrow_right),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool saveData() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      MatchHandler.matchData.update(
        widget.stageName,
        (Map m) => m,
        ifAbsent: () => {},
      );
      final Map data = MatchHandler.matchData[widget.stageName]!;
      for (Tuple2 editorController in _textData) {
        if (editorController.item2.text != "") {
          data.addAll({editorController.item1: editorController.item2.text});
        }
      }
      return true;
    }
    return false;
  }
}
