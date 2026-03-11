import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/services/team_service.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService = TeamService();

  List<Team> _teams = [];
  Future<List<Team>>? _initialLoadFuture;

  List<Team> get teams => _teams;

  Future<List<Team>> fetchAllTeams() async {
    _teams = await _teamService.getAllTeams();
    notifyListeners();
    return _teams;
  }

  Future<List<Team>> ensureTeamsLoaded() {
    _initialLoadFuture ??= fetchAllTeams();
    return _initialLoadFuture!;
  }

  Future<List<Team>> refreshTeams() {
    _initialLoadFuture = fetchAllTeams();
    return _initialLoadFuture!;
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
    await refreshTeams();
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

  Future<List<Team>> getUserTeams() {
    return _teamService.getUserTeams();
  }

  Future<void> joinTeam(int teamId) async {
    await _teamService.joinTeam(teamId);
    notifyListeners();
  }

  Future<void> leaveTeam(int teamId) async {
    await _teamService.leaveTeam(teamId);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) {
    return _teamService.getTeamMembers(teamId);
  }

  Future<List<Map<String, dynamic>>> getMyTeamsTournaments() async {
    final userTeams = await getUserTeams();
    final Set<Map<String, dynamic>> tournamentsSet = {};
    
    for (final team in userTeams) {
      try {
        final tournaments = await _teamService.getTournamentsByTeam(team.id);
        tournamentsSet.addAll(tournaments);
      } catch (e) {
        // If a team has no tournaments, continue with others
      }
    }
    
    return tournamentsSet.toList();
  }
}

