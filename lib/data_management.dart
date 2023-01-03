import 'dart:convert';
import 'dart:io';

import 'package:bearscouts/database.dart';
import 'package:bearscouts/themefile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// DataManagementPage is a simple page for importing and exporting app data
/// templates. This is useful for making the data collection the same across
/// multiple devices.
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
        title: const Text('Templates'),
      ),
      body: Container(
        decoration: backgroundDecoration,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                // Export button
                child: ElevatedButton(
                  onPressed: () async {
                    // Grab all of the config data from the database
                    var matchData = await DBManager.instance
                        .getData("select * from config_match");
                    var pitData = await DBManager.instance
                        .getData("select * from config_pit");

                    // Combine the two data sections into one larger map
                    var totalData = {
                      "match": matchData,
                      "pit": pitData,
                    };

                    if ((!Platform.isAndroid && !Platform.isIOS) ||
                        await Permission.storage.request().isGranted) {
                      String? saveLocation =
                          await FilePicker.platform.getDirectoryPath();

                      if (saveLocation == null) {
                        // We didn't get a save location; abort
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
                        // The file naming scheme is bearscouts_config_{export time}
                        String exportTime = DateTime.now()
                            .toString()
                            .split(' ')[0]
                            .replaceAll('/', '-');
                        File file = File(
                            '$saveLocation/bearscouts_config_$exportTime.json');

                        await file.writeAsString(json.encode(totalData));

                        // We've successfully exported data. Tell the user
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Data Exported'),
                            content: Text('Data has been exported to '
                                '$saveLocation/bearscouts_config_$exportTime.json'),
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
                padding: const EdgeInsets.only(bottom: 10),
                // Import button
                child: ElevatedButton(
                  onPressed: () async {
                    // Use FilePicker to grab a file from the os
                    var matchData = await FilePicker.platform.pickFiles();
                    // Make sure the user actually selected a file and that it
                    // is only one file. There's no batch file import here.
                    if (matchData != null && matchData.isSinglePick) {
                      if (matchData.files.single.path != null &&
                          matchData.files.single.path!.isNotEmpty) {
                        File matchDataInputFile =
                            File(matchData.files.single.path!);

                        String data = await matchDataInputFile.readAsString();

                        // Use the function to read from a string. This will
                        // delete all data that was in the database before,
                        // and the user should be aware of this
                        await DBManager.instance.readConfigFromString(data);

                        // Tell the user we were successful
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
                      // We have more than one or no files selected. Abort.
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Failed Importing Data'),
                          content: const Text(
                              'Either zero or multiple files were selected. Please try again.'),
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
              // Reset to default button. This will read the configuration
              // from the asset bundle, which is a Rapid React template
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  child: const Text("Reset to Default"),
                  onPressed: () {
                    // Ensure that the user knows what they are doing before
                    // actually deleting the data.
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Are you sure?"),
                        content: const Text(
                          "This will FOREVER lose all data "
                          "stored in the app. Ensure you have a backup before"
                          " doing this.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              DBManager.instance.readConfigFromAssetBundle();

                              Navigator.pop(context);
                            },
                            child: const Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No"),
                          )
                        ],
                      ),
                    );
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
