import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:http/http.dart' as http;

class StateProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get theme => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  List<Tournament>? _availableTournaments;
  Future<List<Tournament>> fetchAvailableTournaments() async {
    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:3000/availableTournaments'));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);

        _availableTournaments = list.map((json) => Tournament.fromJson(json)).toList();
        return _availableTournaments!;
      }
    } catch (e) {
      print(e);
      _availableTournaments = null;
      return Future.error(e);
    }
    return[];
  }
  List<Tournament> get user => _availableTournaments ?? [];
}