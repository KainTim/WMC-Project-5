import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/pages/create_team_page.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

class TeamsListWidget extends StatelessWidget {
  const TeamsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                return Center(
                  child: Text(
                    'Fehler: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                  ),
                );
              }

              if (teams.isEmpty) {
                return const Center(child: Text('Keine Teams gefunden'));
              }

              return ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) =>
                    TeamListItem(team: teams[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class TeamListItem extends StatelessWidget {
  final Team team;

  const TeamListItem({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
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
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'join', child: Text('Team beitreten')),
            const PopupMenuItem(value: 'edit', child: Text('Team bearbeiten')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Team löschen', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'join':
                await _joinTeam(context);
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTeamPage(teamToEdit: team),
                  ),
                );
              case 'delete':
                await _deleteTeam(context);
            }
          },
        ),
      ),
    );
  }

  Future<void> _joinTeam(BuildContext context) async {
    try {
      await Provider.of<TeamProvider>(context, listen: false).joinTeam(team.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Du bist ${team.name} beigetreten.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _deleteTeam(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Team löschen?'),
        content: Text(
          'Soll "${team.name}" gelöscht werden? Das kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<TeamProvider>(
          context,
          listen: false,
        ).deleteTeam(team.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Team gelöscht')));
        }
      } catch (e) {
        if (context.mounted) {
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
