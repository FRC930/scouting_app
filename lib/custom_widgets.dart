import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bearscouts/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

Map<String, bool> validFields = {};

class BearScoutsDataWidget extends StatefulWidget {
  final List<String> datapoint;
  final bool isMatch;

  const BearScoutsDataWidget(
    this.datapoint,
    this.isMatch, {
    Key? key,
  }) : super(key: key);

  @override
  _BearScoutsDataWidgetState createState() => _BearScoutsDataWidgetState();
}

class _BearScoutsDataWidgetState extends State<BearScoutsDataWidget> {
  void onSave(bool valid, String value) {
    if (valid) {
      validFields[widget.datapoint[0]] = true;

      if (widget.isMatch) {
        DBManager.instance.setMatchDatapoint(
          widget.datapoint[0],
          value,
        );
      } else {
        DBManager.instance.setPitDatapoint(
          widget.datapoint[0],
          value,
        );
      }
    }
  }

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

    validFields[widget.datapoint[0]] = false;
  }

  @override
  void dispose() {
    super.dispose();

    validFields.remove(widget.datapoint[0]);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.datapoint[2]) {
      case "choice":
        return BearScoutsMultipleChoice(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      case "counter":
        return BearScoutsCounter(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      case "heading":
        return BearScoutsHeading(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      case "image":
        return BearScoutsDisplayImage(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      case "stopwatch":
        return BearScoutsStopwatch(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      case "toggle":
        return BearScoutsToggle(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      case "slider":
        return BearScoutsSlider(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
      case "heatmap":
        return BearScoutsHeatMap(
          widget.datapoint,
          onSave,
          getDatapoint(),
        );
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

class BearScoutsTextField extends StatefulWidget {
  final List<String> _configOptions;
  final String initialValue;
  final void Function(bool, String) isValidWithValue;

  const BearScoutsTextField(
      this._configOptions, this.isValidWithValue, this.initialValue,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BearScoutsTextFieldState();
}

class _BearScoutsTextFieldState extends State<BearScoutsTextField> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static final Map<String, RegExp> _validationRegexes = {
    "integer": RegExp(r"^[0-9]+$"),
    "decimal": RegExp(r"^[0-9]+(\.[0-9]+)?$"),
    "text": RegExp(r"^[a-zA-Z0-9,. ]+$"),
  };

  @override
  void initState() {
    super.initState();

    _textController.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType = TextInputType.text;
    if (widget._configOptions[3] == "integer") {
      keyboardType = TextInputType.number;
    } else if (widget._configOptions[3] == "decimal") {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    }

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
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}

class BearScoutsCounter extends StatefulWidget {
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

class _BearScoutsCounterState extends State<BearScoutsCounter> {
  final TextEditingController _textController = TextEditingController();
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    _counter = int.tryParse(widget.initialValue) ?? 0;

    _textController.text = _counter.toString();

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

class BearScoutsMultipleChoice extends StatefulWidget {
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

class _BearScoutsMultipleChoiceState extends State<BearScoutsMultipleChoice> {
  List<String> _options = [];
  List<String> _hints = [];
  DropdownMenuItem<String>? _selectedItem;

  @override
  void initState() {
    super.initState();

    String optionString = widget._configOptions[3];
    _options = optionString.split(",");
    String hintString = widget._configOptions[4];
    _hints = hintString.split(",");

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

    if (_hints.length > _options.length) {
      while (_hints.length > _options.length) {
        _hints.removeLast();
      }

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

class BearScoutsStopwatch extends StatefulWidget {
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

class _BearScoutsStopwatchState extends State<BearScoutsStopwatch> {
  final TextEditingController _textController = TextEditingController();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? updateTimer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();

    _textController.text =
        widget.initialValue.isEmpty ? "0.0" : widget.initialValue;

    widget.isValidWithValue(true, widget.initialValue);

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
