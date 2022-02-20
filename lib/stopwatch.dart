import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scouting_app3/handlers.dart';

class StopwatchTimerWidget extends StatefulWidget {
  final String stageName;
  final String title;
  final int initialMilliseconds;

  const StopwatchTimerWidget(
      this.stageName, this.title, this.initialMilliseconds,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _StopwatchTimerWidgetState();
}

class _StopwatchTimerWidgetState extends State<StopwatchTimerWidget> {
  Timer? timer;
  Stopwatch watchTimer = Stopwatch();
  bool addInitialTime = true;

  @override
  void dispose() {
    super.dispose();

    timer?.cancel();
  }

  void reset() {
    addInitialTime = false;
    MatchHandler.matchData[widget.stageName]![widget.title] = "0.0";
    setState(() {
      watchTimer.stop();
      watchTimer.reset();
      timer?.cancel();
    });
  }

  void startTimer() {
    watchTimer.start();
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) => setState(() {}),
    );
  }

  void stopTimer() {
    MatchHandler.matchData[widget.stageName]![widget.title] =
        ((watchTimer.elapsedMilliseconds +
                    (addInitialTime ? widget.initialMilliseconds : 0)) /
                1000.0)
            .toString();
    setState(() {
      timer?.cancel();
      watchTimer.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.title,
                style: TextHandler.boldBodyText,
              ),
            ),
            SizedBox(
              width: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffdddddd), width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      _formatTime(((watchTimer.elapsedMilliseconds +
                              (addInitialTime
                                  ? widget.initialMilliseconds
                                  : 0)) /
                          1000.0)),
                      style: TextHandler.boldBodyText.copyWith(fontSize: 36),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: startTimer,
                  child: Text(
                    "Start",
                    style: TextHandler.buttonText,
                  ),
                ),
                ElevatedButton(
                  onPressed: stopTimer,
                  child: Text(
                    "Stop",
                    style: TextHandler.buttonText,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => reset(),
                  child: Text(
                    "Reset",
                    style: TextHandler.buttonText,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(double seconds) {
    seconds *= 10;
    seconds = seconds.floorToDouble();
    seconds /= 10;
    return seconds.toString();
  }
}
