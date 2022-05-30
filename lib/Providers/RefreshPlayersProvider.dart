import 'package:flutter/cupertino.dart';

class RefreshPlayersProvider with ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
