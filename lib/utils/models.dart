import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ServerType { official, modded, community }
enum ResponseType { server, error }
enum WipeType { weekly, biweekly, monthly }

class Server {
  int id = 0;
  String name = "default";
  String ip = "default";
  int port = 0;
  int players = 0;
  int max_players = 0;
  int rank = 0;
  bool warn_when_wipe = false;
  bool favorited = false;
  List<num> location = [0, 0];
  bool official = false;
  ServerType type = ServerType.community;
  String header_image = "";
  String url = "";
  String description = "default";
  int queued_players = 0;
  WipeType wipe_type = WipeType.weekly;
  DateTime last_wipe = DateTime(2002);
  DateTime next_wipe = DateTime(2055);
  String country = "default";
  fetchData(Map<String, dynamic> data, List<int> favorited_servers,
      List<int> warn_when_wipe_servers) {
    this.id = int.parse(data["id"]);
    this.favorited = favorited_servers.contains(this.id);
    this.warn_when_wipe = warn_when_wipe_servers.contains(this.id);

    this.name = data["attributes"]["name"];
    this.ip = data["attributes"]["ip"];
    this.port = data["attributes"]["port"];
    this.players = data["attributes"]["players"];
    this.max_players = data["attributes"]["maxPlayers"];
    this.rank = data["attributes"]["rank"];
    this.location = List<num>.from(data["attributes"]["location"]);
    this.official = data["attributes"]["details"]["official"];
    this.description = data["attributes"]["details"]["rust_description"];
    this.queued_players = data["attributes"]["details"]["rust_queued_players"];
    this.type = rustType_to_enum(data["attributes"]["details"]["rust_type"]);
    this.url = data["attributes"]["details"]["rust_url"];
    this.header_image = data["attributes"]["details"]["rust_headerimage"];
    this.last_wipe =
        DateTime.parse(data["attributes"]["details"]["rust_last_wipe"]);

    ///determine what the [WipeType] is
    if (this.name.toLowerCase().contains("monthly") ||
        this.name.toLowerCase().contains("long")) {
      this.wipe_type = WipeType.monthly;
      this.next_wipe = this.last_wipe.add(Duration(days: 30));
    } else if (this.name.toLowerCase().contains("2 weeks") ||
        this.name.toLowerCase().contains("biweek")) {
      this.wipe_type = WipeType.biweekly;
      this.next_wipe = this.last_wipe.add(Duration(days: 14));
    } else {
      this.wipe_type = WipeType.weekly;
      this.next_wipe = this.last_wipe.add(Duration(days: 7));
    }
  }

  rustType_to_enum(String rust_type) {
    switch (rust_type) {
      case "modded":
        return ServerType.modded;
      case "community":
        return ServerType.community;
      case "official":
        return ServerType.official;
    }
  }
}

class Response {
  Response(
      {required this.response_type,
      required this.server,
      required this.details});
  ResponseType response_type;
  String? details;
  Server? server;
}
