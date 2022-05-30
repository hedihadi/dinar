import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServersProvider with ChangeNotifier {
  List<int> _favorited_servers = [];
  List<Server> _servers = [];
  List<Server> get servers => _servers;
  List<int> get favorited_servers => _favorited_servers;

  ///check if [_servers] already contain this server.
  ///if yes, the server will be updated instead of added.
  add_server(Server server) {
    List<int> servers = _servers.map((e) => e.id).toList();
    if (servers.contains(server.id)) {
      // _servers[_servers.indexWhere((element) => element.id == server.id)] = server;
      for (int i = 0; i < _servers.length; i++) {
        if (_servers[i].id == server.id) {
          if (_favorited_servers.contains(server.id)) {
            server.favorited = true;
          }
          _servers[i] = server;
        }
      }
    } else {
      if (_favorited_servers.contains(server.id)) {
        server.favorited = true;
      }
      _servers.add(server);
    }
    notifyListeners();
  }

  remove_server(int id) {
    List<int> servers = _servers.map((e) => e.id).toList();
    if (servers.contains(id)) {
      _servers.removeAt(_servers.indexWhere((element) => element.id == id));
    }
    notifyListeners();
  }

  set_favorited_servers(List<int> favorited_servers) {
    _favorited_servers = favorited_servers;
    notifyListeners();
  }

  add_favorited_server(int id) async {
    _favorited_servers.add(id);
    final server = await ApiManager().getServerInfo(id);
    if (server != null) {
      add_server(server);
    } else {
      notifyListeners();
    }
    //save changes to local storage
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("favorited_servers", jsonEncode(_favorited_servers));
  }

  remove_favorited_server(int id) async {
    if (_favorited_servers.contains(id)) {
      _favorited_servers.removeAt(_favorited_servers.indexWhere((element) => id == id));
    }
    remove_server(id);
    //save changes to local storage
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("favorited_servers", jsonEncode(favorited_servers));
  }
}
