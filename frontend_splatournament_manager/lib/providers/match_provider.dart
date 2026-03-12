import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/match.dart';
import 'package:frontend_splatournament_manager/services/api_client.dart';

class MatchProvider extends ChangeNotifier {
  Future<void> initializeBracket(int tournamentId) async {
    final response = await ApiClient.post('/tournaments/$tournamentId/bracket', {});
    
    if (response.statusCode != HttpStatus.created) {
      throw Exception('Failed to initialize bracket (${response.statusCode})');
    }
    
    notifyListeners();
  }

  Future<List<Match>> getMatchesByTournament(int tournamentId) async {
    final response = await ApiClient.get('/tournaments/$tournamentId/matches');
    
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load matches (${response.statusCode})');
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
      throw Exception(error['error'] ?? 'Failed to set winner');
    }
    
    notifyListeners();
  }

  Future<void> resetMatch(int matchId) async {
    final response = await ApiClient.delete('/matches/$matchId/winner');

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to reset match (${response.statusCode})');
    }
    
    notifyListeners();
  }
}
