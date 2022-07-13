import 'package:flutter/material.dart';

class SearchModel with ChangeNotifier {
  String _searchString = '';
  String get searchString => _searchString;

  set searchString(String value) {
    _searchString = value;
    notifyListeners();
  }
}