import 'package:bearscouts/storage_manager.dart';
import 'package:flutter/material.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late final Color textColor;
  late final String tabletName;

  _HomePageWidgetState() {
    tabletName = Storage().appConfig["Tablet Name"] ?? "";

    if (tabletName.isNotEmpty && tabletName.toLowerCase().contains("red")) {
      textColor = Colors.red;
    } else if (tabletName.isNotEmpty &&
        tabletName.toLowerCase().contains("blue")) {
      textColor = Colors.blue;
    } else {
      textColor = Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "This is the",
            style: Theme.of(context).textTheme.headline2?.copyWith(
                  color: textColor,
                ),
          ),
          Text(
            tabletName,
            style: TextStyle(
              fontSize: 96,
              color: textColor,
            ),
          ),
          Text(
            "scouting tablet",
            style: Theme.of(context)
                .textTheme
                .headline2
                ?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
