import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiManager {
  //static String databaseUrl = 'http://192.168.0.100:8000/api';
  static String databaseUrl = 'https://dinarapi.zalapp.com/api';

  static sendDataToDatabase(String route, {Map<String, dynamic> data = const {}}) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';

    final url = Uri.parse("$databaseUrl/$route");
    final body = jsonEncode(data);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    final response = await http.post(url, body: body, headers: headers);
    return response;
  }

  static Future<http.Response> getDataFromDatabase(String route, {Map<String, dynamic> queries = const {}, String? overridingUrl}) async {
    String url = '';
    if (overridingUrl == null) {
      url = "$databaseUrl/$route";
    } else {
      url = overridingUrl;
    }

    Stopwatch stopwatch = Stopwatch()..start();
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
    final response = await http.get(
      Uri.parse(url).replace(queryParameters: queries.map((key, value) => MapEntry(key, value.toString()))),
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (response.statusCode == 401) {
      throw Exception('Unauthorized, please login');
    }
    Logger().w('execution time for $route: ${stopwatch.elapsed.inSeconds}sec(s) ${response.request!.url}');
    if (response.statusCode == 500) {
      throw Exception(response.reasonPhrase);
    }
    return response;
  }
}
