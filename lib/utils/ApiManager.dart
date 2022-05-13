import 'dart:async';
import 'dart:convert';

import 'package:rustwipe/utils/models.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//this class communicates with the battlemtrics api
class ApiManager {
  ApiManager({required this.controller});
  var controller;
  //this stream broadcasts newly acquired servers

  //get all servers
  Future<void> initGetServers() async {
    getServers(
        'https://api.battlemetrics.com/servers?filter[game]=rust&page[size]=100');
  }

  Future<void> getServers(String url) async {
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> raw_jsons = jsonDecode(response.body);
    if (raw_jsons.containsKey("errors")) {
      controller.sink.add(Response(
          response_type: ResponseType.error,
          details: raw_jsons["errors"][0]["details"],
          server: null));
      await Future.delayed(const Duration(seconds: 60));
      getServers(url);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    List<int> favorited_servers = [];
    List<int> warn_when_wipe_servers = [];

    favorited_servers =
        List<int>.from(jsonDecode(prefs.getString("favorites") ?? "[]"));
    warn_when_wipe_servers = List<int>.from(
        jsonDecode(prefs.getString("warn_when_wipe_servers") ?? "[]"));
    int a = raw_jsons["data"].length;
    for (Map<String, dynamic> raw_json in raw_jsons["data"]) {
      Server server = Server();
      server.fetchData(raw_json, favorited_servers, warn_when_wipe_servers);
      controller.sink.add(Response(
          response_type: ResponseType.server, server: server, details: null));
    }

    ///after we computed this link, we go to the next link.
    //check if we've reached the end
    print(raw_jsons["links"]["next"]);
    if (Map<String, dynamic>.from(raw_jsons["links"]).containsKey("next")) {
      getServers(raw_jsons["links"]["next"]);
    }
  }

//this function will periodically send updated server info
  Future<void> getFavoritedServers(SharedPreferences prefs) async {
    //now run this code every 2 seconds to update the server data
    List<int> favorited_servers = [];
    List<int> warn_when_wipe_servers = [];

//first retrieve the id of favorited servers
    favorited_servers = List<int>.from(
        jsonDecode(prefs.getString("favorited_servers") ?? "[]"));
    warn_when_wipe_servers = List<int>.from(
        jsonDecode(prefs.getString("warn_when_wipe_servers") ?? "[]"));
    print("yooo $favorited_servers");

    for (var favorited_server in favorited_servers) {
      await Future.delayed(const Duration(milliseconds: 500));

      http.Response response = await http.get(
          Uri.parse("https://api.battlemetrics.com/servers/$favorited_server"));
      Map<String, dynamic> raw_json = jsonDecode(response.body);
      if (raw_json.containsKey("errors")) {
        controller.sink.add(Response(
            response_type: ResponseType.error,
            server: null,
            details: raw_json["errors"][0]["detail"]));
      } else {
        Server server = Server();
        server.fetchData(
            raw_json["data"], favorited_servers, warn_when_wipe_servers);
        controller.sink.add(Response(
            response_type: ResponseType.server, server: server, details: null));
      }
    }
  }
}
