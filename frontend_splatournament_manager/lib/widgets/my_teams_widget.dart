import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

class MyTeamsWidget extends StatefulWidget {
  const MyTeamsWidget({super.key});

  @override
  State<MyTeamsWidget> createState() => _MyTeamsWidgetState();
}

class _MyTeamsWidgetState extends State<MyTeamsWidget> {
  late Future<List<Team>> _myTeamsFuture;

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  void _loadMyTeams() {
    _myTeamsFuture = Provider.of<TeamProvider>(
      context,
      listen: false,
    ).getUserTeams();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Team>>(
      future: _myTeamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Fehler: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
            ),
          );
        }

        final teams = snapshot.data ?? [];
        if (teams.isEmpty) {
          return const Center(
            child: Text(
              'Du bist noch in keinem Team.\nTritt einem Team im Tab Alle Teams bei.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          itemBuilder: (context, index) => _buildTeamCard(teams[index]),
        );
      },
    );
  }

  Widget _buildTeamCard(Team team) {
    final memberCountText = team.memberCount != null
        ? '${team.memberCount}/4 Mitglieder'
        : 'Keine Mitglieder';
    final description = team.description.isEmpty
        ? 'Keine Beschreibung'
        : team.description;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(team.tag)),
        title: Text(team.name),
        subtitle: Text(
          '$description\n$memberCountText',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () => _leaveTeam(team),
        ),
      ),
    );
  }

  Future<void> _leaveTeam(Team team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Team verlassen?'),
        content: Text('Soll "${team.name}" verlassen werden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verlassen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await Provider.of<TeamProvider>(
          context,
          listen: false,
        ).leaveTeam(team.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Team verlassen')));
          _loadMyTeams();
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fehler: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    }
  }
}
