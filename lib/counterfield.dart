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
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFF1D57A5),
            ),
            onPressed: () {
              setState(() {
                if (counter > 0) {
                  counter--;
                }
                widget.callback(counter);
                controller.text = counter.toString();
              });
            },
            child: const Icon(Icons.arrow_left_sharp),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Color(0xFFDDDDDD),
              filled: true,
            ),
            enabled: false,
          ),
        ),
        SizedBox(
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFF1D57A5),
            ),
            onPressed: () {
              setState(() {
                counter++;
                widget.callback(counter);
                controller.text = counter.toString();
              });
            },
            child: const Icon(Icons.arrow_right_sharp),
          ),
        ),
      ],
    );
  }
}
