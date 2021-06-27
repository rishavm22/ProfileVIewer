import 'package:flutter/material.dart';

class ListFilterProvider extends ChangeNotifier {
  RangeValues ageLimit=RangeValues(18, 60);
  String interest='';
  int _limit=3;

  RangeValues get getAgeLimit => ageLimit;

  void setAgeLimit(RangeValues v){
    ageLimit=v;
    notifyListeners();
  }

  String get getInterest => interest;

  void setInterest(String v){
    interest=v;
    notifyListeners();
  }

  int get getListLimit => _limit;

  void increaseListLimit(int v){
    Future.delayed(Duration(milliseconds: 1000), () {
      _limit= _limit+v;
    });
    notifyListeners();
  }

}