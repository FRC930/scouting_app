import 'package:flutter/material.dart';

/// CounterField
/// This is a widget used by the scouting app to get a positive integer
/// input from the user. This uses a callback to set the value,
/// allowing the parent widget to control updating the value. This
/// allows the the counterfield to be used across the app.
class CounterField extends StatefulWidget {
  /// The callback to set the value
  final void Function(int) callback;

  /// The initial value of the [CounterField]
  final int initialValue;

  const CounterField(this.callback, this.initialValue, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CounterFieldState();
}

/// The state of the [CounterField]
class _CounterFieldState extends State<CounterField> {
  /// The current value of the [CounterField]
  int counter = 0;

  /// TextEditingController to allow updating the value whenever the
  /// user presses either of the buttons
  TextEditingController controller = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();

    // Set the initial value to the one passed to the widget
    counter = widget.initialValue;
    // Set the initial value of the controller to the initial integer
    controller.text = counter.toString();
    // Call the value update callback with the initial value
    widget.callback(counter);
  }

  @override
  Widget build(BuildContext context) {
    // The counterfield is a row of three items: a left button, a text field, and a right button
    return Row(
      children: [
        SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (counter > 0) {
                  counter--;
                }
                // Update the value after changing the counter value
                widget.callback(counter);
                // Update the text field to reflect the new value
                controller.text = counter.toString();
              });
            },
            child: const Icon(
              Icons.arrow_left_sharp,
            ),
          ),
        ),
        // Expanded to ensure the text field fills the remaining space
        Expanded(
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            enabled: false,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // There is no need to do bounds checking here
                counter++;
                // Update the value after changing the counter value
                widget.callback(counter);
                // Update the text field to reflect the new value
                controller.text = counter.toString();
              });
            },
            child: const Icon(
              Icons.arrow_right_sharp,
            ),
          ),
        ),
      ],
    );
  }
}
