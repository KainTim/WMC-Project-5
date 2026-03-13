import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/services/api_client.dart';

class TournamentProvider extends ChangeNotifier {
  List<Tournament> _availableTournaments = [];
  Future<List<Tournament>>? _initialLoadFuture;

  List<Tournament> get availableTournaments => _availableTournaments;

  Future<List<Tournament>> _fetchTournaments() async {
    final response = await ApiClient.get('/tournaments');
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Turniere konnten nicht geladen werden (${response.statusCode})',
      );
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

  Future<void> createTournament(
    String name,
    String description,
    int maxTeamAmount,
    DateTime registrationStartDate,
    DateTime registrationEndDate,
  ) async {
    final response = await ApiClient.post('/tournaments', {
      'name': name,
      'description': description,
      'maxTeamAmount': maxTeamAmount,
      'registrationStartDate': registrationStartDate.toIso8601String().split(
        'T',
      )[0],
      'registrationEndDate': registrationEndDate.toIso8601String().split(
        'T',
      )[0],
    });

    if (response.statusCode != HttpStatus.created) {
      throw Exception(
        'Turnier konnte nicht erstellt werden (${response.statusCode})',
      );
    }

    await refreshAvailableTournaments();
  }
}
