import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class TournamentProvider extends ChangeNotifier {
  final String baseUrl = SplatournamentApp.baseUrl;

  List<Tournament> _availableTournaments = [];
  Future<List<Tournament>>? _initialLoadFuture;

  List<Tournament> get availableTournaments => _availableTournaments;

  Future<List<Tournament>> _fetchTournaments() async {
    final response = await http.get(Uri.parse('$baseUrl/tournaments'));
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load tournaments (${response.statusCode})');
    }

    final List<dynamic> list = json.decode(response.body);
    return list.map((json) => Tournament.fromJson(json)).toList();
  }

  Future<List<Tournament>> fetchAvailableTournaments() async {
    _availableTournaments = await _fetchTournaments();
    notifyListeners();
    return _availableTournaments;
  }

  Future<List<Tournament>> ensureTournamentsLoaded() {
    _initialLoadFuture ??= fetchAvailableTournaments();
    return _initialLoadFuture!;
  }

  Future<List<Tournament>> refreshAvailableTournaments() {
    _initialLoadFuture = fetchAvailableTournaments();
    return _initialLoadFuture!;
  }
}