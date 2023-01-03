import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bearscouts/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// This holds all of the fields stored by name and whether they are valid or
// invalid. When we switch between match and pit scouting, this map is cleared
Map<String, bool> validFields = {};


class BearScoutsDataWidget extends StatefulWidget {
  // This holds all of the information needed to construct a collection widget
  final List<String> datapoint;
  // This tells the widget which database table it needs to write to
  final bool isMatch;

  const BearScoutsDataWidget(
    this.datapoint,
    this.isMatch, {
    Key? key,
  }) : super(key: key);

  @override
  _BearScoutsDataWidgetState createState() => _BearScoutsDataWidgetState();
}

// The state class for the overarching data collection widget
class _BearScoutsDataWidgetState extends State<BearScoutsDataWidget> {
  // This function will be called whenever the data is changed or the widget
  // is initialized
  void onSave(bool valid, String value) {
    // The valid parameter tells us whether to write the data or not
    if (valid) {
      // Write that the field is valid to the validFields map
      validFields[widget.datapoint[0]] = true;

      // Check where to write the data
      if (widget.isMatch) {
        // Call the function in DBManager to write the match data
        DBManager.instance.setMatchDatapoint(
          widget.datapoint[0],
          value,
        );
      } else {
        // Call the other function in DBManger to write the pit data
        DBManager.instance.setPitDatapoint(
          widget.datapoint[0],
          value,
        );
      }
    }
  }

  // This is a helper function to ensure that we get the proper data
  // Using the isMatch variable it decides whether to get pit or match
  String getDatapoint() {
    if (widget.isMatch) {
      return DBManager.instance.getMatchDatapoint(widget.datapoint[0]);
    } else {
      return DBManager.instance.getPitDatapoint(widget.datapoint[0]);
    }
  }

  @override
  void initState() {
    super.initState();

    // Assmue that the field is invalid when we first start up
    validFields[widget.datapoint[0]] = false;
  }

  @override
  void dispose() {
    super.dispose();

    // Remove the widget from validFields so that we can switch collection
    // types without keeping the old widget data
    validFields.remove(widget.datapoint[0]);
  }

  @override
  Widget build(BuildContext context) {
    // Switch on the type of datapoint
    switch (widget.datapoint[2]) {
      // Multiple choice
      case "choice":
        return BearScoutsMultipleChoice(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Numerical counter
      case "counter":
        return BearScoutsCounter(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Uneditable text that will not be exported to the qr code
      case "heading":
        return BearScoutsHeading(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Image that will not be exported to the qr code
      case "image":
        return BearScoutsDisplayImage(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Stopwatch in default configuration
      case "stopwatch":
        return BearScoutsStopwatch(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Toggle or switch, outputs true/false
      case "toggle":
        return BearScoutsToggle(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Slider with min/max and precision settings
      case "slider":
        return BearScoutsSlider(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Heatmap that will export the points that the user inputs
      case "heatmap":
        return BearScoutsHeatMap(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      // Basic text field
      case "field":
      default:
        return BearScoutsTextField(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
    }
  }
}

// Ordinary text field that is suitable for single-line inputs
class BearScoutsTextField extends StatefulWidget {
  // The options which configure the text field
  final List<String> _configOptions;
  // What to put in the text field initially
  final String initialValue;
  // Basically our save function
  final void Function(bool, String) isValidWithValue;
  // Whether to make the text field editable or not
  final bool editable;

  const BearScoutsTextField(
    this._configOptions,
    this.isValidWithValue,
    this.initialValue, {
    Key? key,
    this.editable = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsTextFieldState();
}

// State class for our text field
class _BearScoutsTextFieldState extends State<BearScoutsTextField> {
  // TextEditingController to make programatic changes to the text contained
  // in the text field. This is used to set the initial value and get what
  // the field currently contains
  final TextEditingController _textController = TextEditingController();
  // GlobalKey to ensure that the field is valid
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // We use these to validate the input based on what the config states
  static final Map<String, RegExp> _validationRegexes = {
    "integer": RegExp(r"^[0-9]+$"),
    "decimal": RegExp(r"^[0-9]+(\.[0-9]+)?$"),
    "text": RegExp(r"^[a-zA-Z0-9,. \-]+$"),
  };

  @override
  void initState() {
    super.initState();

    // Set the initial value of the text controller
    _textController.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // Set the text input type based on the type of validation
    TextInputType keyboardType = TextInputType.text;
    if (widget._configOptions[3] == "integer") {
      keyboardType = TextInputType.number;
    } else if (widget._configOptions[3] == "decimal") {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    }

    // Construct the widget using the config options passed in the contructor
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        controller: _textController,
        decoration: InputDecoration(
          labelText: widget._configOptions[0],
          hintText: "Enter ${widget._configOptions[0]} Here",
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        key: _formKey,
        // This gets called whenever the text changes
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          RegExp validationRegex =
              _validationRegexes[widget._configOptions[3]]!;
          if (!validationRegex.hasMatch(value)) {
            return widget._configOptions[4];
          }
          widget.isValidWithValue(true, value);
          return null;
        },
        enabled: widget.editable,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}

// This is the counter widget. We use this to collect numerical values that
// will change often during the match, such as game pieces scored
class BearScoutsCounter extends StatefulWidget {
  // See the text field class for an explanation of what these are
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsCounter(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsCounterState();
}

// The state class for our counter
class _BearScoutsCounterState extends State<BearScoutsCounter> {
  // The text controller that will increment and decrement the counter
  final TextEditingController _textController = TextEditingController();
  // Counter variable for keeping track of what number we're at
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    // Use the initial value to set the counter
    _counter = int.tryParse(widget.initialValue) ?? 0;

    // Change the text controller to match what the initial value is
    _textController.text = _counter.toString();

    // This widget will always have a valid value
    widget.isValidWithValue(true, _counter.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            height: 58,
            // Counter decrement button
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_counter > 0) {
                    _counter--;
                  }
                  widget.isValidWithValue(true, _counter.toString());
                  // Update the text field to reflect the new value
                  _textController.text = _counter.toString();
                });
              },
              child: const Icon(
                Icons.arrow_left_sharp,
              ),
            ),
          ),
          Expanded(
            // The text field to display the current value
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: widget._configOptions[0],
                hintText: "Enter ${widget._configOptions[0]} Here",
                border: const OutlineInputBorder(),
              ),
              enabled: false,
            ),
          ),
          SizedBox(
            height: 58,
            // Counter increment button
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  // There is no need to do bounds checking here
                  _counter++;
                  widget.isValidWithValue(true, _counter.toString());
                  // Update the text field to reflect the new value
                  _textController.text = _counter.toString();
                });
              },
              child: const Icon(
                Icons.arrow_right_sharp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This is the class used for constructing multiple choice boxes. These should
// be used for data fields where there is a specific couple of choices. If
// there is a possibility for variety, it would be better to use a text field
class BearScoutsMultipleChoice extends StatefulWidget {
  // See text field for an explanation of these
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsMultipleChoice(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsMultipleChoiceState();
}

// The state class for the multiple choice box
class _BearScoutsMultipleChoiceState extends State<BearScoutsMultipleChoice> {
  // This list contains the various options that the user can choose
  List<String> _options = [];
  // This list contains the values that the user will see
  List<String> _hints = [];
  // This field contains the currently selected item for use in validation
  DropdownMenuItem<String>? _selectedItem;

  @override
  void initState() {
    super.initState();

    // Split and assign the options
    String optionString = widget._configOptions[3];
    _options = optionString.split(",");
    // Split and assign the hints 
    String hintString = widget._configOptions[4];
    _hints = hintString.split(",");

    // Try to set the initial value, if it does not exist in the array, set
    // the current item to the first item in the list. This field will also
    // always be valid, so make sure to set that too.
    if (widget.initialValue.isNotEmpty &&
        _options.contains(widget.initialValue)) {
      _selectedItem = DropdownMenuItem<String>(
        value: widget.initialValue,
        child: Text(_hints[_options.indexOf(widget.initialValue)]),
      );
      widget.isValidWithValue(true, widget.initialValue);
    } else {
      _selectedItem = DropdownMenuItem<String>(
        value: _options[0],
        child: Text(_hints[0]),
      );
      widget.isValidWithValue(true, _options[0]);
    }

    // Equalize the size of the lists so that we don't run into issues with
    // array index out of bounds errors. The user should put the same number
    // of items into the form creation, but if they don't this ensures the
    // app will still function
    if (_hints.length > _options.length) {
      while (_hints.length > _options.length) {
        _hints.removeLast();
      }

      // Tell the user that there was an issue with the configuration, but
      // continue operation like nothing happened
      Future.delayed(const Duration(milliseconds: 100), () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Insufficient options"),
            content: const Text(
              "There are too many options in the list for one of the multiple "
              "choice boxes. Contact your app administrator to resolve this.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      });
    // Same thing as above, just the other way around
    } else if (_hints.length < _options.length) {
      while (_options.length > _hints.length) {
        _options.removeLast();
      }

      Future.delayed(const Duration(milliseconds: 100), () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Insufficient hints"),
            content: const Text(
              "There are too many hints in the list for one of the multiple "
              "choice boxes. Contact your app administrator to resolve this.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF737375),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            // The label for the drop down menu
            Align(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  widget._configOptions[0],
                  style: Theme.of(context).textTheme.labelMedium?.merge(
                        const TextStyle(
                          color: Color(0xFF6e6d70),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              alignment: Alignment.centerLeft,
            ),
            // The actual drop down menu
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: List<DropdownMenuItem<String>>.generate(
                  _options.length,
                  (index) => DropdownMenuItem<String>(
                    child: Text(_hints[index]),
                    value: _options[index],
                  ),
                ),
                onChanged: (String? value) {
                  // set state to actually change the selected item
                  setState(() {
                    _selectedItem = DropdownMenuItem<String>(
                      value: value,
                      child:
                          Text(_hints[_options.indexOf(value ?? _options[0])]),
                    );
                    widget.isValidWithValue(true, value ?? "");
                  });
                },
                value: _selectedItem?.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The stopwatch class is used for anything involving precise timing.
class BearScoutsStopwatch extends StatefulWidget {
  // See text field for an explanation of these items
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsStopwatch(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsStopwatchState();
}

// The state class for the stop watch
class _BearScoutsStopwatchState extends State<BearScoutsStopwatch> {
  // Text controller for making the stopwatch display the time
  final TextEditingController _textController = TextEditingController();
  // A built in stopwatch class that we will use to keep track of time
  final Stopwatch _stopwatch = Stopwatch();
  // The timer to ensure that we update the display
  Timer? updateTimer;
  // Boolean to tell us if the stopwatch is running or not
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();

    // Try to set it to an initial value, and if not, set it to zero
    _textController.text =
        widget.initialValue.isEmpty ? "0.0" : widget.initialValue;

    // This field will always be valid
    widget.isValidWithValue(true, widget.initialValue);

    // Write the values to the database every 500 ms, just in case the 
    // user doesn't stop the stopwatch before exiting the page
    Timer(const Duration(milliseconds: 500), () {
      widget.isValidWithValue(
        true,
        (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // The text field displaying the time
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: widget._configOptions[0],
                border: const OutlineInputBorder(),
              ),
              enabled: false,
            ),
          ),
          // This is the start/stop button, and will change based on the
          // current status of the timer
          SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_isRunning) {
                    _stopwatch.stop();
                    _isRunning = false;
                    updateTimer?.cancel();
                  } else {
                    _stopwatch.start();
                    _isRunning = true;
                    updateTimer = Timer.periodic(
                      const Duration(milliseconds: 37),
                      (Timer timer) {
                        setState(() {
                          _textController.text =
                              (_stopwatch.elapsed.inMilliseconds / 1000.0)
                                  .toString();
                        });
                      },
                    );
                  }
                });
              },
              child: _isRunning
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
            ),
          ),
          // Reset button
          SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_isRunning) {
                    _stopwatch.stop();
                    _isRunning = false;
                    updateTimer?.cancel();

                    _textController.text = "0.0";
                  } else {
                    updateTimer?.cancel();
                    _textController.text = "0.0";
                  }
                });
              },
              child: const Icon(Icons.restart_alt),
            ),
          ),
        ],
      ),
    );
  }
}

class BearScoutsDisplayImage extends StatefulWidget {
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsDisplayImage(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsDisplayImageState();
}

class _BearScoutsDisplayImageState extends State<BearScoutsDisplayImage> {
  @override
  void initState() {
    super.initState();

    widget.isValidWithValue(true, "");
  }

  @override
  Widget build(BuildContext context) {
    if (widget._configOptions[3].contains("assets/")) {
      return Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            widget._configOptions[3],
            fit: BoxFit.contain,
            height: 200,
            bundle: rootBundle,
          ));
    } else {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Image.file(
          File(widget._configOptions[3]),
          fit: BoxFit.contain,
          height: 200,
        ),
      );
    }
  }
}

class BearScoutsHeading extends StatefulWidget {
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsHeading(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsHeadingState();
}

class _BearScoutsHeadingState extends State<BearScoutsHeading> {
  @override
  void initState() {
    super.initState();

    widget.isValidWithValue(true, "");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          widget._configOptions[0],
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
    );
  }
}

class BearScoutsSlider extends StatefulWidget {
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsSlider(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsSliderState();
}

class _BearScoutsSliderState extends State<BearScoutsSlider> {
  double _value = 0.0;

  @override
  void initState() {
    super.initState();

    _value = double.tryParse(widget.initialValue) ?? 0.0;

    widget.isValidWithValue(true, widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF737375),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  widget._configOptions[0],
                  style: Theme.of(context).textTheme.labelMedium?.merge(
                        const TextStyle(
                          color: Color(0xFF6e6d70),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
            ),
            Slider(
              value: _value,
              min: double.tryParse(widget._configOptions[3]) ?? 0.0,
              max: double.tryParse(widget._configOptions[4]) ?? 100.0,
              onChanged: (double value) {
                widget.isValidWithValue(true, value.toStringAsFixed(2));
                setState(() {
                  _value = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BearScoutsToggle extends StatefulWidget {
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsToggle(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsToggleState();
}

class _BearScoutsToggleState extends State<BearScoutsToggle> {
  bool _value = false;

  @override
  void initState() {
    super.initState();

    _value = widget.initialValue == "true";

    widget.isValidWithValue(true, _value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF737375),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  widget._configOptions[0],
                  style: Theme.of(context).textTheme.labelMedium?.merge(
                        const TextStyle(
                          color: Color(0xFF6e6d70),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
            ),
            Switch(
              value: _value,
              onChanged: (bool value) {
                widget.isValidWithValue(true, value.toString());
                setState(() {
                  _value = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BearScoutsHeatMap extends StatefulWidget {
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsHeatMap(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsHeatMapState();
}

class _BearScoutsHeatMapState extends State<BearScoutsHeatMap> {
  final _BearScoutsHeatMapPainter _painter2 = _BearScoutsHeatMapPainter();
  String currentValue = "";

  @override
  void initState() {
    super.initState();

    widget.isValidWithValue(true, widget.initialValue);

    if (widget._configOptions[3].toString().contains("assets/")) {
      _loadImageFromAssets(widget._configOptions[3]).then((image) {
        setState(() {
          _painter2.clearHeatmapPoints();
          _painter2.setImage(image);
          _painter2.addAllPoints(widget.initialValue.split("|"));
        });
      });
    } else if (widget._configOptions[3].toString().isEmpty ||
        widget._configOptions[3].toString().toLowerCase() == "null") {
      _loadImageFromAssets("assets/field_image.png").then((image) {
        setState(() {
          _painter2.clearHeatmapPoints();
          _painter2.setImage(image);
          _painter2.addAllPoints(widget.initialValue.split("|"));
        });
      });
    } else {
      _loadImageFromFilesystem(widget._configOptions[3]).then((image) {
        setState(() {
          _painter2.clearHeatmapPoints();
          _painter2.setImage(image);
          _painter2.addAllPoints(widget.initialValue.split("|"));
        });
      });
    }
    currentValue = widget.initialValue;
  }

  String _offsetToString(ui.Offset offset) {
    double x = offset.dx / _painter2.width * 54.0;
    double y = offset.dy / _painter2.height * 26.5;
    return '(${x.toStringAsFixed(1)},${y.toStringAsFixed(1)})';
  }

  Future<ui.Image> _loadImageFromAssets(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return await _loadUIImageFromUint8List(bytes.buffer.asUint8List());
  }

  Future<ui.Image> _loadImageFromFilesystem(String path) async {
    return await _loadUIImageFromUint8List(await File(path).readAsBytes());
  }

  Future<ui.Image> _loadUIImageFromUint8List(Uint8List data) async {
    var immutableImageBuffer = await ui.ImmutableBuffer.fromUint8List(data);
    var imageDesc = await ui.ImageDescriptor.encoded(immutableImageBuffer);
    var codec = await imageDesc.instantiateCodec(
      targetWidth: MediaQuery.of(context).size.width.toInt() - 40,
    );
    var frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF737375),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget._configOptions[0],
                      style: Theme.of(context).textTheme.labelMedium?.merge(
                            const TextStyle(
                              color: Color(0xFF6e6d70),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _painter2.undoLastHeatmapPoint();
                  },
                  icon: const Icon(Icons.undo),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            GestureDetector(
              onTapDown: (details) {
                currentValue += _offsetToString(details.localPosition) + "|";
                widget.isValidWithValue(true, currentValue);

                setState(() {
                  _painter2.addHeatmapPoint(details.localPosition);
                });
              },
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  child: CustomPaint(
                    painter: _painter2,
                  ),
                  width: _painter2.width.toDouble(),
                  height: _painter2.height.toDouble() > 0
                      ? _painter2.height.toDouble() + 20
                      : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BearScoutsHeatMapPainter extends ChangeNotifier
    implements CustomPainter {
  ui.Image? _backgroundImage;
  final List<ui.Offset> _heatmapPoints = [];

  void addAllPoints(List<String> points) {
    for (var point in points) {
      if (point.isNotEmpty) {
        point = point.substring(1, point.length - 1);
        addHeatmapPoint(ui.Offset(
          double.parse(point.split(",")[0]) / 54.0 * width,
          double.parse(point.split(",")[1]) / 26.5 * height,
        ));
      }
    }
  }

  void addHeatmapPoint(ui.Offset point) {
    _heatmapPoints.add(point);
    notifyListeners();
  }

  void undoLastHeatmapPoint() {
    _heatmapPoints.removeLast();
    notifyListeners();
  }

  void clearHeatmapPoints() {
    _heatmapPoints.clear();
    notifyListeners();
  }

  void setImage(ui.Image image) {
    _backgroundImage = image;
  }

  int get width => _backgroundImage?.width ?? 0;
  int get height => _backgroundImage?.height ?? 0;

  @override
  bool? hitTest(ui.Offset position) => true;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (_backgroundImage == null) {
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..color = const ui.Color(0xFF1C1B1F),
    );
    canvas.drawImage(_backgroundImage!, Offset.zero, ui.Paint());

    for (ui.Offset point in _heatmapPoints) {
      canvas.drawCircle(
        point,
        20,
        ui.Paint()
          ..shader = const RadialGradient(
            colors: [
              ui.Color(0xFFFF0000),
              ui.Color(0x00FF0000),
            ],
          ).createShader(Rect.fromCircle(
            center: point,
            radius: 20,
          )),
      );
    }
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder {
    return (Size size) {
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
          properties: const SemanticsProperties(
            label: 'Heatmap',
            textDirection: TextDirection.ltr,
          ),
        )
      ];
    };
  }

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => true;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
