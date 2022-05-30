import 'package:RustCompanion/utils/models.dart';
import 'package:flutter/material.dart';

class AddNewNotificationProvider with ChangeNotifier {
  Player? _selected_player;
  Player? get selected_player => _selected_player;
Server? _selected_server;
Server?  get selected_server => _selected_server;

  set_player(Player player) {
    _selected_player = player;
    notifyListeners();
  }
  set_server(Server server){
    _selected_server=server;
    notifyListeners();
  }
}
