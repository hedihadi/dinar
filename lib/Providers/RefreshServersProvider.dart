import 'package:flutter/cupertino.dart';

class RefreshServersProvider with ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
