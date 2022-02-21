import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scouting_app3/themefile.dart';

import 'handlers.dart';

class MatchViewElement extends StatefulWidget {
  const MatchViewElement({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchViewElement> {
  List<String> filesToPutInQR = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          children: <Widget>[
            // Asynchronously load the file list
            FutureBuilder(
              future: _inFutureList(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text("Match data loading..."),
                        ),
                      ),
                    ],
                  );
                } else {
                  return fileListBuild(context, snapshot);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget fileListBuild(BuildContext context, AsyncSnapshot snapshot) {
    List<String> values = snapshot.data;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: ElevatedButton(
            child: Text(
              "View QR code for all selected matches",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              if (_CheckBoxWrapperState.numSelected > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRCodeViewAll(filesToPutInQR),
                  ),
                );
              }
            },
          ),
        ),

        // Delete buttons and confirmation
        Center(
          child: ElevatedButton(
            child: Text(
              "Delete all selected matches",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              if (_CheckBoxWrapperState.numSelected > 0) {
                AlertDialog alert = AlertDialog(
                  title: Text(
                    "Delete data?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  content: Text(
                    "Are you sure that you want to delete these files?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        "Yes",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          for (String filename in filesToPutInQR) {
                            File(filename).deleteSync();
                          }
                        });
                      },
                    ),
                    TextButton(
                      child: Text(
                        "No",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
                showDialog(
                  context: context,
                  builder: (context) {
                    return alert;
                  },
                );
              }
            },
          ),
        ),
        // End delete buttons and confirmation

        // List of file names
        SizedBox(
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: values.length,
            itemBuilder: (context, index) {
              Color backgroundColor = mainColor;
              if (File(values[index]).readAsStringSync().contains("DONE_")) {
                backgroundColor = Colors.grey;
              }

              return Row(
                children: <Widget>[
                  CheckBoxWrapper(filesToPutInQR, values[index]),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: backgroundColor),
                    child: Text(
                      values[index].split("/").last,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodeView(File(values[index])),
                        ),
                      );
                    },
                  )
                ],
              );
            },
          ),
        ),
        // End list of file names
      ],
    );
  }

  // Function to asynchronously read match files
  Future<List<String>> _inFutureList() async {
    List<String> fileList;
    fileList = await MatchViewHandler.readMatchFiles();
    await Future.delayed(const Duration(milliseconds: 500));
    return fileList;
  }
}

// Custom checkbox group input field
class CheckBoxWrapper extends StatefulWidget {
  final List<String> fileList;
  final String filename;

  const CheckBoxWrapper(this.fileList, this.filename, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CheckBoxWrapperState();
}

class _CheckBoxWrapperState extends State<CheckBoxWrapper> {
  // Total number of checkboxes selected, max is 6
  // This is static so all instances share it
  static int numSelected = 0;

  // Whether the current checkbox is checked
  bool _value = false;

  @override
  void initState() {
    super.initState();

    numSelected = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _value,
      onChanged: (value) {
        setState(() {
          // If we are unselecting a checkbox
          if (value == false) {
            // Set our stored value. 
            //This is needed to actually change the checkbox appearance
            _value = value!;
            numSelected--;
            widget.fileList.remove(widget.filename);
          // If we are selecting a checkbox
          } else if (numSelected < 6 && value == true) {
            _value = value!;
            // Sanity check to make sure we don't add the same file twice
            if (!widget.fileList.contains(widget.filename)) {
              numSelected++;
              widget.fileList.add(widget.filename);
            }
          }
          // If we have 6 checkboxes selected already, nothing to do
        });
      },
    );
  }

  bool get state => _value;
}

class QRCodeView extends StatelessWidget {
  final File fileRef;

  const QRCodeView(this.fileRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "QR Code viewer",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
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
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: QRCodeViewPage(fileRef.readAsStringSync()),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: ElevatedButton(
                    child: Text(
                      "Delete file",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () {
                      AlertDialog alert = AlertDialog(
                        title: Text(
                          "Delete data?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        content: Text(
                          "Are you sure that you want to delete this file?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "Yes",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            onPressed: () {
                              fileRef.deleteSync();
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                          ),
                          TextButton(
                            child: Text(
                              "No",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          return alert;
                        },
                      );
                    },
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

class QRCodeViewAll extends StatelessWidget {
  final List<String> matchFileList;

  const QRCodeViewAll(this.matchFileList, {Key? key}) : super(key: key);

  String buildQRString() {
    String retString = "";

    for (var element in matchFileList) {
      File currentFile = File(element);
      retString += currentFile.readAsStringSync() + "\n";
      currentFile.writeAsStringSync("DONE_", mode: FileMode.append);
    }

    return retString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "QR Code viewer",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
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
          padding: const EdgeInsets.all(20),
          child: Center(
            child: QRCodeViewPage(
              buildQRString(),
            ),
          ),
        ),
      ),
    );
  }
}

class QRCodeViewPage extends StatefulWidget {
  final String entireData;

  const QRCodeViewPage(this.entireData, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeViewPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: CustomPaint(
              size: const Size.square(360.0),
              painter: QrPainter(
                data: widget.entireData,
                version: QrVersions.auto,
                emptyColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
