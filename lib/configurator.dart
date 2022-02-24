import 'dart:convert';

import 'package:flutter/services.dart';

class Configurator {
  static Configurator? _instance;

  List _data = [];

  Configurator._();

  static Configurator getInstance() {
    _instance ??= Configurator._();
    return _instance!;
  }

  Future<void> readConfigJson() async {
    rootBundle.loadString("assets/config.json").then((response) {
      _data = json.decode(response);
    });
  }

  List getEntireData() {
    return _data;
  }

  Map getSection(int index) {
    return _data[index];
  }

  int getListLength() {
    return _data.length;
  }
}
