import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bearscouts/data_manager.dart';

class StopwatchWidget extends StatefulWidget {
  final int dataIndex;
  final int initialTimeMilliseconds;

  const StopwatchWidget(this.dataIndex, this.initialTimeMilliseconds,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  Stopwatch timer = Stopwatch();
  Timer? updateTimer;
  bool addInitialTime = true;

  @override
  void initState() {
    super.initState();

    stopTimer();
  }

  void reset() {
    addInitialTime = false;
    DataManager.setMatchDataAtIndex(widget.dataIndex, "0.0");
    setState(() {
      timer.stop();
      timer.reset();
      updateTimer?.cancel();
    });
  }

  void startTimer() {
    timer.start();
    updateTimer?.cancel();
    updateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {});
    });
  }

  void stopTimer() {
    String elapsedTime = ((timer.elapsedMilliseconds +
                (addInitialTime ? widget.initialTimeMilliseconds : 0)) /
            1000.0)
        .toString();
    DataManager.setMatchDataAtIndex(widget.dataIndex, elapsedTime);
    setState(() {
      timer.stop();
      updateTimer?.cancel();
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
                DataManager.getDatapoint(widget.dataIndex)["title"],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: SizedBox(
                width: 200,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xffdddddd), width: 3),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        _formatTime(((timer.elapsedMilliseconds +
                                (addInitialTime
                                    ? widget.initialTimeMilliseconds
                                    : 0)) /
                            1000.0)),
                      ),
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
                  child: const Text("Start"),
                ),
                ElevatedButton(
                  onPressed: stopTimer,
                  child: const Text("Stop"),
                ),
                ElevatedButton(
                  onPressed: () => reset(),
                  child: const Text("Reset"),
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
