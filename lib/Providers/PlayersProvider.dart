import 'dart:convert';

import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayersProvider with ChangeNotifier {
  List<int> _favorited_players = [];
  List<Player> _players = [];
  List<Player> get players => _players;
  List<int> get favorited_players => _favorited_players;

  ///check if [_players] already contain this player.
  ///if yes, the player will be updated instead of added.
  add_player(Player player) {
    List<int> players = _players.map((e) => e.id).toList();
    if (players.contains(player.id)) {
      // _players[_players.indexWhere((element) => element.id == player.id)] = player;
      for (int i = 0; i < _players.length; i++) {
        if (_players[i].id == player.id) {
          if (_favorited_players.contains(player.id)) {
            player.favorited = true;
          }
          _players[i] = player;
        }
      }
    } else {
      if (_favorited_players.contains(player.id)) {
        player.favorited = true;
      }
      _players.add(player);
    }
    notifyListeners();
  }

  remove_player(int id) {
    List<int> players = _players.map((e) => e.id).toList();
    if (players.contains(id)) {
      _players.removeAt(_players.indexWhere((element) => element.id == id));
    }
    notifyListeners();
  }

  set_favorited_players(List<int> favorited_players) {
    _favorited_players = favorited_players;
    notifyListeners();
  }

  add_favorited_player(int id) async {
    _favorited_players.add(id);
    final player = await ApiManager().getPlayerInfo(id);
    if (player != null) {
      player.favorited = _favorited_players.contains(player.id);
      add_player(player);
    } else {
      notifyListeners();
    }
    //save changes to local storage
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("favorited_players", jsonEncode(_favorited_players));

        if (await LocalStorageManager().is_collect_data_enabled()) {
      await FirebaseAnalytics.instance.logEvent(
        name: "player_favorited",
        parameters: {
          "playerid": "$id",
        },
      );
    }
  }

  remove_favorited_player(int id) async {
    if (_favorited_players.contains(id)) {
      _favorited_players.removeAt(_favorited_players.indexWhere((element) => element == id));
    }
    remove_player(id);
    //save changes to local storage
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("favorited_players", jsonEncode(_favorited_players));

        if (await LocalStorageManager().is_collect_data_enabled()) {
      await FirebaseAnalytics.instance.logEvent(
        name: "player_unfavorited",
        parameters: {
          "playerid": "$id",
        },
      );
    }
  }
}
