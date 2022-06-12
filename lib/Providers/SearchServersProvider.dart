import 'dart:convert';

import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchServersProvider with ChangeNotifier {
  List<Server> _servers = [];
  List<Server> get servers => _servers;
  List<Server> _filtered_servers = [];
  List<Server> get filtered_servers => _filtered_servers;

  addServers(List<Server> servers_temp) {
    _servers.addAll(servers_temp);
    notifyListeners();
  }

  Future<void> sort_servers(SortBy sort_by, bool descending, bool hide_non_wiping_servers) async {
    //first clear and initiate the filtered servers
    _filtered_servers.clear();
    //now filter the servers
    if (hide_non_wiping_servers == true) {
      _servers.forEach((_server) {
        if (_server.next_wipe.compareTo(DateTime.now()) != -1) {
          _filtered_servers.add(_server);
        }
      });
    } else {
      _filtered_servers.addAll(_servers);
    }
    if (sort_by == SortBy.Players && descending == true) {
      _filtered_servers.sort((b, a) => a.players.compareTo(b.players));
    } else if (sort_by == SortBy.Players && descending == false) {
      _filtered_servers.sort((a, b) => a.players.compareTo(b.players));
    } else if (sort_by == SortBy.LastWipe && descending == true) {
      _filtered_servers.sort((a, b) => a.last_wipe.compareTo(b.last_wipe));
    } else if (sort_by == SortBy.LastWipe && descending == false) {
      _filtered_servers.sort((b, a) => a.last_wipe.compareTo(b.last_wipe));
    } else if (sort_by == SortBy.NextWipe && descending == true) {
      _filtered_servers.sort((b, a) => a.next_wipe.compareTo(b.next_wipe));
    } else if (sort_by == SortBy.NextWipe && descending == false) {
      _filtered_servers.sort((a, b) => a.next_wipe.compareTo(b.next_wipe));
    }
    notifyListeners();
  }

  clear() {
    _servers.clear();
    _filtered_servers.clear();
  }
}
