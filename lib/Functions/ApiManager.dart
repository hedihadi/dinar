import 'dart:async';
import 'dart:convert';
import 'package:RustCompanion/Providers/PlayersProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/src/provider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/utils/models.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ApiManager {
  Future<void> getFavoritedServers(BuildContext context) async {
    final favorited_servers = context.read<ServersProvider>().favorited_servers;
    //run code for each favorited server
    for (var favorited_server in favorited_servers) {
      //wait for a moment to avoid hitting max requests
      //request server info
      http.Response response = await http.get(Uri.parse("https://api.battlemetrics.com/servers/$favorited_server"));
      //parse data
      Map<String, dynamic> raw_json = jsonDecode(response.body);
      //check if API has returned an error or not
      if (raw_json.containsKey("errors")) {
        //if an error, send the error info to the stream so the widgets can deal with it.
      } else {
        //if no error, send server data to the stream
        Server server = Server();
        server.fetchData(raw_json["data"]);
        context.read<ServersProvider>().add_server(server);
      }
    }
  }

  Future<Server?> getServerInfo(int id) async {
    http.Response response = await http.get(Uri.parse('https://api.battlemetrics.com/servers/$id'));
    Map<String, dynamic> raw_jsons = jsonDecode(response.body);
    if (raw_jsons.containsKey("errors")) {
      return null;
    } else {
      Server server = Server();
      server.fetchData(raw_jsons["data"]);
      return server;
    }
  }

  Future<void> searchServers(String name, Map<ServerType, bool> server_types, Map<WipeType, bool> wipe_types, int minimum_players,
      int maximum_players, int key, StreamController<Response> controller, BuildContext context) async {
    List<Server> servers = [];

    final prefs = await SharedPreferences.getInstance();
    final favorited_servers = context.read<ServersProvider>().favorited_servers;

    http.Response response = await http
        .get(Uri.parse('https://api.battlemetrics.com/servers?filter[search]="$name"&filter[game]=rust&filter[status]=online&sort=players'));
    Map<String, dynamic> raw_jsons = jsonDecode(response.body);
    if (raw_jsons.containsKey("errors")) {
      return;
    }

    int a = raw_jsons["data"].length;
    for (Map<String, dynamic> raw_json in raw_jsons["data"]) {
      Server server = Server();
      server.fetchData(raw_json);
      if (server_types[server.type] == false) continue;
      if (wipe_types[server.wipe_type] == false) continue;
      if (server.players < minimum_players) continue;
      if (server.players > maximum_players) continue;
      Response response = Response(server: server, key: key);
      if (favorited_servers.contains(server.id)) {
        server.favorited = true;
      }
      response.server = server;
      response.key = key;
      controller.sink.add(response);
    }
  }

  Future<void> getFavoritedPlayers(BuildContext context) async {
    final favorited_players = context.read<PlayersProvider>().favorited_players;
    for (var favorited_player in favorited_players) {
      Player? player = await getPlayerInfo(favorited_player);
      if (player == null) {
        continue;
      }
      context.read<PlayersProvider>().add_player(player);
    }
  }

  Future<Player?> getPlayerInfo(int id) async {
    http.Response response = await http.get(Uri.parse('https://api.battlemetrics.com/players/$id'));
    Map<String, dynamic> raw_jsons = jsonDecode(response.body);
    if (raw_jsons.containsKey("errors")) {
      print(raw_jsons["errors"]);
      return null;
    } else {
      Player player = Player();
      player.fetchData(raw_jsons["data"]);
      List<Session> sessions = await _getPlayerSessions(id);
      if (sessions.length > 0) {
        final aa = sessions.first.stop;
        if (sessions.first.stop == null) {
          player.online = true;
          player.playing_since = sessions.first.start;
        }
      }
      player.sessions = sessions;
      return player;
    }
  }

  ///this function checks if a player is online
  ///by getting the sessions, if the first session's [stop] is null
  ///then it means they're currently playing at that server.
  Future<Server?> isPLayerOnline(int id) async {
    List<Session> sessions = await _getPlayerSessions(id);
    if (sessions.first.stop == null) {
      return sessions.first.server;
    }
  }

  Future<List<Player>> getPlayersFromServer(int server_id, BuildContext context) async {
    List<Player> players = [];
    http.Response response = await http.get(Uri.parse('https://api.battlemetrics.com/servers/$server_id?include=player'));
    Map<String, dynamic> raw_jsons = jsonDecode(response.body);
    if (raw_jsons.containsKey("errors")) {
      print(raw_jsons["error"]);
      return [];
    }
    for (Map<String, dynamic> raw_json in raw_jsons["included"]) {
      Player player = Player();
      player.fetchData(raw_json);
      //now get player's sessions
      //var sessions = await _getPlayerSessions(player.id);
      //player.sessions = sessions;
      //player.playing_since = player.sessions.first.start;
      player.favorited = context.read<PlayersProvider>().favorited_players.contains(player.id);

      players.add(player);
    }
    return players;
  }

  Future<void> searchPlayers(String name, int key, StreamController<PlayerResponse> controller, BuildContext context) async {
    http.Response response = await http.get(Uri.parse('https://api.battlemetrics.com/players?filter[search]="$name"&filter[server][game]=rust'));
    Map<String, dynamic> raw_jsons = jsonDecode(response.body);
    if (raw_jsons.containsKey("errors")) {
      return;
    }
    //foreach found player in the query
    for (Map<String, dynamic> raw_json in raw_jsons["data"]) {
      Player player = Player();
      player.fetchData(raw_json);
      //now get player's sessions
      var sessions = await _getPlayerSessions(player.id);
      player.sessions = sessions;
      var response = PlayerResponse(key: key, player: player);
      controller.sink.add(response);
    }
  }

  Future<List<Session>> _getPlayerSessions(int id) async {
    List<Session> sessions = [];
    http.Response response =
        await http.get(Uri.parse('https://api.battlemetrics.com/players/$id/relationships/sessions?include=server&page[size]=5'));
    Map<String, dynamic> raw_jsons = jsonDecode(response.body);
    if (raw_jsons.containsKey("errors")) {
      print(raw_jsons["errors"]);
      return [];
    }
    for (Map<String, dynamic> raw_json in raw_jsons["data"]) {
      int server_id = int.parse(raw_json["relationships"]["server"]["data"]["id"]);
      //skip session if it's not rust
      String game_name = List<Map<String, dynamic>>.from(raw_jsons["included"])
          .where((element) => int.parse(element["id"]) == server_id)
          .first["relationships"]["game"]["data"]["id"];
      if (game_name != "rust") {
        continue;
      }
      Server server = Server();

      server.fetchData(List<Map<String, dynamic>>.from(raw_jsons["included"]).where((element) => int.parse(element["id"]) == server_id).first);
      Session session = Session(
          id: raw_json["id"],
          server: server,
          start: DateTime.parse(raw_json["attributes"]["start"]),
          stop: raw_json["attributes"]["stop"] == null ? null : DateTime.parse(raw_json["attributes"]["stop"]));
      sessions.add(session);
    }
    return sessions;
  }
}
