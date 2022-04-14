import 'dart:async';

import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? loadTimer;

  @override
  void initState() {
    super.initState();

    loadTimer = Timer(const Duration(seconds: 3), () {
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    });
  }

  @override
  void dispose() {
    super.dispose();

    loadTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  "930 Scouting App",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(100),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
