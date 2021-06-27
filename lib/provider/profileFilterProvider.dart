import 'package:flutter/material.dart';

class ProfileFilterProvider extends ChangeNotifier {
  bool _isFilterOn = false;
  List<String> _filterBy =[];

  bool get getFilterStatus => _isFilterOn;
  List<String> get getFilterBy => _filterBy;

  setFilterStatus(bool v) {
    _isFilterOn = v;
    notifyListeners();
  }
  setFilterBy(List<String> v) {
    _filterBy=v;
    notifyListeners();
  }

}