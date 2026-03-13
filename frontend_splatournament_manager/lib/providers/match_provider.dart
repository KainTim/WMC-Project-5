import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/match.dart';
import 'package:frontend_splatournament_manager/services/api_client.dart';

class MatchProvider extends ChangeNotifier {
  Future<void> initializeBracket(int tournamentId) async {
    final response = await ApiClient.post(
      '/tournaments/$tournamentId/bracket',
      {},
    );

    if (response.statusCode != HttpStatus.created) {
      throw Exception(
        'Turnierbaum konnte nicht initialisiert werden (${response.statusCode})',
      );
    }

    notifyListeners();
  }

  Future<List<Match>> getMatchesByTournament(int tournamentId) async {
    final response = await ApiClient.get('/tournaments/$tournamentId/matches');

    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Matches konnten nicht geladen werden (${response.statusCode})',
      );
    }

    final List<dynamic> list = json.decode(response.body);
    return list.map((json) => Match.fromJson(json)).toList();
  }

  Future<void> setMatchWinner(int matchId, int winnerId) async {
    final response = await ApiClient.put('/matches/$matchId/winner', {
      'winnerId': winnerId,
    });

    if (response.statusCode != HttpStatus.ok) {
      final error = json.decode(response.body);
      throw Exception(
        error['error'] ?? 'Sieger konnte nicht festgelegt werden',
      );
    }

    notifyListeners();
  }

  Future<void> resetMatch(int matchId) async {
    final response = await ApiClient.delete('/matches/$matchId/winner');

    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Match konnte nicht zurückgesetzt werden (${response.statusCode})',
      );
    }

    notifyListeners();
  }
}
