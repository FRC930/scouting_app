import 'dart:convert';
import 'dart:io';

import 'package:bearscouts/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DataManagementPage extends StatefulWidget {
  const DataManagementPage({Key? key}) : super(key: key);

  @override
  _DataManagementPageState createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scouting App Templates'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () async {
                  var matchData = await DBManager.instance
                      .getData("select * from config_match");
                  var pitData = await DBManager.instance
                      .getData("select * from config_pit");

                  var totalData = {
                    "match": matchData,
                    "pit": pitData,
                  };

                  if ((!Platform.isAndroid && !Platform.isIOS) ||
                      await Permission.storage.request().isGranted) {
                    String? saveLocation =
                        await FilePicker.platform.getDirectoryPath();

                    if (saveLocation == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cancelled Data Export'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      String exportTime = DateTime.now()
                          .toString()
                          .split(' ')[0]
                          .replaceAll('/', '-');
                      File file = File(
                          '$saveLocation/bearscouts_config_$exportTime.json');

                      await file.writeAsString(json.encode(totalData));

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Data Exported'),
                          content: Text(
                              'Data has been exported to $saveLocation/bearscouts_config_$exportTime.json'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: const Text('Export Template'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () async {
                  var matchData = await FilePicker.platform.pickFiles();
                  if (matchData != null && matchData.isSinglePick) {
                    if (matchData.files.single.path != null &&
                        matchData.files.single.path!.isNotEmpty) {
                      File matchDataInputFile =
                          File(matchData.files.single.path!);

                      String data = await matchDataInputFile.readAsString();

                      await DBManager.instance.readConfigFromString(data);

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Data Imported'),
                          content: Text('Data has been imported from ' +
                              matchData.files.single.path!),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Failed Importing Data'),
                        content: const Text(
                            'Either zero or more than one file was selected. Please try again.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Import Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
