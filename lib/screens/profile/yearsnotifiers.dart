import 'package:flutter/material.dart';
import 'package:thaartransport/screens/profile/yeardata.dart';

class singleNotifier extends ChangeNotifier {
  String _currentYear = years[0];
  // SingleNotifer();

  String get currentYear => _currentYear;

  updateYear(String value) {
    if (value != _currentYear) {
      _currentYear = value;
      notifyListeners();
    }
  }
}
