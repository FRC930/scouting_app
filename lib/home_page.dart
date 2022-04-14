import 'package:flutter/material.dart';
import 'package:bearscouts/data_manager.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    String tabletName = DataManager.getAppConfig("Tablet Name");

    Color textColor = Colors.white;

    if (tabletName.isNotEmpty && tabletName.toLowerCase().contains("red")) {
      textColor = Colors.red;
    } else if (tabletName.isNotEmpty &&
        tabletName.toLowerCase().contains("blue")) {
      textColor = Colors.blue;
    }

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
