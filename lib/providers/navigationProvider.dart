import 'package:flutter/cupertino.dart';

class ProviderNavigation with ChangeNotifier {

  int _positionPage = 0;



  int get positionPage => _positionPage;

  set positionPage(int value) {
    _positionPage = value;
    notifyListeners();
  }
}