import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FileViewer extends StatefulWidget {
  final String viewerType;

  const FileViewer({Key? key, this.viewerType = "match"}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  List<String> filesToPutInQR = [];

  @override
  void initState() {
    super.initState();
  }

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
                    children: const [
                      Center(
                        child: Text("Match data loading...",
                            style: TextStyle(fontSize: 96)),
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
    // Sometimes it seems that the asnyc snapshot is not ready when the widget is built
    // This is a workaround to make sure that the widget is built
    if (values.isEmpty) {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        setState(() {});
      });
    }
    return Column(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ElevatedButton(
              child: const Text("View QR code for all selected matches"),
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
        ),

        // Delete buttons and confirmation
        Center(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ElevatedButton(
              child: const Text("Delete all selected matches"),
              onPressed: () {
                if (_CheckBoxWrapperState.numSelected > 0) {
                  AlertDialog alert = AlertDialog(
                    title: const Text("Delete data?"),
                    content: const Text(
                        "Are you sure that you want to delete these files?"),
                    actions: [
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () {
                          for (String filename in filesToPutInQR) {
                            File(filename).deleteSync();
                          }
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              "/pit_scout/data_view", (route) => false);
                        },
                      ),
                      TextButton(
                        child: const Text("No"),
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
        ),
        // End delete buttons and confirmation

        // List of file names
        SizedBox(
          height: 600,
          child: ListView.builder(
            itemCount: values.length,
            itemBuilder: (context, index) {
              String buttonText = "";
              if (Platform.isWindows) {
                buttonText = values[index].split("\\").last;
              } else {
                buttonText = values[index].split("/").last;
              }

              return Row(
                children: <Widget>[
                  CheckBoxWrapper(filesToPutInQR, values[index]),
                  ElevatedButton(
                    child: Text(buttonText),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodeView(File(values[index])),
                        ),
                      );
                    },
                  ),
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
    List<String> fileList = [];
    Directory appFilesDir = await getApplicationSupportDirectory();
    if (widget.viewerType == "match") {
      appFilesDir = Directory(appFilesDir.path + "/matches");
    } else {
      appFilesDir = Directory(appFilesDir.path + "/pit");
    }
    if (!(await appFilesDir.exists())) {
      await appFilesDir.create();
    }
    appFilesDir.list().forEach((element) {
      if (element.path.endsWith("json")) {
        fileList.add(element.path);
      }
    });
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
        title: const Text("QR Code viewer"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: QRCodeViewPage(
                () {
                  String fileString = fileRef.readAsStringSync();
                  String qrString = "";
                  List fileJson = json.decode(fileString);

                  for (String datapoint in fileJson) {
                    qrString += datapoint + ";";
                  }

                  return qrString;
                }(),
                fileRef.readAsStringSync(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: ElevatedButton(
                  child: const Text("Delete file"),
                  onPressed: () {
                    AlertDialog alert = AlertDialog(
                      title: const Text("Delete data?"),
                      content: const Text(
                          "Are you sure that you want to delete this file?"),
                      actions: [
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            fileRef.deleteSync();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                        TextButton(
                          child: const Text("No"),
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

      String fileString = currentFile.readAsStringSync();
      List fileJson = json.decode(fileString);

      for (String datapoint in fileJson) {
        retString += datapoint + ";";
      }

      retString += "\n";
    }

    return retString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code viewer"),
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
            child: QRCodeViewPage(buildQRString(), ""),
          ),
        ),
      ),
    );
  }
}

class QRCodeViewPage extends StatefulWidget {
  final String entireData;
  final String fileContents;

  const QRCodeViewPage(this.entireData, this.fileContents, {Key? key})
      : super(key: key);

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
        (widget.fileContents.isNotEmpty)
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  child: const Text("View raw file"),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FileViewPage(widget.fileContents),
                        ));
                  },
                ),
              )
            : const Padding(padding: EdgeInsets.all(0)),
      ],
    );
  }
}

class FileViewPage extends StatelessWidget {
  final String fileContents;

  const FileViewPage(this.fileContents, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raw File Viewer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(fileContents),
        ),
      ),
    );
  }
}
