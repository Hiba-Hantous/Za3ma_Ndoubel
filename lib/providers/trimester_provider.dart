import 'package:flutter/material.dart';

class TrimesterProvider extends ChangeNotifier {
  int _trimester = 1;

  int get trimester => _trimester;

  void setTrimester(int t) {
    if (_trimester == t) return;
    _trimester = t;
    notifyListeners();
  }
}
