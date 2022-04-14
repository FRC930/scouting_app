import 'package:flutter/material.dart';

class CounterField extends StatefulWidget {
  final void Function(int) callback;
  final int initialValue;

  const CounterField(this.callback, this.initialValue, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CounterFieldState();
}

class _CounterFieldState extends State<CounterField> {
  int counter = 0;
  TextEditingController controller = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();

    counter = widget.initialValue;
    controller.text = counter.toString();
    widget.callback(counter);
  }

  @override
  Widget build(BuildContext context) {
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
                widget.callback(counter);
                controller.text = counter.toString();
              });
            },
            child: const Icon(
              Icons.arrow_left_sharp,
            ),
          ),
        ),
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
                counter++;
                widget.callback(counter);
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
