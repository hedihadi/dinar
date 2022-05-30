import 'dart:convert';
import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/utils.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ServerType { official, modded, community }
enum WipeType { weekly, biweekly, monthly }
enum NotificationType { PlayerComesOnline, PlayerGoesOffline, ServerWipes, PlayerJoinServer, PlayerLeaveServer }
enum PlayerLeaveOrJoin { Leave, Join }
enum SortBy {Players,LastWipe,NextWipe,Name}
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
  ServerType type = ServerType.community;
  String header_image = "";
  String url = "";
  String description = "default";
  int queued_players = 0;
  WipeType wipe_type = WipeType.weekly;
  DateTime last_wipe = DateTime(2002);
  DateTime next_wipe = DateTime(2055);
  DateTime lastupdate = DateTime.now();
  String country = "default";
  fetchData(Map<String, dynamic> data) {
    this.id = int.parse(data["id"]);
    this.name = data["attributes"]["name"];
    this.ip = data["attributes"]["ip"];
    this.port = data["attributes"]["port"];
    this.players = data["attributes"]["players"];
    this.max_players = data["attributes"]["maxPlayers"];
    this.rank = data["attributes"]["rank"];
    this.location = List<num>.from(data["attributes"]?["location"]);
    this.description = data["attributes"]["details"]["rust_description"];
    this.queued_players = data["attributes"]["details"]["rust_queued_players"];
    this.type = rustType_to_enum(data["attributes"]["details"]["rust_type"]);
    this.url = data["attributes"]["details"]["rust_url"];
    this.header_image = data["attributes"]["details"]["rust_headerimage"];
    this.last_wipe = DateTime.parse(data["attributes"]["details"]["rust_last_wipe"]);

    ///determine what the [WipeType] is
    if (this.name.toLowerCase().contains("monthly") || this.name.toLowerCase().contains("long")) {
      this.wipe_type = WipeType.monthly;
      this.next_wipe = this.last_wipe.add(Duration(days: 30));
    } else if (this.name.toLowerCase().contains("2 weeks") || this.name.toLowerCase().contains("biweek")) {
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

class Player {
  int id = 0;
  String name = "";
  bool private = false;
  List<Session> sessions = [];
  bool favorited = false;
  DateTime playing_since = DateTime(2002);
  bool online = false;
  DateTime lastupdate = DateTime.now();

  fetchData(Map<String, dynamic> data) {
    id = int.parse(data["id"]);
    name = data["attributes"]["name"];
    private = data["attributes"]["private"];
  }
}

class Session {
  Session({required this.id, required this.server, required this.start, required this.stop});
  String id;
  Server server;
  DateTime start;
  DateTime? stop;
}

class PlayerResponse {
  PlayerResponse({required this.player, required this.key});
  Player? player;
  int key = 0;
}

class Response {
  Response({required this.server, required this.key});
  Server? server;
  int key = 0;
}

class NotificationModel {
  NotificationModel(NotificationType notification_type) {
    this.notification_type = notification_type;
    switch (notification_type) {
      case NotificationType.PlayerComesOnline:
        color = ColorManager().tag1;
        break;
      case NotificationType.PlayerGoesOffline:
        color = ColorManager().tag2;
        break;
      case NotificationType.ServerWipes:
        color = ColorManager().tag3;
        break;
      case NotificationType.PlayerJoinServer:
        color = ColorManager().tag4;
        break;
      case NotificationType.PlayerLeaveServer:
        color = ColorManager().tag5;
        break;
    }
  }
  int? id;
  NotificationType notification_type = NotificationType.ServerWipes;
  Server? server;
  Player? player;
  Color? color;
  bool enabled = true;
  DateTime? server_last_wipe;
  DateTime? player_last_online;
  String session_id = "";
  toJson() {
    Map<String, dynamic> a = {};
    a["id"] = id;
    a["notification_type"] = notification_type.toString();
    a["enabled"] = enabled;
    a["session_id"] = session_id;
    if (server != null) {
      a["server_id"] = server!.id;
      a["server_last_wipe"] = server!.last_wipe.millisecondsSinceEpoch;
    }
    if (player != null) {
      a["player_id"] = player!.id;
      a["player_last_online"] = player!.sessions.first.start.millisecondsSinceEpoch;
    }
    return a;
  }
}
