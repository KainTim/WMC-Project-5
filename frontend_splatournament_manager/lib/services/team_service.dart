import 'dart:convert';
import 'dart:io';

import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/services/api_client.dart';

class TeamService {
  Future<List<Team>> getAllTeams() async {
    final response = await ApiClient.get('/teams');
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Teams konnten nicht geladen werden (${response.statusCode})',
      );
    }
    final List<dynamic> list = json.decode(response.body);
    return list.map((j) => Team.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Team> getTeamById(int id) async {
    final response = await ApiClient.get('/teams/$id');
    if (response.statusCode == HttpStatus.notFound) {
      throw Exception('Team nicht gefunden');
    }
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Team konnte nicht geladen werden (${response.statusCode})',
      );
    }
    return Team.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Team> createTeam({
    required String name,
    required String tag,
    String description = '',
  }) async {
    final response = await ApiClient.post('/teams', {
      'name': name,
      'tag': tag,
      'description': description,
    });
    if (response.statusCode != HttpStatus.created) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Team konnte nicht erstellt werden');
    }
    return Team.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> updateTeam(
    int id, {
    String? name,
    String? tag,
    String? description,
  }) async {
    final response = await ApiClient.put('/teams/$id', {
      'name': name,
      'tag': tag,
      'description': description,
    });
    if (response.statusCode != HttpStatus.ok) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Team konnte nicht aktualisiert werden');
    }
  }

  Future<void> deleteTeam(int id) async {
    final response = await ApiClient.delete('/teams/$id');
    if (response.statusCode != HttpStatus.ok) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Team konnte nicht gelöscht werden');
    }
  }

  Future<List<Team>> getTeamsByTournament(int tournamentId) async {
    final response = await ApiClient.get('/tournaments/$tournamentId/teams');
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Teams für das Turnier konnten nicht geladen werden (${response.statusCode})',
      );
    }
    final List<dynamic> list = json.decode(response.body);
    return list.map((j) => Team.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> registerTeamForTournament(int tournamentId, int teamId) async {
    final response = await ApiClient.post('/tournaments/$tournamentId/teams', {
      'teamId': teamId,
    });
    if (response.statusCode == 409) {
      throw Exception('Das Team ist bereits für dieses Turnier angemeldet');
    }
    if (response.statusCode != HttpStatus.created) {
      final body = json.decode(response.body);
      throw Exception(
        body['error'] ?? 'Team konnte nicht für das Turnier angemeldet werden',
      );
    }
  }

  Future<void> removeTeamFromTournament(int tournamentId, int teamId) async {
    final response = await ApiClient.delete(
      '/tournaments/$tournamentId/teams/$teamId',
    );
    if (response.statusCode != HttpStatus.ok) {
      final body = json.decode(response.body);
      throw Exception(
        body['error'] ?? 'Team konnte nicht aus dem Turnier entfernt werden',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getTournamentsByTeam(int teamId) async {
    final response = await ApiClient.get('/teams/$teamId/tournaments');
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Turniere für das Team konnten nicht geladen werden (${response.statusCode})',
      );
    }
    final List<dynamic> list = json.decode(response.body);
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Team>> getUserTeams() async {
    final response = await ApiClient.get('/users/me/teams');
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Eigene Teams konnten nicht geladen werden (${response.statusCode})',
      );
    }
    final List<dynamic> list = json.decode(response.body);
    return list.map((j) => Team.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> joinTeam(int teamId) async {
    final response = await ApiClient.post('/teams/$teamId/members', {});
    if (response.statusCode == 409) {
      throw Exception('Du bist bereits Mitglied dieses Teams');
    }
    if (response.statusCode != HttpStatus.created) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Beitritt zum Team fehlgeschlagen');
    }
  }

  Future<void> leaveTeam(int teamId) async {
    final response = await ApiClient.delete('/teams/$teamId/members/me');
    if (response.statusCode != HttpStatus.ok) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Team konnte nicht verlassen werden');
    }
  }

  Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) async {
    final response = await ApiClient.get('/teams/$teamId/members');
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Teammitglieder konnten nicht geladen werden (${response.statusCode})',
      );
    }
    final List<dynamic> list = json.decode(response.body);
    return list.cast<Map<String, dynamic>>();
  }
}
