import 'package:bearscouts/database.dart';
import 'package:bearscouts/nav_drawer.dart';
import 'package:bearscouts/themefile.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({Key? key}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        title: const Text('Data Viewer'),
      ),
      body: Container(
        decoration: backgroundDecoration,
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            MatchDataList(),
            PitDataList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Match Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Pit Data',
          ),
        ],
      ),
    );
  }
}

class MatchDataList extends StatefulWidget {
  const MatchDataList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MatchDataListState();
}

class _MatchDataListState extends State<MatchDataList> {
  final Map<String, bool> _selected = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    String qrString = "";

                    for (String key in _selected.keys) {
                      if ((_selected[key] ?? false)) {
                        List<String> splitKey = key.split('-');

                        qrString += await getQRString(splitKey[0], splitKey[1]);
                        qrString += "\n";
                      }
                    }

                    setState(() {
                      _selected.clear();
                    });

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => QRCodeViewPage(
                        qrString,
                      ),
                    ));
                  },
                  child: const Text("View QR Code for all selected matches"),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Checkbox(
                        onChanged: (bool? value) {
                          setState(() {
                            _selected[snapshot.data![index]["Team Number"]
                                    .toString() +
                                "-" +
                                snapshot.data![index]["Match Number"]
                                    .toString()] = value ?? false;
                          });
                        },
                        value: _selected[snapshot.data![index]["Team Number"]
                                    .toString() +
                                "-" +
                                snapshot.data![index]["Match Number"]
                                    .toString()] ??
                            false,
                      ),
                      title: Text(
                        "Team " +
                            snapshot.data![index]["Team Number"].toString() +
                            " in match " +
                            snapshot.data![index]["Match Number"].toString(),
                        textAlign: TextAlign.center,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () async {
                          String qrString = await getQRString(
                            snapshot.data![index]["Team Number"].toString(),
                            snapshot.data![index]["Match Number"].toString(),
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QRCodeViewPage(
                                qrString,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  itemCount: snapshot.data!.length,
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              width: 30,
              height: 30,
            ),
          );
        }
      },
      future: DBManager.instance.getData("select * from data_match"),
    );
  }

  Future<String> getQRString(String teamNumber, String matchNumber) async {
    List<Map<String, Object?>> qrData = await DBManager.instance.getData(
      "select * from data_match where \"Match Number\" = " +
          matchNumber +
          " and \"Team Number\" = " +
          teamNumber,
    );

    List<String> exportOrder = (await DBManager.instance.getData(
      "select title from config_match order by export asc",
    ))
        .map(
          (e) => e["title"].toString(),
        )
        .toList();

    String qrString = "";
    for (String title in exportOrder) {
      String dataToAdd = qrData[0][title].toString();
      if (dataToAdd.isNotEmpty) {
        qrString += dataToAdd + ";";
      }
    }
    return qrString;
  }
}

class PitDataList extends StatefulWidget {
  const PitDataList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PitDataListState();
}

class _PitDataListState extends State<PitDataList> {
  final Map<String, bool> _selected = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    String qrString = "";

                    for (String key in _selected.keys) {
                      if ((_selected[key] ?? false)) {
                        qrString += await getQRString(key);
                        qrString += "\n";
                      }
                    }

                    setState(() {
                      _selected.clear();
                    });

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => QRCodeViewPage(
                        qrString,
                      ),
                    ));
                  },
                  child: const Text("View QR Code for all selected teams"),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Checkbox(
                        onChanged: (bool? value) {
                          setState(() {
                            _selected[snapshot.data![index]["Team Number"]
                                .toString()] = value ?? false;
                          });
                        },
                        value: _selected[snapshot.data![index]["Team Number"]
                                .toString()] ??
                            false,
                      ),
                      title: Text(
                        "Team " +
                            snapshot.data![index]["Team Number"].toString(),
                        textAlign: TextAlign.center,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () async {
                          String qrString = await getQRString(
                            snapshot.data![index]["Team Number"].toString(),
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QRCodeViewPage(
                                qrString,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  itemCount: snapshot.data!.length,
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              width: 30,
              height: 30,
            ),
          );
        }
      },
      future: DBManager.instance.getData("select * from data_pit"),
    );
  }

  Future<String> getQRString(String teamNumber) async {
    List<Map<String, Object?>> qrData = await DBManager.instance.getData(
      "select * from data_pit where \"Team Number\" = " + teamNumber,
    );

    List<String> exportOrder = (await DBManager.instance.getData(
      "select title from config_pit order by export asc",
    ))
        .map(
          (e) => e["title"].toString(),
        )
        .toList();

    if (qrData.isEmpty) {
      return "";
    }

    String qrString = "";
    for (String title in exportOrder) {
      String dataToAdd = qrData[0][title].toString();
      if (dataToAdd.isNotEmpty) {
        qrString += dataToAdd + ";";
      }
    }
    return qrString;
  }
}

class QRCodeViewPage extends StatelessWidget {
  final String qrCodeData;

  const QRCodeViewPage(this.qrCodeData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? dataWidget;

    if (qrCodeData.isEmpty) {
      dataWidget = const Center(
        child: Text('No data'),
      );
    } else if (qrCodeData.length > 3000) {
      dataWidget = const Center(
        child: Text('Too much data for a single QR code'),
      );
    } else {
      dataWidget = Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CustomPaint(
            size: const Size.square(360.0),
            painter: QrPainter(
              data: qrCodeData,
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Container(
        decoration: backgroundDecoration,
        child: Center(
          child: dataWidget,
        ),
      ),
    );
  }
}
