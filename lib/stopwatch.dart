import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scouting_app3/handlers.dart';

// Custom stopwatch widget
class StopwatchTimerWidget extends StatefulWidget {
  final String stageName;
  final String title;
  final int initialTime;

  const StopwatchTimerWidget(this.stageName, this.title, this.initialTime,
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

    // Stop trying to update the display
    timer?.cancel();
  }

  void reset() {
    // We don't want to account for any previous data anymore
    addInitialTime = false;
    // Get rid of the previous data
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
      const Duration(milliseconds: 50),
      (_) => setState(() {}),
    );
  }

  void stopTimer() {
    MatchHandler.matchData[widget.stageName]![widget.title] =
        // Get elapsed time
        ((watchTimer.elapsedMilliseconds +
                    // Check whether to add initial time from a previous stopwatch run or not
                    (addInitialTime ? widget.initialTime : 0)) /
                // Divide by 1000 to convert to seconds
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
                style: Theme.of(context).textTheme.displayMedium,
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
                              (addInitialTime ? widget.initialTime : 0)) /
                          1000.0)),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(fontSize: 36),
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: stopTimer,
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => reset(),
                  child: Text(
                    "Reset",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// Converts time to a number in the form of #.# (ex. 12.3, 5.9)
  String _formatTime(double seconds) {
    seconds *= 10;
    seconds = seconds.floorToDouble();
    seconds /= 10;
    return seconds.toString();
  }
}
