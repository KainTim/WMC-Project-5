import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/pages/create_team_page.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teams"),
        actions: [
          IconButton(
            onPressed: () async {
              final teamProvider = Provider.of<TeamProvider>(
                context,
                listen: false,
              );
              try {
                await teamProvider.refreshTeams();
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to refresh teams')),
                );
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Consumer<TeamProvider>(
          builder: (context, provider, _) {
            return FutureBuilder<List<Team>>(
              future: provider.ensureTeamsLoaded(),
              builder: (context, snapshot) {
                final teams = provider.teams;

                if (snapshot.connectionState == ConnectionState.waiting &&
                    teams.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError && teams.isEmpty) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (teams.isEmpty) {
                  return const Center(child: Text('No teams found'));
                }

                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return TeamListItem(team: team);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTeamPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TeamListItem extends StatelessWidget {
  final Team team;

  const TeamListItem({super.key, required this.team});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Team'),
          content: Text('Are you sure you want to delete "${team.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  final provider = Provider.of<TeamProvider>(
                    context,
                    listen: false,
                  );
                  await provider.deleteTeam(team.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Team deleted')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(team.tag),
        ),
        title: Text(team.name),
        subtitle: Text(team.description.isEmpty ? 'No description' : team.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTeamPage(teamToEdit: team),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
