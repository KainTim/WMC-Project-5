import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

class MyTeamsWidget extends StatelessWidget {
  const MyTeamsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, provider, _) {
        return FutureBuilder<List<Team>>(
          future: provider.ensureUserTeamsLoaded(),
          builder: (context, snapshot) {
            final teams = provider.userTeams;

            if (snapshot.connectionState == ConnectionState.waiting &&
                teams.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && teams.isEmpty) {
              return Center(
                child: Text(
                  "Fehler: ${snapshot.error.toString().replaceFirst("Exception: ", "")}",
                ),
              );
            }

            if (teams.isEmpty) {
              return const Center(
                child: Text(
                  'Du bist noch in keinem Team.\nTritt einem Team unter Teams bei.',
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) =>
                  _buildTeamCard(context, teams[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team) {
    final memberCountText = team.memberCount != null
        ? "${team.memberCount}/4 Mitglieder"
        : "Keine Mitglieder";
    final description =
        team.description.isEmpty ? "Keine Beschreibung" : team.description;

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
          onPressed: () => _leaveTeam(context, team),
        ),
      ),
    );
  }

  Future<void> _leaveTeam(BuildContext context, Team team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Team verlassen?"),
        content: Text('Soll "${team.name}" verlassen werden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Abbrechen"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Verlassen", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<TeamProvider>(context, listen: false).leaveTeam(
          team.id,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Team verlassen")));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Fehler: ${e.toString().replaceFirst("Exception: ", "")}",
              ),
            ),
          );
        }
      }
    }
  }
}
