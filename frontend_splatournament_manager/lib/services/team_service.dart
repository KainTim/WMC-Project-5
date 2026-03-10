import 'dart:convert';
import 'dart:io';

import 'package:frontend_splatournament_manager/main.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:http/http.dart' as http;

class TeamService {
  final String baseUrl = SplatournamentApp.baseUrl;

  Future<List<Team>> getAllTeams() async {
    final response = await http.get(Uri.parse('$baseUrl/teams'));
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load teams (${response.statusCode})');
    }
    final List<dynamic> list = json.decode(response.body);
    return list.map((j) => Team.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Team> getTeamById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/teams/$id'));
    if (response.statusCode == HttpStatus.notFound) {
      throw Exception('Team not found');
    }
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load team (${response.statusCode})');
    }
    return Team.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Team> createTeam({
    required String name,
    required String tag,
    String description = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'tag': tag, 'description': description}),
    );
    if (response.statusCode != HttpStatus.created) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to create team');
    }
    return Team.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> updateTeam(
    int id, {
    String? name,
    String? tag,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/teams/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': ?name,
        'tag': ?tag,
        'description': ?description,
      }),
    );
    if (response.statusCode != HttpStatus.ok) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to update team');
    }
  }

  Future<void> deleteTeam(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/teams/$id'));
    if (response.statusCode != HttpStatus.ok) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to delete team');
    }
  }

  Future<List<Team>> getTeamsByTournament(int tournamentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tournaments/$tournamentId/teams'),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Failed to load teams for tournament (${response.statusCode})',
      );
    }
    final List<dynamic> list = json.decode(response.body);
    return list.map((j) => Team.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> registerTeamForTournament(int tournamentId, int teamId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tournaments/$tournamentId/teams'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'teamId': teamId}),
    );
    if (response.statusCode == 409) {
      throw Exception('Team is already registered for this tournament');
    }
    if (response.statusCode != HttpStatus.created) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to register team');
    }
  }

  Future<void> removeTeamFromTournament(int tournamentId, int teamId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tournaments/$tournamentId/teams/$teamId'),
    );
    if (response.statusCode != HttpStatus.ok) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to remove team from tournament');
    }
  }

  Future<List<Map<String, dynamic>>> getTournamentsByTeam(int teamId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teams/$teamId/tournaments'),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Failed to load tournaments for team (${response.statusCode})',
      );
    }
    final List<dynamic> list = json.decode(response.body);
    return list.cast<Map<String, dynamic>>();
  }
}
