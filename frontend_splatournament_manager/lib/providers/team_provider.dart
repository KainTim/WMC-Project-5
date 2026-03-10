import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/services/team_service.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService = TeamService();

  List<Team> _teams = [];
  List<Team> get teams => _teams;

  Future<List<Team>> fetchAllTeams() async {
    _teams = await _teamService.getAllTeams();
    notifyListeners();
    return _teams;
  }

  Future<Team> createTeam({
    required String name,
    required String tag,
    String description = '',
  }) async {
    final team = await _teamService.createTeam(
      name: name,
      tag: tag,
      description: description,
    );
    _teams = [..._teams, team];
    notifyListeners();
    return team;
  }

  Future<void> updateTeam(
    int id, {
    String? name,
    String? tag,
    String? description,
  }) async {
    await _teamService.updateTeam(id, name: name, tag: tag, description: description);
    await fetchAllTeams();
  }

  Future<void> deleteTeam(int id) async {
    await _teamService.deleteTeam(id);
    _teams = _teams.where((t) => t.id != id).toList();
    notifyListeners();
  }

  Future<List<Team>> getTeamsByTournament(int tournamentId) async {
    return _teamService.getTeamsByTournament(tournamentId);
  }

  Future<void> registerTeamForTournament(int tournamentId, int teamId) async {
    await _teamService.registerTeamForTournament(tournamentId, teamId);
    notifyListeners();
  }

  Future<void> removeTeamFromTournament(int tournamentId, int teamId) async {
    await _teamService.removeTeamFromTournament(tournamentId, teamId);
    notifyListeners();
  }
}

